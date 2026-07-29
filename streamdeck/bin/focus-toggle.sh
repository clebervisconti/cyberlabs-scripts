#!/bin/bash
# Toggle a macOS Focus. There is no supported CLI for Focus, so this drives a
# Shortcut you own — see README ("Focus key setup") for the two-minute build.
source "$(dirname "$0")/../lib.sh"

SHORTCUT="SD Toggle Focus"

if ! command -v shortcuts >/dev/null 2>&1; then
  notify "🌙 Focus" "shortcuts CLI unavailable on this macOS"
  exit 1
fi

if ! shortcuts list 2>/dev/null | grep -qx "$SHORTCUT"; then
  notify "🌙 Focus not wired" "Create a Shortcut named “$SHORTCUT” — see streamdeck/README.md"
  open -a Shortcuts
  exit 1
fi

shortcuts run "$SHORTCUT"
