# Shared helpers for Stream Deck scripts. Sourced, never run directly.

# Workspace root — honours CYBERLABS_ROOT, falls back to the canonical path.
ROOT="${CYBERLABS_ROOT:-$HOME/cyberlabs}"

# Homebrew and user bins are not on PATH when launched from Finder/Stream Deck.
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"

notify() { # notify <title> <message>
  /usr/bin/osascript -e "display notification \"${2//\"/\\\"}\" with title \"${1//\"/\\\"}\""
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

# The eight synced repos, in workspace order.
REPOS=(squads agents skills memory shared design infra scripts)
