#!/bin/bash
# Teaching mode: hide desktop clutter, silence interruptions, and open the FIAP
# material. Toggling off restores the desktop icons.
source "$(dirname "$0")/../lib.sh"

STATE="$HOME/.cache/streamdeck-class-mode"
mkdir -p "$(dirname "$STATE")"

if [[ -f "$STATE" ]]; then
  rm -f "$STATE"
  defaults write com.apple.finder CreateDesktop -bool true
  killall Finder
  notify "🎓 Class mode off" "Desktop icons restored"
else
  touch "$STATE"
  defaults write com.apple.finder CreateDesktop -bool false
  killall Finder
  /usr/bin/osascript -e 'tell application "WhatsApp" to quit' 2>/dev/null || true
  "$(dirname "$0")/focus-toggle.sh" >/dev/null 2>&1 || true
  open "$ROOT/memory/me/03-fiap" 2>/dev/null || true
  notify "🎓 Class mode on" "Desktop hidden · Focus on · FIAP notes open"
fi
