#!/bin/bash
# One-glance answer to "is anything uncommitted or unpushed across the repos?"
source "$(dirname "$0")/../lib.sh"
require_root

dirty=() ahead=() found=0
for repo in "${REPOS[@]}"; do
  d="$ROOT/$repo"
  [[ -d "$d/.git" ]] || continue
  found=$((found + 1))
  [[ -n "$(git -C "$d" status --porcelain)" ]] && dirty+=("$repo")
  count=$(git -C "$d" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
  [[ "$count" -gt 0 ]] && ahead+=("$repo+$count")
done

if [[ ${#dirty[@]} -eq 0 && ${#ahead[@]} -eq 0 ]]; then
  notify "✅ Workspace clean" "All $found repos committed and pushed"
else
  notify "⚠️ Workspace dirty" "Uncommitted: ${dirty[*]:-none} · Unpushed: ${ahead[*]:-none}"
fi
