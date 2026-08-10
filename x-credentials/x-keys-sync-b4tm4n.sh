#!/bin/bash
# Copy the cyberlabs-x-* Keychain items from HULK to b4tm4n so both machines match.
#
# Run on HULK, AFTER x-keys-save.sh and AFTER unlocking b4tm4n's keychain:
#     ssh -t b4tm4n security unlock-keychain
#
# Values are base64-encoded and sent on stdin, so no shell quoting can corrupt them
# and nothing sensitive appears in argv, history, or on disk.
set -uo pipefail

HOST=b4tm4n
ACC="$USER"
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

if ! ssh "$HOST" 'security show-keychain-info' >/dev/null 2>&1; then
  echo "b4tm4n keychain is LOCKED. Unlock it first, then re-run:" >&2
  echo "    ssh -t $HOST security unlock-keychain" >&2
  exit 1
fi

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

# Fixed remote script (no interpolation, no secrets in argv); data arrives on stdin.
REMOTE='
while IFS=" " read -r n b; do
  [ -n "$n" ] || continue
  v=$(printf "%s" "$b" | base64 -d 2>/dev/null || printf "%s" "$b" | base64 -D)
  printf "%s\n%s\n" "$v" "$v" | security add-generic-password -a "$USER" \
      -s "cyberlabs-$n" -D "X API" -j "PostizCS app 32972511" -U -w >/dev/null 2>&1
  back=$(security find-generic-password -a "$USER" -s "cyberlabs-$n" -w 2>/dev/null)
  if [ "$back" = "$v" ]; then printf "  %-30s OK (%s chars)\n" "$n" "${#v}"
  else printf "  %-30s FAILED\n" "$n"; fi
done
'

echo "pushing $count item(s) to $HOST:"
printf '%s' "$data" | ssh "$HOST" "bash -c '$REMOTE'"
echo "done"
