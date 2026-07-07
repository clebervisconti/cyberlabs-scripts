#!/bin/bash

# Get the directory where this setup script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=== Clip2md Setup & Apple Shortcut Installer ==="

# 1. Compile get_html.swift if needed
echo "Checking Swift clipboard helper..."
if [ ! -f "$DIR/get_html" ] || [ "$DIR/get_html.swift" -nt "$DIR/get_html" ]; then
    echo "Compiling Swift helper..."
    swiftc "$DIR/get_html.swift" -o "$DIR/get_html"
    if [ $? -ne 0 ]; then
        echo "Error: Swift compilation failed."
        exit 1
    fi
    echo "Swift helper compiled successfully."
else
    echo "Swift helper is already compiled."
fi

# Ensure all scripts have execution permissions
chmod +x "$DIR/save_markdown.sh"
chmod +x "$DIR/html_to_markdown.py"
chmod +x "$DIR/generate_shortcut.py"

# Define shortcut paths
SCRIPT_PATH="$DIR/save_markdown.sh"
UNSIGNED_SHORTCUT="$DIR/Clip2md_unsigned.shortcut"
SIGNED_SHORTCUT="$DIR/Clip2md.shortcut"

# 2. Generate the unsigned shortcut binary plist
echo "Generating Shortcut plist..."
python3 "$DIR/generate_shortcut.py" "$SCRIPT_PATH" "$UNSIGNED_SHORTCUT"
if [ $? -ne 0 ]; then
    echo "Error: Failed to generate unsigned shortcut file."
    exit 1
fi

# 3. Sign the shortcut
echo "Signing the Shortcut..."
shortcuts sign --mode anyone --input "$UNSIGNED_SHORTCUT" --output "$SIGNED_SHORTCUT"
if [ $? -ne 0 ]; then
    echo "Error: Failed to sign shortcut file."
    rm -f "$UNSIGNED_SHORTCUT"
    exit 1
fi

# Clean up the temporary unsigned shortcut file
rm -f "$UNSIGNED_SHORTCUT"

# 4. Import the signed shortcut into Apple Shortcuts
echo "Opening the Shortcut for import..."
echo "------------------------------------------------------------"
echo "IMPORTANT: The Shortcuts app will open shortly."
echo "Please click 'Add Shortcut' in the dialog window to complete."
echo "------------------------------------------------------------"
open "$SIGNED_SHORTCUT"

echo "Setup script completed. Keep Clip2md.shortcut as a backup."
