#!/bin/bash
# Toggle mute inside Webex using its own shortcut (⌘⇧M on Mac).
# If your Webex version uses a different binding, change KEY/MODS here.
source "$(dirname "$0")/../lib.sh"
keystroke_app "Webex" "m" "command down, shift down"
