#!/bin/bash

# Get the directory where this setup script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=== Clip2md Setup & Apple Shortcut Installer ==="

# Ensure generate_shortcut.py is executable
chmod +x "$DIR/generate_shortcut.py"

# Define shortcut paths
UNSIGNED_SHORTCUT="$DIR/Clip2md_unsigned.shortcut"
SIGNED_SHORTCUT="$DIR/Clip2md.shortcut"

# 1. Generate the unsigned shortcut binary plist
echo "Generating Shortcut plist..."
python3 "$DIR/generate_shortcut.py" "$UNSIGNED_SHORTCUT"
if [ $? -ne 0 ]; then
    echo "Error: Failed to generate unsigned shortcut file."
    exit 1
fi

# 2. Sign the shortcut
echo "Signing the Shortcut..."
shortcuts sign --mode anyone --input "$UNSIGNED_SHORTCUT" --output "$SIGNED_SHORTCUT"
if [ $? -ne 0 ]; then
    echo "Error: Failed to sign shortcut file."
    rm -f "$UNSIGNED_SHORTCUT"
    exit 1
fi

# Clean up the temporary unsigned shortcut file
rm -f "$UNSIGNED_SHORTCUT"

# 3. Import the signed shortcut into Apple Shortcuts
echo "Opening the Shortcut for import..."
echo "------------------------------------------------------------"
echo "IMPORTANT: The Shortcuts app will open shortly."
echo "Please click 'Add Shortcut' in the dialog window to complete."
echo "------------------------------------------------------------"
open "$SIGNED_SHORTCUT"

echo "Setup script completed. Keep Clip2md.shortcut as a backup."
