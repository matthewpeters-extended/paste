import PasteCore
import SwiftUI

struct SettingsView: View {
    let model: BindingsModel
    let permission: PermissionMonitor
    let launchAtLogin: LaunchAtLogin

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !permission.isGranted { PermissionNotice(permission: permission) }

                BindingsSection(model: model, title: "Bindings")

                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("General").font(.headline)
                    Toggle("Launch Paste at login", isOn: Binding(get: { launchAtLogin.isEnabled }, set: { launchAtLogin.set($0) }))
                    if let error = launchAtLogin.error {
                        Text(error).foregroundStyle(.red).font(.caption)
                    }
                }

                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Account").font(.headline)
                    Text("Paste has no online account. Everything stays on this Mac.")
                        .font(.caption).foregroundStyle(.secondary)
                    info("Version", version)
                    info("Mac user", NSFullUserName())
                    info("Bindings", "\(model.all.count) saved")
                    info("Saved in", model.fileURL.path(percentEncoded: false))
                    info("Accessibility", permission.isGranted ? "Allowed" : "Not allowed")
                }

                Divider()
                Button("Quit Paste", role: .destructive) { NSApplication.shared.terminate(nil) }
            }
            .padding(20)
        }
        .frame(width: 460, height: 560)
    }

    private func info(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label).foregroundStyle(.secondary).frame(width: 100, alignment: .leading)
            Text(value).textSelection(.enabled)
        }
        .font(.callout)
    }
}
