import PasteCore
import SwiftUI

struct PopoverView: View {
    let model: BindingsModel
    let permission: PermissionMonitor
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @Environment(\.openWindow) private var openWindow

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

            BindingsSection(model: model)

            Divider()
            Button("Settings", systemImage: "gearshape") { openSettings() }
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(width: 320)
        .containerShape(.rect(cornerRadius: 24))
    }

    private func openSettings() {
        NSApp.keyWindow?.close()   // dismiss the popover
        openWindow(id: "settings")
        NSApp.activate()
    }
}
