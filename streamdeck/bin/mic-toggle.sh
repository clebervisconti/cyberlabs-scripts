#!/bin/bash
# Toggle the system microphone between muted and 70%. Remembers the prior level.
source "$(dirname "$0")/../lib.sh"

STATE="$HOME/.cache/streamdeck-mic-level"
mkdir -p "$(dirname "$STATE")"

current=$(/usr/bin/osascript -e 'input volume of (get volume settings)')

if [[ "$current" -gt 0 ]]; then
  echo "$current" > "$STATE"
  /usr/bin/osascript -e 'set volume input volume 0'
  notify "🎙 Mic muted" "Input volume 0"
else
  restore=$(cat "$STATE" 2>/dev/null)
  [[ "$restore" =~ ^[0-9]+$ && "$restore" -gt 0 ]] || restore=70
  /usr/bin/osascript -e "set volume input volume $restore"
  notify "🎙 Mic live" "Input volume $restore"
fi
