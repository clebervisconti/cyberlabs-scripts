#!/bin/bash
# Toggle OBS recording. Two paths, best first:
#   1. obs-cmd over the built-in websocket (brew install obs-cmd; enable
#      Tools → WebSocket Server in OBS, password in Keychain as "obs-websocket").
#      Works without stealing focus — ideal mid-recording.
#   2. Fallback: bring OBS to the front and press ⇧⌘R — set that as the
#      Start/Stop Recording hotkey in OBS Settings → Hotkeys.
source "$(dirname "$0")/../lib.sh"

if command -v obs-cmd >/dev/null 2>&1; then
  pw=$(security find-generic-password -s obs-websocket -w 2>/dev/null || true)
  url="obsws://localhost:4455${pw:+/$pw}"
  if obs-cmd --websocket "$url" recording toggle >/dev/null 2>&1; then
    notify "🔴 OBS" "Recording toggled (websocket)"
    exit 0
  fi
fi

require_app "OBS"
if ! pgrep -xq OBS; then
  open -a OBS
  notify "🎥 OBS starting" "Press again to toggle recording"
  exit 0
fi
keystroke_app "OBS" "r" "command down, shift down"
notify "🔴 OBS" "Sent ⇧⌘R — set it as Start/Stop Recording in OBS Hotkeys"
