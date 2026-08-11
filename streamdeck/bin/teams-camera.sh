#!/bin/bash
# Toggle the camera inside Microsoft Teams (⌘⇧O on Mac).
source "$(dirname "$0")/../lib.sh"
keystroke_app "Microsoft Teams" "o" "command down, shift down"
