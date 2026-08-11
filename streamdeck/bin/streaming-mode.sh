#!/bin/bash
# Toggle "recording content" mode: close the noisy apps, set mic to 80%, turn
# Focus on, and open OBS. Pressing again brings the chat apps back.
source "$(dirname "$0")/../lib.sh"

STATE="$HOME/.cache/streamdeck-streaming-mode"
mkdir -p "$(dirname "$STATE")"
NOISY=("WhatsApp" "Music" "Mail")

if [[ -f "$STATE" ]]; then
  rm -f "$STATE"
  for app in "${NOISY[@]}"; do
    open -g -a "$app" 2>/dev/null || true
  done
  "$(dirname "$0")/focus-toggle.sh" >/dev/null 2>&1 || true
  notify "🎛 Streaming mode off" "Chat apps back, Focus toggled"
else
  touch "$STATE"
  for app in "${NOISY[@]}"; do
    /usr/bin/osascript -e "tell application \"$app\" to quit" 2>/dev/null || true
  done
  /usr/bin/osascript -e 'set volume input volume 80' -e 'set volume output volume 30'
  "$(dirname "$0")/focus-toggle.sh" >/dev/null 2>&1 || true
  open -a OBS 2>/dev/null || notify "🎥 OBS" "OBS not installed — brew install --cask obs"
  notify "🎛 Streaming mode on" "Mic 80% · distractions closed · Focus on · OBS up"
fi
