import CoreGraphics

/// Types text into the focused app as characters. Never touches the clipboard.
enum Typer {
    /// Marks events Paste posted itself, so the listener never reacts to them.
    static let marker: Int64 = 0x50415354   // "PAST"

    static func type(_ text: String) {
        let source = CGEventSource(stateID: .privateState)
        source?.userData = marker
        let units = Array(text.utf16)
        // Unicode strings on a key event are limited to about 20 UTF-16 units, so send in chunks.
        var start = 0
        while start < units.count {
            var end = min(start + 16, units.count)
            // Don't split a surrogate pair across chunks.
            if end < units.count, UTF16.isLeadSurrogate(units[end - 1]) { end -= 1 }
            post(Array(units[start..<end]), source: source)
            start = end
        }
    }

    private static func post(_ chunk: [UniChar], source: CGEventSource?) {
        for isDown in [true, false] {
            guard let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: isDown) else { continue }
            event.flags = []   // the Combo's modifier keys may still be held; don't let them turn this into a shortcut
            event.keyboardSetUnicodeString(stringLength: chunk.count, unicodeString: chunk)
            event.post(tap: .cgSessionEventTap)
        }
    }
}
