#!/bin/bash
# Toggle "about to be on camera" mode: quiet the noisy apps, unmute the mic,
# set a sane output level. Pressing again brings the chat apps back.
source "$(dirname "$0")/../lib.sh"

STATE="$HOME/.cache/streamdeck-meeting-mode"
mkdir -p "$(dirname "$STATE")"
NOISY=("WhatsApp" "Music" "Plaud")

if [[ -f "$STATE" ]]; then
  rm -f "$STATE"
  for app in "${NOISY[@]}"; do
    open -g -a "$app" 2>/dev/null || true
  done
  notify "🎬 Meeting mode off" "Chat apps back, Focus unchanged"
else
  touch "$STATE"
  for app in "${NOISY[@]}"; do
    /usr/bin/osascript -e "tell application \"$app\" to quit" 2>/dev/null || true
  done
  /usr/bin/osascript -e 'set volume input volume 70' -e 'set volume output volume 40'
  "$(dirname "$0")/focus-toggle.sh" >/dev/null 2>&1 || true
  notify "🎬 Meeting mode on" "Mic 70% · distractions closed · Focus toggled"
fi
