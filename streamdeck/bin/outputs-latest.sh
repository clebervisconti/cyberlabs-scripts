#!/bin/bash
# Open the most recently written run folder under outputs/ in Finder.
source "$(dirname "$0")/../lib.sh"

latest=$(find "$ROOT/outputs" -mindepth 2 -maxdepth 2 -type d -print0 2>/dev/null \
  | xargs -0 stat -f '%m %N' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

if [[ -z "$latest" ]]; then
  open "$ROOT/outputs"
  notify "📂 Outputs" "No run folders yet — opened outputs/"
else
  open "$latest"
  notify "📂 Latest run" "$(basename "$(dirname "$latest")")/$(basename "$latest")"
fi
