#!/bin/bash
# Start/stop screen sharing inside Microsoft Teams (⌘⇧E on Mac).
# Teams opens its share picker — pick the window or screen there.
source "$(dirname "$0")/../lib.sh"
keystroke_app "Microsoft Teams" "e" "command down, shift down"
