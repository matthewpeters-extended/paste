import SwiftUI

@main
struct PasteApp: App {
    @State private var controller = AppController()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(model: controller.model, permission: controller.permission)
        } label: {
            Image(systemName: controller.model.isPaused ? "pause.circle" : "doc.on.clipboard")
        }
        .menuBarExtraStyle(.window)

        Window("Paste Settings", id: "settings") {
            SettingsView(model: controller.model, permission: controller.permission, launchAtLogin: controller.launchAtLogin)
        }
        .windowResizability(.contentSize)
    }
}
