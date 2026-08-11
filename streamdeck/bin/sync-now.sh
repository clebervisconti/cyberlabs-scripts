#!/bin/bash
# Force the workspace repo sync that normally runs on the Claude Code Stop hook.
source "$(dirname "$0")/../lib.sh"
require_root

HOOK="$ROOT/.claude/sync-all.sh"
if [[ ! -x "$HOOK" ]]; then
  notify "🔄 Sync failed" "Not found or not executable: $HOOK"
  exit 1
fi

notify "🔄 Syncing" "Pulling, committing and pushing 8 repos…"

if out=$("$HOOK" 2>&1); then
  changed=$(printf '%s\n' "$out" | grep -ciE 'push|commit' || true)
  notify "✅ Sync done" "$changed repo action(s). Log: .claude/sync.log"
else
  notify "❌ Sync failed" "$(printf '%s' "$out" | tail -2 | tr '\n' ' ')"
  exit 1
fi
