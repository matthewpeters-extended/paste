import Foundation
import Testing
import PasteCore

@Test func aBoundComboReturnsItsText() throws {
    var bindings = Bindings()
    let combo = Combo(key: "l", modifiers: [.command, .shift])
    try bindings.add(Binding(label: "LinkedIn", combo: combo, text: "https://linkedin.com/in/me"))

    #expect(bindings.text(for: combo) == "https://linkedin.com/in/me")
}

@Test func aSwitchedOffBindingReturnsNothing() throws {
    var bindings = Bindings()
    let combo = Combo(key: "v", modifiers: [.command])
    try bindings.add(Binding(label: "Postal code", combo: combo, text: "M5V 2T6", isEnabled: false))

    #expect(bindings.text(for: combo) == nil)
}

@Test func whilePausedEveryComboReturnsNothing() throws {
    var bindings = Bindings()
    let a = Combo(key: "v", modifiers: [.command])
    let b = Combo(key: "l", modifiers: [.command, .shift])
    try bindings.add(Binding(label: "A", combo: a, text: "one"))
    try bindings.add(Binding(label: "B", combo: b, text: "two"))

    bindings.isPaused = true

    #expect(bindings.text(for: a) == nil)
    #expect(bindings.text(for: b) == nil)

    bindings.isPaused = false

    #expect(bindings.text(for: a) == "one")
}

@Test func aDuplicateComboIsRejected() throws {
    var bindings = Bindings()
    let combo = Combo(key: "v", modifiers: [.command])
    try bindings.add(Binding(label: "First", combo: combo, text: "one"))

    #expect(throws: BindingsError.duplicateCombo) {
        try bindings.add(Binding(label: "Second", combo: combo, text: "two"))
    }
    #expect(bindings.text(for: combo) == "one")
}

@Test func bindingsSurviveASaveAndReload() throws {
    let store = InMemoryBindingStore()
    let combo = Combo(key: "l", modifiers: [.command, .shift])

    var first = try Bindings(store: store)
    try first.add(Binding(label: "LinkedIn", combo: combo, text: "https://linkedin.com/in/me", isEnabled: false))

    let reloaded = try Bindings(store: store)

    #expect(reloaded.all == [Binding(label: "LinkedIn", combo: combo, text: "https://linkedin.com/in/me", isEnabled: false)])
}

@Test func theFileBackedStoreWritesAndReadsOneLocalFile() throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    let file = dir.appendingPathComponent("bindings.json")
    let combo = Combo(key: "e", modifiers: [.command, .option])

    var first = try Bindings(store: FileBindingStore(url: file))
    try first.add(Binding(label: "Email", combo: combo, text: "me@example.com"))

    let reloaded = try Bindings(store: FileBindingStore(url: file))

    #expect(reloaded.text(for: combo) == "me@example.com")
    #expect(try FileManager.default.contentsOfDirectory(atPath: dir.path) == ["bindings.json"])
}

@Test func aMissingFileLoadsAsNoBindings() throws {
    let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("bindings.json")

    #expect(try Bindings(store: FileBindingStore(url: file)).all.isEmpty)
}

@Test func aSystemReservedComboIsFlaggedButStillAllowed() throws {
    let paste = Combo(key: "v", modifiers: [.command])
    let copy = Combo(key: "c", modifiers: [.command])
    let linkedIn = Combo(key: "l", modifiers: [.command, .shift])

    #expect(paste.isSystemReserved)
    #expect(copy.isSystemReserved)
    #expect(!linkedIn.isSystemReserved)

    var bindings = Bindings()
    try bindings.add(Binding(label: "Postal code", combo: paste, text: "M5V 2T6"))

    #expect(bindings.text(for: paste) == "M5V 2T6")
}
