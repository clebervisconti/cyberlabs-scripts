#!/bin/bash

# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Compile the Swift binary if it does not exist
if [ ! -f "$DIR/get_html" ]; then
    swiftc "$DIR/get_html.swift" -o "$DIR/get_html"
fi

# Run the Swift binary to get clipboard content and determine type
RAW_CONTENT=$("$DIR/get_html" 2>/dev/null)
STATUS=$?

if [ $STATUS -eq 1 ]; then
    osascript -e 'display notification "No text or HTML found on the clipboard!" with title "Clipboard to Markdown" subtitle "Operation Cancelled"'
    exit 1
elif [ $STATUS -eq 0 ]; then
    # HTML found: convert to Markdown
    MARKDOWN=$(echo "$RAW_CONTENT" | python3 "$DIR/html_to_markdown.py")
else
    # Plain text found: use as is
    MARKDOWN="$RAW_CONTENT"
fi

# Generate a default timestamped filename
DEFAULT_NAME="clipboard_$(date +%Y%m%d_%H%M%S).md"

# Open the Save As dialog using AppleScript
TARGET_FILE=$(osascript <<EOF 2>/dev/null
try
    set selectedFile to choose file name with prompt "Save Markdown File As:" default name "$DEFAULT_NAME"
    return POSIX path of selectedFile
on error
    return ""
end try
EOF
)

# If the user cancelled, exit
if [ -z "$TARGET_FILE" ]; then
    exit 0
fi

# Write content to the target file
printf "%s\n" "$MARKDOWN" > "$TARGET_FILE"

# Show a system notification that the save succeeded
osascript -e "display notification \"Saved to $(basename "$TARGET_FILE")\" with title \"Clipboard to Markdown\" subtitle \"Success\""
