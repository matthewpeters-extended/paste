import SwiftUI

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
