import SwiftUI

/// Shown on first launch, before the Bindings list.
struct PermissionScreen: View {
    let permission: PermissionMonitor
    let continueAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome to Paste").font(.headline)
            Text("Paste types your saved text when you press a key combination, in any app. To notice those key presses, macOS needs you to allow Paste under **Accessibility**.")
            Text("Paste never uses the network. Your Bindings stay in a file on this Mac.")
                .font(.caption).foregroundStyle(.secondary)

            if permission.isGranted {
                Label("Permission granted", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                Button("Continue", action: continueAction).keyboardShortcut(.defaultAction)
            } else {
                Button("Open Accessibility Settings") { permission.requestAndOpenSettings() }
                    .keyboardShortcut(.defaultAction)
                Text("Turn on Paste in the list, then come back here.")
                    .font(.caption).foregroundStyle(.secondary)
                Button("Skip for now", action: continueAction).buttonStyle(.link)
            }
        }
    }
}

/// Shown at the top of the popover while the permission is missing.
struct PermissionNotice: View {
    let permission: PermissionMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Paste needs Accessibility permission, so your Bindings won't fire yet.", systemImage: "exclamationmark.triangle.fill")
                .font(.caption).foregroundStyle(.orange)
            Button("Open Accessibility Settings") { permission.requestAndOpenSettings() }
                .controlSize(.small)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.15), in: ConcentricRectangle())
    }
}
