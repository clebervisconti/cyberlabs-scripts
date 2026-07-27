#!/usr/bin/env bash
#
# configure-dock.sh — rebuild the Dock's pinned apps & folders to match the
# MacBook Pro. This sets *which icons* are in the Dock; visual behaviour
# (size, auto-hide, magnification, hot corners) is handled by macos-defaults.sh.
#
# Requires dockutil (installed via the Brewfile):  brew install dockutil
#
# Usage:  ./configure-dock.sh
#
# Idempotent: it clears the Dock and rebuilds it from the list below, so
# re-running always produces the same result. Apps that aren't installed on
# this machine are skipped with a note (e.g. Xcode, if you haven't installed it).

set -euo pipefail

DOCKUTIL="$(command -v dockutil || true)"
if [[ -z "$DOCKUTIL" ]]; then
  echo "dockutil not found. Install it first:  brew install dockutil" >&2
  exit 1
fi

echo "==> Rebuilding the Dock for user: $USER"

# Pinned apps, in order (captured from the source Mac).
#   * /System/Applications/...  → built-in macOS apps (present on every Mac)
#   * /Applications/...         → third-party apps (installed via the Brewfile)
APPS=(
  "/System/Applications/iPhone Mirroring.app"
  "/System/Applications/System Settings.app"
  "/System/Applications/Utilities/Activity Monitor.app"
  "/System/Applications/Utilities/Terminal.app"
  "/System/Applications/Passwords.app"
  "/System/Applications/Utilities/Screen Sharing.app"
  "/Applications/Safari.app"
  "/Applications/Google Chrome.app"
  "/Applications/Claude.app"
  "/Applications/Antigravity IDE.app"
  "/Applications/GitHub Desktop.app"
  "/Applications/Xcode.app"
  "/System/Applications/Mail.app"
  "/System/Applications/Calendar.app"
  "/System/Applications/Photos.app"
  "/System/Applications/Reminders.app"
  "/System/Applications/Notes.app"
  "/System/Applications/Music.app"
)

# Start from an empty Dock so re-runs are deterministic.
"$DOCKUTIL" --remove all --no-restart >/dev/null

for app in "${APPS[@]}"; do
  path="$app"
  # Safari lives in a sealed system (Cryptex) path on modern macOS; fall back to it.
  if [[ "$app" == "/Applications/Safari.app" && ! -e "$app" ]]; then
    path="/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
  fi
  if [[ -e "$path" ]]; then
    "$DOCKUTIL" --add "$path" --no-restart >/dev/null
    echo "   added:   $(basename "$app" .app)"
  else
    echo "   skipped: $(basename "$app" .app) (not installed)"
  fi
done

# Folders / stacks on the right side of the Dock.
# Applications → folder icon, automatic view, sorted by name.
"$DOCKUTIL" --add "/Applications" --view auto --display folder --sort name --no-restart >/dev/null
echo "   added:   Applications (folder)"
# Downloads → stack, fan view, sorted by date added (uses the current user's home).
"$DOCKUTIL" --add "$HOME/Downloads" --view fan --display stack --sort dateadded --no-restart >/dev/null
echo "   added:   Downloads (stack)"

killall Dock >/dev/null 2>&1 || true
echo "==> Dock configured."
