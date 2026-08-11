#!/bin/bash
# Pick a squad from a native list, then start a Claude Code session already
# primed with /squad run <name>.
source "$(dirname "$0")/../lib.sh"
require_root

squads=$(find "$ROOT/squads" -mindepth 1 -maxdepth 1 -type d ! -name management ! -name '.*' -exec basename {} \; | sort)
[[ -z "$squads" ]] && { notify "🚀 No squads" "Nothing under squads/"; exit 1; }

applescript_list=$(printf '%s' "$squads" | sed 's/.*/"&"/' | paste -sd, -)

choice=$(/usr/bin/osascript <<APPLESCRIPT
set opts to {$applescript_list}
set pick to choose from list opts with title "Run a squad" with prompt "Which squad?" without multiple selections allowed
if pick is false then return ""
return item 1 of pick
APPLESCRIPT
)

[[ -z "$choice" ]] && exit 0
term "cd '$ROOT' && claude '/squad run $choice'"
