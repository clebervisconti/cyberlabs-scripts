#!/bin/bash
# Copy the cyberlabs-x-* Keychain items from HULK to b4tm4n so both machines match.
#
# Run on HULK, after x-keys-save.sh:
#     ~/Cyberlabs/scripts/x-credentials/x-keys-sync-b4tm4n.sh
#
# Why it works this way: b4tm4n's login keychain is locked to SSH, and
# `security unlock-keychain` only unlocks for the CURRENT security session — a
# later ssh connection is locked again. So the unlock and the writes have to
# happen inside one interactive session. You'll be asked for b4tm4n's login
# password once, by macOS itself.
#
# Values are base64-encoded into a 0600 staging file on b4tm4n, applied, then
# deleted (also removed on any exit path via trap). They are never in argv and
# never in shell history. The brief on-disk window is the tradeoff for not
# having to retype every value on the second machine.
set -uo pipefail

HOST=b4tm4n
ACC="$USER"
REMOTE_DATA="/tmp/.xk-$$.dat"
NAMES=(
  x-bearer-token
  x-consumer-key
  x-consumer-secret
  x-oauth1-access-token
  x-oauth1-access-token-secret
  x-client-id
  x-client-secret
  x-oauth2-access-token
  x-oauth2-refresh-token
)

data=""
count=0
for n in "${NAMES[@]}"; do
  v=$(security find-generic-password -a "$ACC" -s "cyberlabs-${n}" -w 2>/dev/null)
  if [[ -z "$v" ]]; then
    printf '  %-30s (absent locally, skipped)\n' "$n"
    continue
  fi
  data+="${n} $(printf '%s' "$v" | base64 | tr -d '\n')"$'\n'
  count=$((count+1))
done

if [[ $count -eq 0 ]]; then
  echo "nothing found locally under cyberlabs-x-* — run x-keys-save.sh first" >&2
  exit 1
fi

echo "staging $count item(s) on $HOST ..."
if ! printf '%s' "$data" | ssh "$HOST" "umask 077; cat > $REMOTE_DATA"; then
  echo "failed to stage data on $HOST" >&2; exit 1
fi

# Unlock + apply + clean up, all in one interactive session.
#
# The remote script is passed as the ssh COMMAND argument, not on stdin. Using a
# heredoc here would occupy stdin, so ssh -t could not allocate a tty and
# `security unlock-keychain` had nowhere to prompt (it read 0 chars and the
# heredoc-mangled loop died with "syntax error near unexpected token 'done'").
# It contains no secrets — only the path of the staging file.
REMOTE_SCRIPT="
trap 'rm -f $REMOTE_DATA' EXIT INT TERM
echo 'Unlocking b4tm4n login keychain (your b4tm4n login password):'
if ! security unlock-keychain; then
  echo 'unlock failed - nothing written' >&2; exit 1
fi
while IFS=' ' read -r n b; do
  [ -n \"\$n\" ] || continue
  v=\$(printf '%s' \"\$b\" | base64 -d 2>/dev/null || printf '%s' \"\$b\" | base64 -D)
  security add-generic-password -a \"\$USER\" -s \"cyberlabs-\$n\" \
      -D 'X API' -j 'X app credentials' -U -w \"\$v\" >/dev/null 2>&1
  back=\$(security find-generic-password -a \"\$USER\" -s \"cyberlabs-\$n\" -w 2>/dev/null)
  if [ \"\$back\" = \"\$v\" ]; then printf '  %-30s OK (%s chars)\n' \"\$n\" \"\${#v}\"
  else printf '  %-30s FAILED\n' \"\$n\"; fi
done < $REMOTE_DATA
rm -f $REMOTE_DATA
echo 'staging file removed'
"
ssh -t "$HOST" "$REMOTE_SCRIPT"

# Belt and braces: make sure the staging file is gone even if the session died.
ssh "$HOST" "rm -f $REMOTE_DATA" 2>/dev/null
echo "done"
