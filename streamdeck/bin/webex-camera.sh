#!/bin/bash
# Toggle the camera inside Webex using its own shortcut (⌘⇧V on Mac).
# If your Webex version uses a different binding, change the key here.
source "$(dirname "$0")/../lib.sh"
keystroke_app "Webex" "v" "command down, shift down"
