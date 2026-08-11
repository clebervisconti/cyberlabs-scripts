#!/bin/bash
# Teams has no keyboard shortcut for recording, so this brings Teams to the
# front and reminds you of the two clicks left. (UI-scripting the menu breaks
# on every Teams update — a reliable nudge beats a flaky automation.)
source "$(dirname "$0")/../lib.sh"
require_app "Microsoft Teams"
/usr/bin/osascript -e 'tell application "Microsoft Teams" to activate'
notify "⏺ Gravar aula" "Na reunião: Mais (⋯) → Gravar e transcrever → Iniciar gravação"
