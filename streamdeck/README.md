# Stream Deck — Cyberlabs key set

Scripts behind the Elgato Stream Deck MK.2 (15 keys, 5×3). Everything here is plain
shell in git, so **any machine** (this Mac, LION, the Cisco MacBook) gets the exact
same shortcuts with one command — see *Portability* below.

```
lib.sh             shared helpers (root resolution, PATH, notify, keystroke_app, Terminal)
bin/*.sh           the actual scripts — edit these
build-apps.sh      regenerates apps/ ; run after adding or renaming a script
apps/*.app         thin launchers the Stream Deck binds to (generated, do not edit)
install-profile.py emits a .streamDeckProfile with the whole layout pre-bound
setup.sh           build-apps + generate + import, in one shot
```

## Install / update

```bash
cd ~/cyberlabs/scripts/streamdeck
./setup.sh
```

That imports a profile named **Cyberlabs** with all keys and the four folders
bound. Pick it from the profile dropdown in the Stream Deck app; to make it the
one that loads on plug-in, set it as default there.

## Portability (Cisco MacBook or any other Mac)

The profile embeds **absolute paths generated on the machine that runs
`setup.sh`**, so never copy an already-generated `.streamDeckProfile` between
machines with different usernames — regenerate instead:

1. Install the Elgato Stream Deck app.
2. `git clone` the `cyberlabs-scripts` repo (anywhere; `~/cyberlabs/scripts` is canonical).
3. `cd <repo>/streamdeck && ./setup.sh`

Keys degrade gracefully where a machine lacks something: no OBS/Teams → the key
notifies "not installed"; no `~/cyberlabs` workspace → Claude/squad/sync keys
notify "workspace missing" instead of silently doing nothing. On the Cisco
MacBook the Cisco and FIAP folders are fully functional out of the box; the
Cyberlabs folder needs the workspace cloned.

### Do not write into ProfilesV3 directly

Tried, twice, does not work. The app only reads profiles at launch, and quitting it
by AppleScript registers as `last session did not properly end` — on the next launch
it restores a backup and re-imports the factory default, silently throwing away
anything written by hand. Importing is the supported path and needs no restart.

## Layout as installed

### Home — daily drivers

| | | | | |
|---|---|---|---|---|
| 🏢 Cisco *(folder)* | 🧪 Cyberlabs *(folder)* | 🎥 Streaming *(folder)* | 🎓 FIAP *(folder)* | 🎙 Mic |
| ⚡ Claude | 📷 Camera (Photo Booth) | 📸 Screen ⇧⌘5 | 🎬 Meeting | 📅 Join |
| 🌙 Focus | 📂 Outputs | 🔄 Sync | 🩺 Health | ⏯ Media |

### Cisco — work

| | | | | |
|---|---|---|---|---|
| ← Back | 💬 Webex | 🔇 Mute WX | 📷 Cam WX | 🖥 Share WX |
| 📁 SharePoint | 📧 Outlook | 📅 Join | 🎬 Meeting | 🎙 Mic |

Mute/Cam/Share drive Webex's own shortcuts (⌘⇧M / ⌘⇧V / ⌘⇧K) — if your Webex
build differs, the key is one line at the top of `bin/webex-*.sh`. The system
🎙 Mic key mutes at OS level, which every meeting app respects.

### Cyberlabs — lab routine

| | | | | |
|---|---|---|---|---|
| ← Back | ⚡ Claude | ⏪ Resume | 🚀 Run Squad | 📋 Squads |
| 📂 Outputs | 📊 Repos | 🔄 Sync | 💻 VS Code | 🖥 VPS |
| 🩺 Health | 📈 Splunk (LION) | 🌐 Meraki | ☁️ Cloudflare | |

Splunk key points at `http://lion.local:8000` — adjust in `install-profile.py`
if you reach LION another way (Tailscale name, IP…).

### Streaming — OBS / YouTube recording

| | | | | |
|---|---|---|---|---|
| ← Back | 🎥 OBS | 🔴 REC | 🎛 Stream Mode | 🎙 Mic |
| 📷 Cam Check | ▶️ YT Studio | 📺 YouTube | 📸 Screen ⇧⌘5 | 📂 Outputs |

- **REC** toggles OBS recording. Best path: `brew install obs-cmd`, enable OBS
  *Tools → WebSocket Server*, store the password in Keychain
  (`security add-generic-password -s obs-websocket -a obs -w '<pw>'`) — then the
  toggle works without stealing focus. Without obs-cmd it falls back to
  activating OBS and pressing ⇧⌘R (set that as *Start/Stop Recording* in
  OBS Settings → Hotkeys).
- **Stream Mode** closes WhatsApp/Music/Mail, mic to 80%, Focus on, opens OBS.
  Press again to undo.

### FIAP — teaching

| | | | | |
|---|---|---|---|---|
| ← Back | 🎓 Class Mode | 💬 Teams | 🖥 Share | 📷 Camera |
| 🔇 Mute | ⏺ Record | 📺 YouTube | 📚 FIAP ON | 📸 Screen ⇧⌘5 |

Share/Camera/Mute drive Teams' shortcuts (⌘⇧E / ⌘⇧O / ⌘⇧M). **Record** brings
Teams forward and reminds you of the exact clicks — Teams has no recording
shortcut and UI-scripting its menus breaks on every update, so a reliable nudge
won over a flaky automation. **Class Mode** hides desktop icons, quits WhatsApp,
turns Focus on and opens the FIAP notes; press again to restore.

Edit the `HOME` / `FOLDERS` dicts in `install-profile.py`, then `./setup.sh` again.

## Binding one key by hand

If you add a script and don't want to regenerate the profile: drag **System → Open**
onto a key, then set **App / File** to the bundle. The path must be **absolute and
wrapped in double quotes** — `"/Users/<you>/cyberlabs/scripts/streamdeck/apps/mic-toggle.app"`.
A `~` will not expand and the key will do nothing.

URLs need no script — use **System → Website**. App keystrokes — use **System → Hotkey**.

## Focus key setup (one-time, ~2 min)

macOS exposes no CLI for Focus, so `focus-toggle` drives a Shortcut you own:

1. Shortcuts app → **+** → add action **Set Focus**.
2. Set it to your Focus (e.g. Do Not Disturb) and change *Turn On* to **Toggle**.
3. Rename the shortcut exactly **`SD Toggle Focus`**.

`meeting-mode`, `class-mode` and `streaming-mode` call it too, so this one step
lights up four keys. Until it exists, those keys still work — they just skip the
Focus part and tell you why. Repeat once per machine (Shortcuts syncs via iCloud
on personal Macs; the Cisco MacBook needs it created there).

## Permissions

First press of some keys triggers a macOS prompt — grant once per machine:

- `join-next-meeting` → Calendar access (System Settings → Privacy → Calendars)
- `webex-*`, `teams-*`, `obs-record` (fallback path) → **Accessibility** for the
  bundle, so `System Events` may send the app its keystroke
- `meeting-mode`, `class-mode`, `streaming-mode` → Automation (control WhatsApp / Finder)
- notifications → allow for the `.app` bundle or Stream Deck

## Toggle state

`mic-toggle`, `meeting-mode`, `class-mode` and `streaming-mode` keep state in
`~/.cache/streamdeck-*`. Delete those files to reset a stuck toggle.
