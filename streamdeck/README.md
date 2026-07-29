# Stream Deck — Cyberlabs key set

Scripts behind the Elgato Stream Deck MK.2 (15 keys, 5×3). Everything here is plain
shell in git, so a new machine just needs `./build-apps.sh` and a profile import.

```
lib.sh             shared helpers (root resolution, PATH, notify, Terminal launcher)
bin/*.sh           the actual scripts — edit these
build-apps.sh      regenerates apps/ ; run after adding or renaming a script
apps/*.app         thin launchers the Stream Deck binds to (generated, do not edit)
install-profile.py emits a .streamDeckProfile with the whole layout pre-bound
```

## Install

```bash
cd ~/cyberlabs/scripts/streamdeck
./build-apps.sh
python3 install-profile.py ~/Downloads/Cyberlabs.streamDeckProfile
open ~/Downloads/Cyberlabs.streamDeckProfile
```

That imports a profile named **Cyberlabs** with all 15 home keys and the four
folders already bound. Pick it from the profile dropdown in the Stream Deck app;
to make it the one that loads on plug-in, set it as default there.

### Do not write into ProfilesV3 directly

Tried, twice, does not work. The app only reads profiles at launch, and quitting it
by AppleScript registers as `last session did not properly end` — on the next launch
it restores a backup and re-imports `StreamDeck_macDefault.streamDeckProfile`,
silently throwing away anything written by hand. Importing is the supported path and
needs no restart. The generator documents the format details the app is strict about.

## Why .app bundles

The Stream Deck **Open** action passes its path to `open`. Given a `.sh` that opens your
editor; given a `.app` it runs the script with no Terminal window and no Dock bounce.
`build-apps.sh` generates one `LSUIElement` bundle per script that `exec`s the real file,
so the bundles never drift from the scripts.

## Binding one key by hand

If you add a script and don't want to regenerate the profile: drag **System → Open**
onto a key, then set **App / File** to the bundle. The path must be **absolute and
wrapped in double quotes** — `"/Users/clebervisconti/cyberlabs/scripts/streamdeck/apps/mic-toggle.app"`.
A `~` will not expand and the key will do nothing.

URLs need no script — use **System → Website**. App keystrokes (Zoom mute, Webex
video) — use **System → Hotkey**.

## Layout as installed

### Home

| | | | | |
|---|---|---|---|---|
| 🧪 Cyberlabs *(folder)* | 🎓 Teach *(folder)* | 📣 Studio *(folder)* | 🛰 Infra *(folder)* | 🎙 Mic |
| ⚡ Claude | 🚀 Run Squad | 📂 Outputs | 🔄 Sync | 🎬 Meeting |
| 🌙 Focus | 📸 Screen ⇧⌘5 | 📅 Join | 🩺 Health | ⏯ Media |

### Folders

- **Cyberlabs** — Claude · Resume · Run Squad · Squads · Outputs · Repos · Sync · VS Code
- **Teach** — Class Mode · Focus · Join · Screen ⇧⌘5 · Outputs
- **Studio** — ContentOS · Instagram · LinkedIn · YT Studio · Site · Run Squad
- **Infra** — VPS · Health · Meraki · Cloudflare · Repos

Edit the `HOME` / `FOLDERS` dicts in `install-profile.py`, then regenerate and re-import.

## Focus key setup (one-time, ~2 min)

macOS exposes no CLI for Focus, so `focus-toggle` drives a Shortcut you own:

1. Shortcuts app → **+** → add action **Set Focus**.
2. Set it to your Focus (e.g. Do Not Disturb) and change *Turn On* to **Toggle**.
3. Rename the shortcut exactly **`SD Toggle Focus`**.

`meeting-mode` and `class-mode` call it too, so this one step lights up three keys.
Until it exists, those keys still work — they just skip the Focus part and tell you why.

## Permissions

First press of some keys triggers a macOS prompt — grant once:

- `join-next-meeting` → Calendar access (System Settings → Privacy → Calendars)
- `meeting-mode`, `class-mode` → Automation (control WhatsApp / Finder)
- notifications → allow for the `.app` bundle or Stream Deck

## Toggle state

`mic-toggle`, `meeting-mode` and `class-mode` keep state in `~/.cache/streamdeck-*`.
Delete those files to reset a stuck toggle.
