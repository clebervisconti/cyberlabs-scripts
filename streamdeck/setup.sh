#!/bin/bash
# One-command install on any machine (this Mac, LION, the Cisco MacBook…):
#
#   git clone git@github.com:<you>/cyberlabs-scripts.git ~/cyberlabs/scripts   # if needed
#   cd ~/cyberlabs/scripts/streamdeck && ./setup.sh
#
# Rebuilds the .app launchers with THIS machine's absolute paths, regenerates
# the profile against them, and hands it to the Stream Deck app to import.
# Keys for things a machine doesn't have (OBS, Teams, the full workspace)
# degrade into a notification instead of failing silently.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HOME/Downloads/Cyberlabs.streamDeckProfile"

"$HERE/build-apps.sh"
python3 "$HERE/install-profile.py" "$OUT"

if [[ -d "/Applications/Elgato Stream Deck.app" ]]; then
  open "$OUT"
  echo
  echo "Imported into the Stream Deck app — pick the 'Cyberlabs' profile in its dropdown."
else
  echo
  echo "Stream Deck app not installed — get it from https://www.elgato.com/downloads,"
  echo "then: open '$OUT'"
fi
