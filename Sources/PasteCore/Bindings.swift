public struct Combo: Hashable, Sendable {
    public enum Modifier: Hashable, Sendable { case command, shift, option, control }

    public let key: String
    public let modifiers: Set<Modifier>

    public init(key: String, modifiers: Set<Modifier>) {
        self.key = key
        self.modifiers = modifiers
    }
}

public struct Binding: Sendable {
    public var label: String
    public var combo: Combo
    public var text: String
    public var isEnabled: Bool

    public init(label: String, combo: Combo, text: String, isEnabled: Bool = true) {
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

    private var all: [Binding] = []

    public init() {}

    public mutating func add(_ binding: Binding) throws {
        guard !all.contains(where: { $0.combo == binding.combo }) else {
            throw BindingsError.duplicateCombo
        }
        all.append(binding)
    }

    public func text(for combo: Combo) -> String? {
        guard !isPaused else { return nil }
        return all.first { $0.combo == combo && $0.isEnabled }?.text
    }
}
