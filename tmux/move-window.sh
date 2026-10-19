#!/bin/sh
# Move current window to another session via fzf picker

current_session=$(tmux display-message -p '#S')

target=$(tmux list-sessions -F "#S" | grep -v "^${current_session}$" | \
    fzf --prompt="Move window to > " --height=80% --reverse --exact)

[ -z "$target" ] && exit 0

tmux switch-client -t "$target"
tmux move-window -s "${current_session}:" -t "$target"
