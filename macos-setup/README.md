# macos-setup

Replicate the MacBook Pro's setup on another Mac (e.g. the Mac mini) with a
single command: installs Homebrew and all your apps, then applies your Finder /
Dock / mouse / keyboard preferences.

Everything here was **captured from the source MacBook Pro**, so a fresh machine
ends up matching it — not a generic template.

## What's in here

| File                 | Purpose                                                        |
| -------------------- | ------------------------------------------------------------- |
| `bootstrap.sh`       | One-command entry point. Runs the steps below in order.        |
| `Brewfile`           | All Homebrew formulae & casks (Chrome, VS Code, Docker, …).    |
| `macos-defaults.sh`  | System preferences (`defaults write`) captured from the Mac.   |
| `configure-dock.sh`  | Rebuilds the Dock's pinned apps & folders (uses `dockutil`).   |

## Usage on the new Mac

1. Copy this folder to the new Mac (clone the repo, AirDrop, or USB).
2. Run:

   ```bash
   cd macos-setup
   ./bootstrap.sh
   ```

That's it. The script will:

1. Check it's on macOS / Apple Silicon and not running as root.
2. Install **Xcode Command Line Tools** (accept the GUI prompt).
3. Install **Rosetta 2** (Apple Silicon).
4. Install **Homebrew** and wire it into your shell.
5. Install everything in the **Brewfile** (includes `dockutil`).
6. Apply your **macOS system preferences**.
7. Rebuild the **Dock icons** to match the source Mac.

It's **idempotent** — safe to run again; already-installed things are skipped.

> ⚠️ **Log out and back in (or restart) after it finishes.** Mouse settings
> (right-click, scroll direction, pointer speed) are only read at login, so they
> will not change until you do — `killall` is not enough. This is the usual
> reason a fresh Mac "ignores" the mouse config.

### Options

```bash
./bootstrap.sh --skip-brew       # skip Homebrew + Brewfile
./bootstrap.sh --skip-defaults   # skip macOS preferences
./bootstrap.sh --skip-rosetta    # skip Rosetta 2
./bootstrap.sh --skip-dock       # skip Dock icon layout
./bootstrap.sh --help
```

You can also run each piece on its own:

```bash
brew bundle --file=./Brewfile    # just the apps
./macos-defaults.sh              # just the preferences
./configure-dock.sh              # just the Dock layout (needs dockutil)
```

## Manual steps the script deliberately leaves to you

A setup script shouldn't handle credentials or system-security prompts. After
`bootstrap.sh` finishes:

- Sign in to **iCloud**, the **App Store**, and individual apps.
- Grant **Full Disk Access / Accessibility / Screen Recording** where needed
  (System Settings ▸ Privacy & Security).
- Sign in to **Docker Desktop**, **VS Code Settings Sync**, **Chrome** profile.
- Authenticate the **GitHub CLI** so `git push` works: `gh auth login`.
- Set the **computer name** (optional block in `macos-defaults.sh`).
- Restore **SSH/GPG keys** and any dotfiles you keep elsewhere.
- **Log out / restart** so all Dock, Finder and input settings fully apply.

## What is and isn't replicated

**Replicated by this script (via `defaults` / `dockutil`):**

- Appearance: Dark mode, accent colour
- Finder: column view, path/status bar, show extensions, drives on desktop, new-window target
- Dock: size, auto-hide, magnification, minimize behaviour, hidden recents, **pinned icons**, hot corner
- Mouse: **right-click (secondary button)**, scroll direction (natural off), pointer speed, scroll settings
- Text: capitalization / period substitution

**Input devices — important:** your mouse/keyboard are **Logitech (MX Vertical +
MX Mechanical)**, handled natively by macOS. Their settings live in
`com.apple.driver.AppleHIDMouse` and the global domain, and are captured here.
If you later install **Logi Options+**, any per-button customisation you do there
is stored by that app and is **not** in this script — export/import it from
within Logi Options+ instead.

**Not replicable by a script (do these by hand):**

- iCloud / App Store / app sign-ins, and Privacy & Security permissions
- Wallpaper, Notification settings, Control Center layout
- Anything configured inside a third-party app (Logi Options+, etc.)

## Keeping this in sync

When you install or remove apps on the source Mac, refresh the Brewfile:

```bash
brew bundle dump --file=macos-setup/Brewfile --force
```

Then commit the change so the new-Mac setup always matches your current one.

## Mac App Store apps

None are captured because the `mas` CLI isn't installed. To include App Store
apps, follow the commented instructions at the bottom of the `Brewfile`.
