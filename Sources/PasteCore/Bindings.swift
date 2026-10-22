import Foundation

public struct Combo: Hashable, Codable, Sendable {
    public enum Modifier: Hashable, Codable, Sendable { case command, shift, option, control }

    public let key: String
    public let modifiers: Set<Modifier>

    public init(key: String, modifiers: Set<Modifier>) {
        self.key = key
        self.modifiers = modifiers
    }

    /// The Combo as macOS shows it, such as "⇧⌘L".
    public var displayString: String {
        let symbols: [(Modifier, String)] = [(.control, "⌃"), (.option, "⌥"), (.shift, "⇧"), (.command, "⌘")]
        let prefix = symbols.filter { modifiers.contains($0.0) }.map(\.1).joined()
        return prefix + (key.count == 1 ? key.uppercased() : key.prefix(1).uppercased() + key.dropFirst())
    }

    /// Combos macOS or nearly every app already uses. Overriding one is allowed, but the UI should warn.
    public var isSystemReserved: Bool {
        modifiers == [.command] && ["a", "c", "v", "x", "z", "w", "q", "h", "m", "s", "space", "tab"].contains(key)
    }
}

public struct Binding: Equatable, Identifiable, Codable, Sendable {
    public let id: UUID
    public var label: String
    public var combo: Combo
    public var text: String
    public var isEnabled: Bool

    public init(id: UUID = UUID(), label: String, combo: Combo, text: String, isEnabled: Bool = true) {
        self.id = id
        self.label = label
        self.combo = combo
        self.text = text
        self.isEnabled = isEnabled
    }
}

public enum BindingsError: Error, Equatable, Sendable {
    case duplicateCombo
}

public struct Bindings: Sendable {
    public var isPaused = false

    public private(set) var all: [Binding] = []
    private var store: (any BindingStore)?

    public init() {}

    public init(store: any BindingStore) throws {
        self.store = store
        self.all = try store.load()
    }

    public mutating func add(_ binding: Binding) throws {
        guard !all.contains(where: { $0.combo == binding.combo }) else {
            throw BindingsError.duplicateCombo
        }
        all.append(binding)
        try store?.save(all)
    }

    public mutating func update(_ binding: Binding) throws {
        guard let index = all.firstIndex(where: { $0.id == binding.id }) else { return }
        guard !all.contains(where: { $0.id != binding.id && $0.combo == binding.combo }) else {
            throw BindingsError.duplicateCombo
        }
        all[index] = binding
        try store?.save(all)
    }

    public mutating func remove(id: Binding.ID) throws {
        all.removeAll { $0.id == id }
        try store?.save(all)
    }

    public func text(for combo: Combo) -> String? {
        guard !isPaused else { return nil }
        return all.first { $0.combo == combo && $0.isEnabled }?.text
    }
}
