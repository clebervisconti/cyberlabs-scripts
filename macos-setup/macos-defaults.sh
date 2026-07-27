#!/usr/bin/env bash
#
# macos-defaults.sh — apply macOS system preferences captured from the MacBook Pro.
#
# These `defaults write` values were read from the source Mac so a fresh machine
# (e.g. the Mac mini) ends up with the same Finder / Dock / mouse / keyboard
# behaviour. Safe to re-run — every setting is written idempotently.
#
# Usage:  ./macos-defaults.sh
#
# Notes:
#   * Some settings only take full effect after a logout/restart.
#   * Mouse & trackpad settings apply once a Magic Mouse / Magic Trackpad is
#     paired with the machine.
#   * To see the current value of any key:  defaults read <domain> <key>

set -euo pipefail

echo "==> Applying macOS defaults (captured from the MacBook Pro)"

# Close System Settings so it doesn't overwrite changes on exit.
osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true

###############################################################################
# General UI / appearance
###############################################################################

# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Accent colour: Green (0=Red 1=Orange 2=Yellow 3=Green 4=Blue 5=Purple 6=Pink)
defaults write NSGlobalDomain AppleAccentColor -int 3

###############################################################################
# Keyboard & text input
###############################################################################

# Text substitutions (as set on the source Mac)
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true

# NOTE: KeyRepeat / InitialKeyRepeat were left at macOS defaults on the source
# Mac, so they are intentionally not forced here. To get a fast key repeat,
# uncomment the two lines below (lower = faster):
#   defaults write NSGlobalDomain KeyRepeat -int 2
#   defaults write NSGlobalDomain InitialKeyRepeat -int 15

###############################################################################
# Mouse & scrolling
#
# Your input devices are Logitech (MX Vertical mouse + MX Mechanical keyboard),
# handled natively by macOS — Logi Options+ is NOT installed. A generic/non-Apple
# mouse is configured through `com.apple.driver.AppleHIDMouse`, so THAT is what we
# replicate. The Apple Magic Mouse / Magic Trackpad domains do not apply to you
# and are intentionally omitted.
#
# !! IMPORTANT: these mouse & scroll-direction settings are read by the input
# !! system at login. They will NOT take effect until you LOG OUT and back in
# !! (or restart). `killall` alone does not reload them.
###############################################################################

# Scroll direction — natural scrolling OFF (traditional direction)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Pointer tracking speed
defaults write NSGlobalDomain com.apple.mouse.scaling -float 1.5

# Generic (Logitech / non-Apple) mouse — button & scroll mapping
defaults write com.apple.driver.AppleHIDMouse Button1 -int 1          # left  button = primary click
defaults write com.apple.driver.AppleHIDMouse Button2 -int 1          # right button = secondary (right) click
defaults write com.apple.driver.AppleHIDMouse ButtonDominance -int 1
defaults write com.apple.driver.AppleHIDMouse ScrollV -int 1          # vertical scroll enabled
defaults write com.apple.driver.AppleHIDMouse ScrollH -int 1          # horizontal scroll enabled
defaults write com.apple.driver.AppleHIDMouse ScrollS -int 4          # scroll speed
defaults write com.apple.driver.AppleHIDMouse ScrollSSize -int 30

###############################################################################
# Finder
###############################################################################

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar and status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Default view style: column view ("clmv"). Others: Nlsv=list, icnv=icon, glyv=gallery
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# New Finder window target (value captured from the source Mac)
defaults write com.apple.finder NewWindowTarget -string "PfID"

# Show drives on the desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

###############################################################################
# Dock
###############################################################################

defaults write com.apple.dock tilesize -int 48            # icon size
defaults write com.apple.dock autohide -bool true          # auto-hide the Dock
defaults write com.apple.dock magnification -bool true      # magnify on hover
defaults write com.apple.dock largesize -int 57            # magnified icon size
defaults write com.apple.dock show-recents -bool false      # hide recent apps
defaults write com.apple.dock minimize-to-application -bool true  # minimize into app icon

###############################################################################
# Hot corners
#   0=off  2=Mission Control  3=App Windows  4=Desktop  5=Screen Saver
#   6=Disable Screen Saver  10=Sleep  11=Launchpad  12=Notification Center
#   13=Lock Screen  14=Quick Note
###############################################################################

# Bottom-right corner → Quick Note
defaults write com.apple.dock wvous-br-corner -int 14
defaults write com.apple.dock wvous-br-modifier -int 0

###############################################################################
# Computer name (OPTIONAL — disabled by default)
#   The source Mac is "Administrator's MacBook Pro"; you almost certainly want a
#   different name on the mini. Uncomment and edit to set it (requires sudo).
###############################################################################
# NEW_NAME="Cleber's Mac mini"
# sudo scutil --set ComputerName "$NEW_NAME"
# sudo scutil --set HostName    "$(echo "$NEW_NAME" | tr ' ' '-')"
# sudo scutil --set LocalHostName "$(echo "$NEW_NAME" | tr ' ' '-')"

###############################################################################
# Apply changes
###############################################################################

echo "==> Restarting Finder, Dock and SystemUIServer"
for app in Finder Dock SystemUIServer; do
  killall "$app" >/dev/null 2>&1 || true
done

echo ""
echo "==> Done."
echo ""
echo "    ┌──────────────────────────────────────────────────────────────┐"
echo "    │  LOG OUT and back in (or restart) now.                         │"
echo "    │  Mouse settings (right-click, scroll direction, pointer speed) │"
echo "    │  are only loaded at login — they will NOT change until you do.  │"
echo "    └──────────────────────────────────────────────────────────────┘"
