#!/usr/bin/env bash
#
# bootstrap.sh — set up a fresh Mac to match the MacBook Pro.
#
# Runs, in order:
#   1. sanity checks (macOS, Apple Silicon, not root)
#   2. Xcode Command Line Tools
#   3. Rosetta 2 (Apple Silicon, for the odd Intel-only app)
#   4. Homebrew + shell integration
#   5. all apps/formulae from Brewfile
#   6. macOS system preferences (macos-defaults.sh)
#   7. Dock icons (configure-dock.sh, via dockutil)
#
# Usage:
#   ./bootstrap.sh                 # do everything
#   ./bootstrap.sh --skip-brew     # skip Homebrew + Brewfile
#   ./bootstrap.sh --skip-defaults # skip macOS system preferences
#   ./bootstrap.sh --skip-rosetta  # skip Rosetta 2
#   ./bootstrap.sh --skip-dock     # skip Dock icon layout
#
# Idempotent: safe to run more than once.
#
# NOTE: mouse & scroll-direction settings only load at login — LOG OUT and back
# in (or restart) after this finishes for them to take effect.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKIP_BREW=false
SKIP_DEFAULTS=false
SKIP_ROSETTA=false
SKIP_DOCK=false
for arg in "$@"; do
  case "$arg" in
    --skip-brew)     SKIP_BREW=true ;;
    --skip-defaults) SKIP_DEFAULTS=true ;;
    --skip-rosetta)  SKIP_ROSETTA=true ;;
    --skip-dock)     SKIP_DOCK=true ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)
      echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

log()  { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$1"; }
info() { printf '    %s\n' "$1"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$1"; }

# ---------------------------------------------------------------------------
# 1. Sanity checks
# ---------------------------------------------------------------------------
log "Checking environment"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script only runs on macOS." >&2; exit 1
fi
if [[ "$(id -u)" -eq 0 ]]; then
  echo "Do not run this script as root / with sudo." >&2; exit 1
fi

ARCH="$(uname -m)"
info "macOS $(sw_vers -productVersion) ($(sw_vers -buildVersion)) on $ARCH"

if [[ "$ARCH" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

# ---------------------------------------------------------------------------
# 2. Xcode Command Line Tools
# ---------------------------------------------------------------------------
log "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  info "Already installed."
else
  info "Installing — accept the GUI prompt, then re-run this script if it exits."
  xcode-select --install || true
  # Wait until the tools are available.
  until xcode-select -p >/dev/null 2>&1; do
    sleep 15
  done
  info "Command Line Tools installed."
fi

# ---------------------------------------------------------------------------
# 3. Rosetta 2 (Apple Silicon only)
# ---------------------------------------------------------------------------
if [[ "$ARCH" == "arm64" && "$SKIP_ROSETTA" == false ]]; then
  log "Rosetta 2"
  if /usr/bin/pgrep -q oahd; then
    info "Already installed."
  else
    info "Installing Rosetta 2..."
    softwareupdate --install-rosetta --agree-to-license || warn "Rosetta 2 install skipped/failed."
  fi
fi

# ---------------------------------------------------------------------------
# 4. Homebrew
# ---------------------------------------------------------------------------
if [[ "$SKIP_BREW" == false ]]; then
  log "Homebrew"
  if ! command -v brew >/dev/null 2>&1 && [[ ! -x "$BREW_PREFIX/bin/brew" ]]; then
    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    info "Already installed."
  fi

  # Load brew into this shell.
  eval "$("$BREW_PREFIX/bin/brew" shellenv)"

  # Persist brew in the login shell (zsh) if not already there.
  ZPROFILE="$HOME/.zprofile"
  BREW_LINE="eval \"\$($BREW_PREFIX/bin/brew shellenv)\""
  if ! grep -qF "$BREW_PREFIX/bin/brew shellenv" "$ZPROFILE" 2>/dev/null; then
    echo "$BREW_LINE" >> "$ZPROFILE"
    info "Added Homebrew to $ZPROFILE"
  fi

  # ------------------------------------------------------------------------
  # 5. Install everything from the Brewfile
  # ------------------------------------------------------------------------
  log "Installing apps & formulae from Brewfile"
  brew update
  brew bundle --file="$DIR/Brewfile"
  brew cleanup
fi

# ---------------------------------------------------------------------------
# 6. macOS system preferences
# ---------------------------------------------------------------------------
if [[ "$SKIP_DEFAULTS" == false ]]; then
  log "Applying macOS system preferences"
  bash "$DIR/macos-defaults.sh"
fi

# ---------------------------------------------------------------------------
# 7. Dock icons (needs dockutil from the Brewfile)
# ---------------------------------------------------------------------------
if [[ "$SKIP_DOCK" == false ]]; then
  if command -v dockutil >/dev/null 2>&1; then
    log "Configuring Dock icons"
    bash "$DIR/configure-dock.sh"
  else
    warn "dockutil not found — skipping Dock icons. Install it and run ./configure-dock.sh"
  fi
fi

# ---------------------------------------------------------------------------
# Done — manual steps
# ---------------------------------------------------------------------------
log "Bootstrap complete 🎉"
cat <<'EOF'

    A few things a script can't (and shouldn't) do for you:

      * Sign in to iCloud, App Store, and app accounts.
      * Grant Full Disk Access / Accessibility / Screen Recording to apps
        that need it (System Settings ▸ Privacy & Security).
      * Sign in to Docker Desktop, VS Code sync, Chrome profile, etc.
      * Authenticate the GitHub CLI:  gh auth login
      * Set the computer name (see the optional block in macos-defaults.sh).
      * Restore any dotfiles / SSH keys / GPG keys you keep elsewhere.
      * Logitech devices: settings are replicated natively, but if you ever
        install Logi Options+, its config is app-managed (not in this script).

    >>> LOG OUT and back in (or restart) now. <<<
    Mouse right-click, scroll direction and pointer speed only load at login,
    so they will NOT change until you do this.

EOF
