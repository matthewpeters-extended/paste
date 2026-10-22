import Foundation
import Observation
import PasteCore

@MainActor
@Observable
final class BindingsModel {
    private var bindings: Bindings
    var loadError: String?

    var all: [PasteCore.Binding] { bindings.all }

    var isPaused: Bool {
        get { bindings.isPaused }
        set { bindings.isPaused = newValue }
    }

    init() {
        let url = URL.applicationSupportDirectory.appending(path: "Paste/bindings.json")
        do {
            bindings = try Bindings(store: FileBindingStore(url: url))
        } catch {
            bindings = Bindings()
            loadError = "Couldn't read your saved Bindings, so none are shown."
        }
    }

    func isDuplicate(_ combo: Combo, excluding id: PasteCore.Binding.ID?) -> Bool {
        bindings.all.contains { $0.id != id && $0.combo == combo }
    }

    func save(_ binding: PasteCore.Binding) throws {
        if bindings.all.contains(where: { $0.id == binding.id }) {
            try bindings.update(binding)
        } else {
            try bindings.add(binding)
        }
    }

    func delete(_ binding: PasteCore.Binding) throws {
        try bindings.remove(id: binding.id)
    }
}
