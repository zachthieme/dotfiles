#!/bin/bash

# Get the ID of the current space
current_space=$(aerospace list-workspaces --focused)

# Get the window ID for Slack
slack_window_id=$(aerospace list-windows --all | grep Slack | awk '{print $1}')

if [[ -z "$slack_window_id" ]]; then
  echo "Slack is not currently open."
  exit 1
fi
# aerospace focus --window-id "$slack_window_id"

aerospace move-node-to-workspace --focus-follows-window --window-id "$slack_window_id" "$current_space"
