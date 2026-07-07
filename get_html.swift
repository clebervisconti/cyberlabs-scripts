import Cocoa

let pasteboard = NSPasteboard.general

// Attempt to read HTML content first
if let html = pasteboard.string(forType: .html) {
    print(html)
    exit(0) // HTML format available
} else if let text = pasteboard.string(forType: .string) {
    print(text)
    exit(2) // Only plain text format available
} else {
    exit(1) // No supported text content on clipboard
}
