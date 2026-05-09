#!/usr/bin/env bash
# Calculates the needed popup width and opens the project picker

CONF="$HOME/.config/tmux/projects.conf"

[ -f "$CONF" ] || exit 1

max_name=0
max_parent=0

while IFS= read -r dir; do
    [[ -z "$dir" || "$dir" == '#'* ]] && continue
    dir="${dir/#\~/$HOME}"
    [[ -d "$dir" ]] || continue
    base="${dir##*/}"
    parent_len=$((${#base} + 3))  # [base] = name + 2 brackets + 1 space
    [[ $parent_len -gt $max_parent ]] && max_parent=$parent_len
    for project_path in "$dir"/*/; do
        [[ -d "$project_path" ]] || continue
        name="${project_path%/}"
        name="${name##*/}"
        [[ ${#name} -gt $max_name ]] && max_name=${#name}
    done
done < "$CONF"

# name + 2 spaces + [parent] + fzf chrome (border + scrollbar)
width=$((max_name + max_parent + 6))

tmux display-popup -E -w "$width" "$HOME/.config/tmux/projects.sh"
