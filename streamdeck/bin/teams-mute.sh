#!/bin/bash
# Toggle mute inside Microsoft Teams (⌘⇧M on Mac).
source "$(dirname "$0")/../lib.sh"
keystroke_app "Microsoft Teams" "m" "command down, shift down"
