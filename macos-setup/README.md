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
5. Install everything in the **Brewfile**.
6. Apply your **macOS system preferences**.

It's **idempotent** — safe to run again; already-installed things are skipped.

### Options

```bash
./bootstrap.sh --skip-brew       # only apply macOS preferences
./bootstrap.sh --skip-defaults   # only install apps
./bootstrap.sh --skip-rosetta    # skip Rosetta 2
./bootstrap.sh --help
```

You can also run either piece on its own:

```bash
brew bundle --file=./Brewfile    # just the apps
./macos-defaults.sh              # just the preferences
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

## Keeping this in sync

When you install or remove apps on the source Mac, refresh the Brewfile:

```bash
brew bundle dump --file=macos-setup/Brewfile --force
```

Then commit the change so the new-Mac setup always matches your current one.

## Mac App Store apps

None are captured because the `mas` CLI isn't installed. To include App Store
apps, follow the commented instructions at the bottom of the `Brewfile`.
