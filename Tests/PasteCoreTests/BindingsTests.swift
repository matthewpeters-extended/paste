import Testing
@testable import PasteCore

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
