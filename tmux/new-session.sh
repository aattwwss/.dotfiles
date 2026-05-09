#!/bin/sh
# Prompt for a session name and create it

printf "New session name: "
read name

[ -z "$name" ] && exit 0

if tmux has-session -t "$name" 2>/dev/null; then
    tmux switch-client -t "$name"
else
    tmux new-session -d -s "$name" -c "$HOME"
    tmux switch-client -t "$name"
fi
