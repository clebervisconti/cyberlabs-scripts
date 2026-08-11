# Shared helpers for Stream Deck scripts. Sourced, never run directly.

# Workspace root — honours CYBERLABS_ROOT, falls back to the canonical path.
# On a machine without the full workspace (e.g. the Cisco MacBook), scripts that
# need it call require_root and fail with a notification instead of a silent no-op.
ROOT="${CYBERLABS_ROOT:-$HOME/cyberlabs}"

# Homebrew and user bins are not on PATH when launched from Finder/Stream Deck.
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"

notify() { # notify <title> <message>
  /usr/bin/osascript -e "display notification \"${2//\"/\\\"}\" with title \"${1//\"/\\\"}\""
}

require_root() { # guard for workspace-dependent scripts on foreign machines
  if [[ ! -d "$ROOT" ]]; then
    notify "🧪 Workspace missing" "No $ROOT on this machine — clone cyberlabs-scripts or set CYBERLABS_ROOT"
    exit 1
  fi
}

require_app() { # require_app <AppName> — notify and bail if the app is not installed
  if ! /usr/bin/osascript -e "id of application \"$1\"" >/dev/null 2>&1; then
    notify "❌ $1 not installed" "Install $1 to use this key"
    exit 1
  fi
}

# Run a command in a new Terminal window, leaving it open afterwards.
term() { # term <shell-command>
  /usr/bin/osascript <<APPLESCRIPT
tell application "Terminal"
  activate
  do script "${1//\"/\\\"}"
end tell
APPLESCRIPT
}

# Bring an app to the front and send it one of its own keyboard shortcuts.
# Needs Accessibility permission for the calling bundle on first use.
keystroke_app() { # keystroke_app <AppName> <key> <applescript-modifier-list>
  require_app "$1"
  /usr/bin/osascript \
    -e "tell application \"$1\" to activate" \
    -e "delay 0.4" \
    -e "tell application \"System Events\" to keystroke \"$2\" using {$3}"
}

# The nine synced repos plus splunk (own pipeline), in workspace order.
REPOS=(squads agents skills memory shared design infra scripts data splunk)
