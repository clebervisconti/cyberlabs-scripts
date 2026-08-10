#!/bin/bash
# Capture every X credential for app PostizCS (32972511) into the local Keychain.
# Run this on TIGER while the portal has the regenerated values on screen.
# Values are typed once, never echoed, never in shell history, never in argv.
# Blank input = keep whatever is already stored (skip that item).
set -uo pipefail

ACC="$USER"
ok=0; skip=0

# service-suffix | prompt label | expected length (0 = don't check)
ITEMS=(
  "x-bearer-token|Bearer Token (App-Only)|0"
  "x-consumer-key|Consumer Key (OAuth 1.0a)|25"
  "x-consumer-secret|Consumer Secret (OAuth 1.0a)|50"
  "x-oauth1-access-token|Access Token (OAuth 1.0a)|0"
  "x-oauth1-access-token-secret|Access Token Secret (OAuth 1.0a)|45"
  "x-client-id|Client ID (OAuth 2.0)|0"
  "x-client-secret|Client Secret (OAuth 2.0)|0"
  "x-oauth2-access-token|Access Token (OAuth 2.0)|0"
  "x-oauth2-refresh-token|Refresh Token (OAuth 2.0)|0"
)

declare -a STORED_NAMES=() STORED_VALS=()

echo "X credentials -> Keychain (service prefix: cyberlabs-)"
echo "Press Enter to skip an item and keep the existing value."
echo

for row in "${ITEMS[@]}"; do
  IFS='|' read -r name label want <<< "$row"
  printf '%-38s: ' "$label"
  read -rs val; echo
  if [[ -z "$val" ]]; then
    printf '  -> skipped\n'; skip=$((skip+1)); continue
  fi
  if [[ "$want" != "0" && "${#val}" -ne "$want" ]]; then
    printf '  !! warning: got %s chars, expected %s — storing anyway\n' "${#val}" "$want"
  fi
  # NOTE: security reads -w from /dev/tty when a terminal exists, so piping the
  # value in does not work interactively. Pass it inline instead.
  security add-generic-password -a "$ACC" -s "cyberlabs-${name}" \
      -D "X API" -j "PostizCS app 32972511" -U -w "$val" >/dev/null 2>&1
  back=$(security find-generic-password -a "$ACC" -s "cyberlabs-${name}" -w 2>/dev/null)
  if [[ "$back" == "$val" ]]; then
    printf '  -> saved (%s chars)\n' "${#val}"
    ok=$((ok+1)); STORED_NAMES+=("$name"); STORED_VALS+=("$val")
  else
    printf '  -> FAILED to store\n'
  fi
done

echo
# catch the mistake made earlier: the same value pasted into two different fields
dupe=0
for ((i=0; i<${#STORED_VALS[@]}; i++)); do
  for ((j=i+1; j<${#STORED_VALS[@]}; j++)); do
    if [[ "${STORED_VALS[$i]}" == "${STORED_VALS[$j]}" ]]; then
      echo "!! ${STORED_NAMES[$i]} and ${STORED_NAMES[$j]} hold the SAME value — one is wrong"
      dupe=1
    fi
  done
done
[[ $dupe -eq 0 ]] && echo "no duplicate values detected"

echo "saved: $ok   skipped: $skip"
echo
echo "current state:"
for row in "${ITEMS[@]}"; do
  IFS='|' read -r name label want <<< "$row"
  v=$(security find-generic-password -a "$ACC" -s "cyberlabs-${name}" -w 2>/dev/null)
  if [[ -n "$v" ]]; then printf '  %-30s %s chars\n' "$name" "${#v}"
  else printf '  %-30s (absent)\n' "$name"; fi
done
