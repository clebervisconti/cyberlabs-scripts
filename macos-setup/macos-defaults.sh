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
# Mouse & trackpad
###############################################################################

# Scroll direction — natural scrolling OFF (traditional direction)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Pointer tracking speed
defaults write NSGlobalDomain com.apple.mouse.scaling -float 1.5
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1

# Magic Mouse (applies once paired)
defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string "OneButton"
defaults write com.apple.AppleMultitouchMouse MouseOneFingerDoubleTapGesture -int 0
defaults write com.apple.AppleMultitouchMouse MouseTwoFingerDoubleTapGesture -int 3
defaults write com.apple.AppleMultitouchMouse MouseTwoFingerHorizSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode -string "OneButton"
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseHorizontalScroll -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseVerticalScroll -bool true

# Magic Trackpad (applies once paired) — tap to click on, three-finger drag off
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false

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

echo "==> Done. Some changes may require a logout/restart to fully apply."
