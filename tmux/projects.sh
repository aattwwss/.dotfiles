#!/usr/bin/env bash
# tmux project picker
# Configure which directories to scan in projects.conf (one path per line)

CONF="$HOME/.config/tmux/projects.conf"
TABS_PER_PROJECT=3

[ -f "$CONF" ] || { echo "Missing $CONF"; exit 1; }

# First pass: collect raw entries as "name|parent|path"
raw=$(
    while IFS= read -r dir; do
        [[ -z "$dir" || "$dir" == '#'* ]] && continue
        dir="${dir/#\~/$HOME}"
        [[ -d "$dir" ]] || continue
        base="${dir##*/}"
        for project_path in "$dir"/*/; do
            [[ -d "$project_path" ]] || continue
            name="${project_path%/}"
            name="${name##*/}"
            echo "$name|$base|$project_path"
        done
    done < "$CONF"
)

# Second pass: format with dynamic padding based on longest name
max_len=$(echo "$raw" | awk -F'|' '{print length($1)}' | sort -n | tail -1)
list=$(echo "$raw" | awk -F'|' -v ml="$max_len" '{printf "%-*s  [%s]|%s\n", ml, $1, $2, $3}')

selection=$(echo "$list" | awk -F'|' '{print $1}' | \
    fzf --prompt="Projects > " --height=100% --reverse --exact)

[ -z "$selection" ] && exit 0

project_path=$(echo "$list" | awk -F'|' -v sel="$selection" '$1 == sel {print $2}')
project="${project_path%/}"
project="${project##*/}"

if ! tmux has-session -t "$project" 2>/dev/null; then
    tmux new-session -d -s "$project" -c "$project_path"

    i=1
    while [ $i -lt $TABS_PER_PROJECT ]; do
        tmux new-window -t "$project" -c "$project_path"
        i=$((i + 1))
    done

    tmux select-window -t "$project:1"
fi

if [ -n "$TMUX" ]; then
    tmux switch-client -t "$project"
else
    tmux attach-session -t "$project"
fi
