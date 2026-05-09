#!/bin/sh
# AWS profile picker — selects a profile and injects it into the active pane

profile=$(grep '^\[profile' ~/.aws/config | sed 's/\[profile //;s/\]//' | \
    fzf --prompt="AWS Profile > " --height=100% --reverse --exact)

[ -z "$profile" ] && exit 0

tmux set-environment AWS_PROFILE "$profile"
tmux send-keys "export AWS_PROFILE=$profile" Enter