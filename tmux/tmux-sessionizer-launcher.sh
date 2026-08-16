#!/usr/bin/env bash
# Calculates the needed popup width and opens the tmux-sessionizer

CONF="$HOME/.config/tmux-sessionizer/tmux-sessionizer.conf"

[ -f "$CONF" ] || exit 1

# shellcheck disable=SC1090
source "$CONF"

# mirror sessionizer defaults if not set
[[ -n "$TS_SEARCH_PATHS" ]] || TS_SEARCH_PATHS=(~/ ~/personal ~/personal/dev/env/.config)

max_name=0
max_parent=0

for entry in "${TS_SEARCH_PATHS[@]}"; do
    path="${entry%%:*}"
    path="${path/#\~/$HOME}"
    [[ -d "$path" ]] || continue
    base="${path##*/}"
    parent_len=$((${#base} + 3))  # [base] = name + 2 brackets + 1 space
    [[ $parent_len -gt $max_parent ]] && max_parent=$parent_len
    while IFS= read -r d; do
        name="${d##*/}"
        [[ ${#name} -gt $max_name ]] && max_name=${#name}
    done < <(find "$path" -mindepth 1 -maxdepth 1 -type d)
done

# [TMUX] bracket always fits
[[ 7 -gt $max_parent ]] && max_parent=7

# longest session name also fits
tmux_max=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | \
    awk '{ if (length($0) > m) m = length($0) } END { print m+0 }')
[[ $tmux_max -gt $max_name ]] && max_name=$tmux_max

# name + 2 spaces + [parent] + fzf chrome (border + scrollbar)
width=$((max_name + max_parent + 6))
[[ $width -lt 40 ]] && width=40

tmux display-popup -E -w "$width" "$HOME/.config/tmux/tmux-sessionizer.sh"
