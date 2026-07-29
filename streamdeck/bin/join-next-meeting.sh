#!/bin/bash
# Find the next Calendar event within the coming hour that carries a join link
# (Webex, Zoom, Meet, Teams) and open it. Needs Calendar access on first run.
source "$(dirname "$0")/../lib.sh"

url=$(/usr/bin/osascript <<'APPLESCRIPT' 2>/dev/null
set now to current date
set horizon to now + (60 * 60)
tell application "Calendar"
  set candidates to {}
  repeat with c in calendars
    tell c
      set evs to (every event whose start date is greater than (now - 300) and start date is less than horizon)
      repeat with e in evs
        set blob to ""
        try
          set blob to blob & (url of e)
        end try
        try
          set blob to blob & " " & (description of e)
        end try
        try
          set blob to blob & " " & (location of e)
        end try
        set end of candidates to blob
      end repeat
    end tell
  end repeat
end tell
return candidates as text
APPLESCRIPT
)

link=$(printf '%s' "$url" | grep -oE 'https://[^ ",<>]*(webex\.com|zoom\.us|meet\.google\.com|teams\.microsoft\.com)[^ ",<>]*' | head -1)

if [[ -n "$link" ]]; then
  open "$link"
  notify "📅 Joining" "${link:0:60}…"
else
  open -a Calendar
  notify "📅 No join link" "Nothing with a meeting URL in the next hour"
fi
