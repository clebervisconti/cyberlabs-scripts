# Stream Deck — Cyberlabs key set

Scripts behind the Elgato Stream Deck MK.2 (15 keys, 5×3). Everything here is plain
shell in git, so a new machine just needs `./build-apps.sh` and a profile import.

```
lib.sh          shared helpers (root resolution, PATH, notify, Terminal launcher)
bin/*.sh        the actual scripts — edit these
build-apps.sh   regenerates apps/ ; run after adding or renaming a script
apps/*.app      thin launchers the Stream Deck binds to (generated, do not edit)
```

## Why .app bundles

The Stream Deck **Open** action passes its path to `open`. Given a `.sh` that opens your
editor; given a `.app` it runs the script with no Terminal window and no Dock bounce.
`build-apps.sh` generates one `LSUIElement` bundle per script that `exec`s the real file,
so the bundles never drift from the scripts.

## Binding a key

1. Stream Deck app → drag **System → Open** onto a key.
2. **App / File** → pick `scripts/streamdeck/apps/<name>.app`.
3. Set the title and icon.

Anything that is just a URL doesn't need a script — use the built-in **System → Website**
action. Anything that is a keystroke in an app (Zoom mute, Webex video) — use
**System → Hotkey**.

## Suggested layout

### Page 1 — HOME

| | | | | |
|---|---|---|---|---|
| 🧪 **Cyberlabs** *(folder)* | 🎓 **Teach** *(folder)* | 📣 **Studio** *(folder)* | 🛰 **Infra** *(folder)* | 🎙 `mic-toggle` |
| ⚡ `claude-here` | 🚀 `squad-run` | 📂 `outputs-latest` | 🔄 `sync-now` | 🎬 `meeting-mode` |
| 🌙 `focus-toggle` | 📸 Hotkey ⇧⌘5 | 📅 `join-next-meeting` | 🩺 `health-check` | ⏯ Multimedia |

### Cyberlabs folder

`claude-here` · `claude-resume` · `squad-run` · `squad-list` · `outputs-latest` ·
`repo-status` · `sync-now` · `workspace-code` · Website → github.com/your repos

### Teach folder (FIAP)

`class-mode` · Website → FIAP portal · Hotkey ⌥⌘P (Keynote play) · Hotkey ⇧⌘5 (record) ·
`focus-toggle` · Website → your class deck folder

### Studio folder (social)

Website → ContentOS `https://contentos.clebervisconti.com` · Website → Instagram ·
Website → LinkedIn · Website → YouTube Studio · Shortcut → `Clip2md` · `squad-run`
(pick `cv-brand-agency` / `newsletter-editorial` / `youtube-creators`)

### Infra folder

`vps-ssh` · `health-check` · Website → Meraki dashboard · Website → Splunk Cloud ·
Website → Cloudflare dashboard · `repo-status`

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
