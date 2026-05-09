#!/bin/sh
# Fuzzy session/window switcher for tmux

current=$(tmux display-message -p '#S')

while true; do
    result=$(tmux list-sessions -F "#S" | awk -v cur="$current" '{
        if ($0 == cur) print $0 " *"
        else print $0
    }' | fzf --prompt="Session > " --height=80% --reverse --exact \
      --header="Enter:switch | Ctrl-R:rename | Ctrl-X:kill" \
      --bind="ctrl-r:become(echo RENAME:{})" \
      --bind="ctrl-x:become(echo KILL:{})" \
      --print-query)

    query=$(echo "$result" | head -1)
    session=$(echo "$result" | tail -1)
    # Strip the asterisk marker if present
    session=$(echo "$session" | sed 's/ \*$//')

    # Exited with no selection
    [ -z "$query" ] && [ -z "$session" ] && exit 0

    if echo "$session" | grep -q "^RENAME:"; then
        target=$(echo "$session" | sed 's/^RENAME://;s/ \*$//')
        printf "New name for '$target': "
        read name
        if [ -n "$name" ]; then
            tmux rename-session -t "$target" "$name"
            [ "$target" = "$current" ] && current="$name"
        fi
    elif echo "$session" | grep -q "^KILL:"; then
        target=$(echo "$session" | sed 's/^KILL://;s/ \*$//')
        # Find another session to fall back to
        other=$(tmux list-sessions -F "#S" | grep -v "^${target}$" | head -1)
        if [ -n "$other" ]; then
            [ "$target" = "$current" ] && tmux switch-client -t "$other" && current="$other"
            tmux kill-session -t "$target"
        else
            # Last session — just kill it and exit tmux
            tmux kill-session -t "$target"
            exit 0
        fi
    else
        tmux switch-client -t "$session"
        exit 0
    fi
done
