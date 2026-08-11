#!/bin/bash
# Open the share-content picker inside Webex (⌘⇧K on Mac).
# If your Webex version uses a different binding, change the key here.
source "$(dirname "$0")/../lib.sh"
keystroke_app "Webex" "k" "command down, shift down"
