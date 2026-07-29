#!/usr/bin/env python3
"""Write the Cyberlabs key layout into the Stream Deck's Default Profile.

The Stream Deck app holds profiles in memory and flushes them on quit, so it must
not be running while this writes. `install-profile.sh` handles backup, quit, write
and relaunch — prefer that over calling this directly.

Format details the app is strict about — get one wrong and it silently discards the
whole profile directory on launch and regenerates the factory default:
  * every Controller needs "Type": "Keypad"
  * Pages.Default must point at a separate blank page ({"Actions": null}) that is
    NOT listed in Pages.Pages
  * folder / multimedia / hotkey actions carry a "Plugin" block; open / website /
    backtoparent do not
  * system.open stores the path WITH literal surrounding double quotes, absolute,
    no tilde:  "\"/Users/me/x.app\""  — system.website stores the URL bare
  * the active profile UUID is pinned per device in
    ~/Library/Preferences/com.elgato.StreamDeck.plist (ESDProfilesPreferred), so
    this reuses the existing .sdProfile directory rather than making a new one
"""
import json
import shutil
import sys
import tempfile
import uuid
import zipfile
from pathlib import Path

APPS = Path(__file__).resolve().parent / "apps"

# ─── action builders ────────────────────────────────────────────────────────────

def _shell(uuid_, name, settings, title="", plugin=None):
    action = {
        "ActionID": str(uuid.uuid4()),
        "LinkedTitle": True,
        "Name": name,
        "Resources": None,
        "Settings": settings,
        "State": 0,
        "States": [{
            "FontFamily": "", "FontSize": 12, "FontStyle": "", "FontUnderline": False,
            "OutlineThickness": 2, "ShowTitle": True, "Title": title,
            "TitleAlignment": "bottom", "TitleColor": "#ffffff",
        }],
        "UUID": uuid_,
    }
    if plugin:
        action["Plugin"] = plugin
    return action


def app(script, title):
    """Open action pointing at one of the generated .app bundles."""
    bundle = APPS / f"{script}.app"
    if not bundle.is_dir():
        sys.exit(f"missing bundle: {bundle}\nrun ./build-apps.sh first")
    return _shell("com.elgato.streamdeck.system.open", "Open",
                  {"path": f'"{bundle}"'}, title)


def website(url, title):
    return _shell("com.elgato.streamdeck.system.website", "Website",
                  {"openInBrowser": True, "path": url}, title)


def folder(profile_uuid, title):
    return _shell("com.elgato.streamdeck.profile.openchild", "Create Folder",
                  {"ProfileUUID": profile_uuid.lower()}, title,
                  plugin={"Name": "Create Folder",
                          "UUID": "com.elgato.streamdeck.profile.openchild",
                          "Version": "1.0"})


def back():
    return {"ActionID": str(uuid.uuid4()), "LinkedTitle": True, "Name": "Parent Folder",
            "Resources": None, "Settings": {}, "State": 0, "States": [{}],
            "UUID": "com.elgato.streamdeck.profile.backtoparent"}


def media(idx, title=""):
    return _shell("com.elgato.streamdeck.system.multimedia", "Multimedia",
                  {"actionIdx": idx}, title,
                  plugin={"Name": "Multimedia",
                          "UUID": "com.elgato.streamdeck.system.multimedia",
                          "Version": "1.0"})


def _key(cmd=False, shift=False, opt=False, ctrl=False, native=-1, qt=33554431, vk=-1):
    mods = (8 if cmd else 0) + (1 if shift else 0) + (2 if ctrl else 0) + (4 if opt else 0)
    return {"KeyCmd": cmd, "KeyCtrl": ctrl, "KeyModifiers": mods, "KeyOption": opt,
            "KeyShift": shift, "NativeCode": native, "QTKeyCode": qt, "VKeyCode": vk}


def hotkey(title, **kw):
    empty = _key()
    return _shell("com.elgato.streamdeck.system.hotkey", "Hotkey",
                  {"Coalesce": True, "Hotkeys": [_key(**kw), empty, empty, empty]},
                  title,
                  plugin={"Name": "Activate a Key Command",
                          "UUID": "com.elgato.streamdeck.system.hotkey", "Version": "1.0"})


# ⇧⌘5 — macOS screenshot & recording panel. Codes copied from the stock profile.
SCREEN = dict(cmd=True, shift=True, native=21, qt=52, vk=21)

# ─── layout ────────────────────────────────────────────────────────────────────
# Keys are "col,row" on the MK.2's 5x3 grid.

CYBERLABS = uuid.uuid4()
TEACH = uuid.uuid4()
STUDIO = uuid.uuid4()
INFRA = uuid.uuid4()

HOME = {
    "0,0": folder(str(CYBERLABS), "Cyberlabs"),
    "1,0": folder(str(TEACH), "Teach"),
    "2,0": folder(str(STUDIO), "Studio"),
    "3,0": folder(str(INFRA), "Infra"),
    "4,0": app("mic-toggle", "Mic"),
    "0,1": app("claude-here", "Claude"),
    "1,1": app("squad-run", "Run Squad"),
    "2,1": app("outputs-latest", "Outputs"),
    "3,1": app("sync-now", "Sync"),
    "4,1": app("meeting-mode", "Meeting"),
    "0,2": app("focus-toggle", "Focus"),
    "1,2": hotkey("Screen", **SCREEN),
    "2,2": app("join-next-meeting", "Join"),
    "3,2": app("health-check", "Health"),
    "4,2": media(5),
}

FOLDERS = {
    CYBERLABS: ("Cyberlabs", {
        "0,0": back(),
        "1,0": app("claude-here", "Claude"),
        "2,0": app("claude-resume", "Resume"),
        "3,0": app("squad-run", "Run Squad"),
        "4,0": app("squad-list", "Squads"),
        "0,1": app("outputs-latest", "Outputs"),
        "1,1": app("repo-status", "Repos"),
        "2,1": app("sync-now", "Sync"),
        "3,1": app("workspace-code", "VS Code"),
    }),
    TEACH: ("Teach", {
        "0,0": back(),
        "1,0": app("class-mode", "Class Mode"),
        "2,0": app("focus-toggle", "Focus"),
        "3,0": app("join-next-meeting", "Join"),
        "4,0": hotkey("Screen", **SCREEN),
        "0,1": app("outputs-latest", "Outputs"),
    }),
    STUDIO: ("Studio", {
        "0,0": back(),
        "1,0": website("https://contentos.clebervisconti.com", "ContentOS"),
        "2,0": website("https://www.instagram.com", "Instagram"),
        "3,0": website("https://www.linkedin.com/feed/", "LinkedIn"),
        "4,0": website("https://studio.youtube.com", "YT Studio"),
        "0,1": app("squad-run", "Run Squad"),
        "1,1": website("https://clebervisconti.com", "Site"),
    }),
    INFRA: ("Infra", {
        "0,0": back(),
        "1,0": app("vps-ssh", "VPS"),
        "2,0": app("health-check", "Health"),
        "3,0": website("https://dashboard.meraki.com", "Meraki"),
        "4,0": website("https://dash.cloudflare.com", "Cloudflare"),
        "0,1": app("repo-status", "Repos"),
    }),
}

# ─── write ─────────────────────────────────────────────────────────────────────

def build(root, top):
    """Populate a .sdProfile directory with the layout above."""
    home_uuid = uuid.uuid4()
    blank_uuid = uuid.uuid4()  # Pages.Default template — must stay outside Pages.Pages

    def write(profile_uuid, name, actions):
        d = root / "Profiles" / str(profile_uuid).upper()
        if d.exists():
            shutil.rmtree(d)
        (d / "Images").mkdir(parents=True)
        (d / "manifest.json").write_text(json.dumps(
            {"Controllers": [{"Actions": actions, "Type": "Keypad"}],
             "Icon": "", "Name": name}))
        return len(actions or {})

    total = write(home_uuid, "", HOME)
    write(blank_uuid, "", None)
    for fid, (_name, actions) in FOLDERS.items():
        # Stock folder profiles carry Name "" — the label comes from the parent
        # key's Title. Mirroring that exactly keeps the app from rejecting them.
        total += write(fid, "", actions)

    top["Pages"] = {"Current": str(home_uuid).lower(),
                    "Default": str(blank_uuid).lower(),
                    "Pages": [str(home_uuid).lower()]}
    (root / "manifest.json").write_text(json.dumps(top))
    return total


def main():
    """Emit a .streamDeckProfile the app can import while it is running.

    Writing into ProfilesV3 directly does not work: the app must be quit to pick
    the change up, and an AppleScript quit reads as "last session did not properly
    end", which makes it restore a backup and re-import the factory default on the
    next launch — silently discarding whatever was written. Importing is the
    supported path and needs no restart.
    """
    out = Path(sys.argv[1] if len(sys.argv) > 1 else
               Path.home() / "Downloads/Cyberlabs.streamDeckProfile").expanduser()

    staging = Path(tempfile.mkdtemp())
    sd = staging / f"{str(uuid.uuid4()).upper()}.sdProfile"
    (sd / "Images").mkdir(parents=True)

    # Device UUID empty => the app binds it to whichever MK.2 is attached.
    top = {"Device": {"Model": "20GBA9901", "UUID": ""},
           "Name": "Cyberlabs", "Version": "3.0"}

    total = build(sd, top)

    if out.exists():
        out.unlink()
    out.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for p in sorted(sd.rglob("*")):
            z.write(p, p.relative_to(staging))
        for d in sorted({p.parent for p in sd.rglob("*")} | {sd, sd / "Images"}):
            name = str(d.relative_to(staging)) + "/"
            if name not in z.namelist():
                z.writestr(name, "")

    shutil.rmtree(staging, ignore_errors=True)
    print(f"{total} keys across 1 home page + {len(FOLDERS)} folders")
    print(out)


if __name__ == "__main__":
    main()
