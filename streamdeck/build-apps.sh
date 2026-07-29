#!/bin/bash
# Wrap every script in bin/ as a tiny .app bundle under apps/.
#
# Why: the Stream Deck "Open" action runs a path through `open`. Handed a .sh it
# opens your editor; handed a .app it just runs, with no Terminal window and no
# bouncing Dock icon. Re-run this after adding a script — the bundles are thin
# launchers, so they never go stale against the script they point at.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
APPS="$HERE/apps"
rm -rf "$APPS"
mkdir -p "$APPS"

for script in "$HERE"/bin/*.sh; do
  name=$(basename "$script" .sh)
  bundle="$APPS/$name.app"
  mkdir -p "$bundle/Contents/MacOS"

  cat > "$bundle/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$name</string>
  <key>CFBundleIdentifier</key><string>com.cyberlabs.streamdeck.$name</string>
  <key>CFBundleExecutable</key><string>$name</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1.0</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

  cat > "$bundle/Contents/MacOS/$name" <<LAUNCHER
#!/bin/bash
exec "$script" "\$@"
LAUNCHER

  chmod +x "$bundle/Contents/MacOS/$name"
  echo "built $name.app"
done

chmod +x "$HERE"/bin/*.sh
echo
echo "Bundles in: $APPS"
