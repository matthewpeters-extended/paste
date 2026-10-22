import AppKit
import PasteCore
import SwiftUI

/// A "press the keys you want" field. Click it to record; Escape cancels.
struct KeyRecorderField: View {
    @SwiftUI.Binding var combo: Combo?
    @State private var isRecording = false

    var body: some View {
        HStack(spacing: 8) {
            Button {
                isRecording.toggle()
            } label: {
                Text(label)
                    .foregroundStyle(combo == nil && !isRecording ? .secondary : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(isRecording ? AnyShapeStyle(.tint.opacity(0.25)) : AnyShapeStyle(.quaternary), in: ConcentricRectangle())
            }
            .buttonStyle(.plain)
            .overlay { KeyCapture(isRecording: $isRecording, combo: $combo).allowsHitTesting(false) }

            if combo != nil {
                Button("Clear") { combo = nil; isRecording = false }
            }
        }
        .containerShape(.rect(cornerRadius: 10))
    }

    private var label: String {
        if isRecording { return "Press a key with ⌘ ⌥ ⌃ or ⇧…" }
        return combo?.displayString ?? "Click to record"
    }
}

private struct KeyCapture: NSViewRepresentable {
    @SwiftUI.Binding var isRecording: Bool
    @SwiftUI.Binding var combo: Combo?

    func makeNSView(context: Context) -> CaptureView { CaptureView() }

    func updateNSView(_ view: CaptureView, context: Context) {
        view.onCombo = { captured in
            if let captured { combo = captured }
            isRecording = false
        }
        view.isRecording = isRecording
        if isRecording { view.window?.makeFirstResponder(view) }
    }
}

final class CaptureView: NSView {
    var isRecording = false
    var onCombo: (Combo?) -> Void = { _ in }

    override var acceptsFirstResponder: Bool { true }

    // Command combos arrive here before keyDown, so this is what lets Command+V and Command+C be captured.
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard isRecording else { return false }
        handle(event)
        return true
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else { return super.keyDown(with: event) }
        handle(event)
    }

    private func handle(_ event: NSEvent) {
        let modifiers = Self.modifiers(of: event)
        if event.keyCode == 53 && modifiers.isEmpty { return onCombo(nil) }   // Escape cancels
        guard !modifiers.isEmpty, let key = Self.keyName(of: event) else { return }   // a modifier is required
        onCombo(Combo(key: key, modifiers: modifiers))
    }

    private static func modifiers(of event: NSEvent) -> Set<Combo.Modifier> {
        var result: Set<Combo.Modifier> = []
        let flags = event.modifierFlags
        if flags.contains(.command) { result.insert(.command) }
        if flags.contains(.shift) { result.insert(.shift) }
        if flags.contains(.option) { result.insert(.option) }
        if flags.contains(.control) { result.insert(.control) }
        return result
    }

    private static let namedKeys: [UInt16: String] = [
        36: "return", 48: "tab", 49: "space", 51: "delete", 117: "forwarddelete",
        123: "left", 124: "right", 125: "down", 126: "up",
        115: "home", 119: "end", 116: "pageup", 121: "pagedown",
        122: "f1", 120: "f2", 99: "f3", 118: "f4", 96: "f5", 97: "f6",
        98: "f7", 100: "f8", 101: "f9", 109: "f10", 103: "f11", 111: "f12",
    ]

    private static func keyName(of event: NSEvent) -> String? {
        if let named = namedKeys[event.keyCode] { return named }
        guard let chars = event.charactersIgnoringModifiers?.lowercased(), chars.count == 1 else { return nil }
        return chars
    }
}
