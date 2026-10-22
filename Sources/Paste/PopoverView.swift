import PasteCore
import SwiftUI

struct PopoverView: View {
    let model: BindingsModel
    let permission: PermissionMonitor
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var editing: PasteCore.Binding?
    @State private var isAdding = false
    @State private var actionError: String?

    var body: some View {
        if hasSeenWelcome {
            main
        } else {
            VStack(alignment: .leading, spacing: 12) {
                PermissionScreen(permission: permission) { hasSeenWelcome = true }
                Divider()
                Button("Quit Paste") { NSApplication.shared.terminate(nil) }
                    .frame(maxWidth: .infinity)
            }
            .padding(12)
            .frame(width: 320)
        }
    }

    private var main: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !permission.isGranted { PermissionNotice(permission: permission) }

            HStack {
                Text("Paste").font(.headline)
                Spacer()
                Toggle("Pause", isOn: Bindable(model).isPaused).toggleStyle(.switch)
            }

            if let error = model.loadError ?? actionError {
                Text(error).foregroundStyle(.red).font(.caption)
            }

            if isAdding {
                BindingEditor(model: model, original: nil) { isAdding = false }
            } else if let editing {
                BindingEditor(model: model, original: editing) { self.editing = nil }
                    .id(editing.id)
            } else {
                list
                Button("Add Binding", systemImage: "plus") { isAdding = true }
            }

            Divider()
            Button("Quit Paste") { NSApplication.shared.terminate(nil) }
                .frame(maxWidth: .infinity)
        }
        .padding(12)
        .frame(width: 320)
        .containerShape(.rect(cornerRadius: 24))
    }

    @ViewBuilder private var list: some View {
        if model.all.isEmpty {
            Text("No Bindings yet")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(.quaternary, in: ConcentricRectangle())
        } else {
            VStack(spacing: 6) {
                ForEach(model.all) { binding in
                    row(binding)
                }
            }
        }
    }

    private func row(_ binding: PasteCore.Binding) -> some View {
        HStack {
            Toggle("On", isOn: Binding(get: { binding.isEnabled }, set: { on in
                var changed = binding
                changed.isEnabled = on
                attempt { try model.save(changed) }
            })).labelsHidden().toggleStyle(.switch).controlSize(.small)
            VStack(alignment: .leading, spacing: 0) {
                Text(binding.label)
                Text(binding.combo.displayString).font(.caption).foregroundStyle(.secondary)
            }
            .opacity(binding.isEnabled ? 1 : 0.5)
            Spacer()
            Button("Edit", systemImage: "pencil") { editing = binding }
            Button("Delete", systemImage: "trash") { attempt { try model.delete(binding) } }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .padding(8)
        .background(.quaternary, in: ConcentricRectangle())
    }

    private func attempt(_ action: () throws -> Void) {
        do { try action(); actionError = nil } catch { actionError = "Couldn't save: \(error.localizedDescription)" }
    }
}
