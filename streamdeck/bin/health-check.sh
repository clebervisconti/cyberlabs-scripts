#!/bin/bash
# "Is my stuff up?" — VPS reachable, and the public apps answering.
source "$(dirname "$0")/../lib.sh"

SITES=(https://clebervisconti.com https://contentos.clebervisconti.com)
VPS_HOST=hostgator

results=()

if ping -c 1 -t 3 "$(awk '/^Host hostgator$/{f=1;next} f&&/HostName/{print $2;exit}' "$HOME/.ssh/config")" >/dev/null 2>&1; then
  results+=("VPS ✅")
else
  results+=("VPS ❌")
fi

for s in "${SITES[@]}"; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 "$s")
  name=$(printf '%s' "$s" | sed -E 's#https://##; s#\.clebervisconti\.com##; s#clebervisconti\.com#site#')
  if [[ "$code" =~ ^(200|30[0-9]|401|403)$ ]]; then
    results+=("$name ✅")
  else
    results+=("$name ❌$code")
  fi
done

notify "🛰 Health check" "${results[*]}"
