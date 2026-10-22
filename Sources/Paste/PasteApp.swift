import SwiftUI

@main
struct PasteApp: App {
    @State private var model = BindingsModel()
    @State private var permission = PermissionMonitor()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(model: model, permission: permission)
        } label: {
            Image(systemName: model.isPaused ? "pause.circle" : "doc.on.clipboard")
        }
        .menuBarExtraStyle(.window)
    }
}
