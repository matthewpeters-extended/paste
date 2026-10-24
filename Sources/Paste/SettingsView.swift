import PasteCore
import SwiftUI

enum SettingsPage: String, CaseIterable, Identifiable {
    case bindings = "Bindings", general = "General", privacy = "Privacy", account = "Account"

    var id: Self { self }

    var icon: String {
        switch self {
        case .bindings: "keyboard"
        case .general: "gearshape"
        case .privacy: "hand.raised"
        case .account: "person.crop.circle"
        }
    }
}

struct SettingsView: View {
    let model: BindingsModel
    let permission: PermissionMonitor
    let launchAtLogin: LaunchAtLogin
    @State private var page: SettingsPage? = .bindings

    var body: some View {
        NavigationSplitView {
            List(selection: $page) {
                Section("Use") { link(.bindings) }
                Section("General") { link(.general); link(.privacy) }
                Section("About") { link(.account) }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text((page ?? .bindings).rawValue).font(.largeTitle.bold())
                    if !permission.isGranted && page != .privacy { PermissionNotice(permission: permission) }
                    content(for: page ?? .bindings)
                }
                .frame(maxWidth: 640, alignment: .leading)
                .padding(32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(minWidth: 760, minHeight: 520)
    }

    private func link(_ page: SettingsPage) -> some View {
        Label(page.rawValue, systemImage: page.icon).tag(page)
    }

    @ViewBuilder private func content(for page: SettingsPage) -> some View {
        switch page {
        case .bindings: bindingsPage
        case .general: generalPage
        case .privacy: privacyPage
        case .account: accountPage
        }
    }

    // MARK: Pages

    private var bindingsPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsGroup("Pause") {
                SettingsRow("Pause all", detail: "Stops every Binding so your keys behave normally.") {
                    Toggle("Pause all", isOn: Bindable(model).isPaused).labelsHidden().toggleStyle(.switch)
                }
            }
            if model.isPaused { PausedNotice() }

            SettingsGroup("Your Bindings", footer: "A Binding types its Text when you press its Combo in any app, as long as its switch is on and Pause all is off.") {
                BindingsSection(model: model, showsHeader: false)
                    .padding(14)
            }
        }
    }

    private var generalPage: some View {
        SettingsGroup("Startup") {
            SettingsRow("Launch Paste at login", detail: "Start Paste automatically when you log in, so your Bindings always work.") {
                Toggle("Launch Paste at login", isOn: Binding(get: { launchAtLogin.isEnabled }, set: { launchAtLogin.set($0) }))
                    .labelsHidden().toggleStyle(.switch)
            }
            if let error = launchAtLogin.error {
                Text(error).foregroundStyle(.red).font(.caption).padding(14)
            }
        }
    }

    private var privacyPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsGroup("Permission", footer: "macOS needs this so Paste can notice your key combinations in other apps and type for you.") {
                SettingsRow("Accessibility", detail: permission.isGranted ? "Allowed" : "Not allowed. Your Bindings won't fire yet.") {
                    if permission.isGranted {
                        Label("Allowed", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                    } else {
                        Button("Open Settings") { permission.requestAndOpenSettings() }
                    }
                }
            }
            SettingsGroup("Your data") {
                SettingsRow("Network", detail: "Paste never connects to the internet.") {
                    Text("Never").foregroundStyle(.secondary)
                }
                SettingsRow("Saved in", detail: model.fileURL.path(percentEncoded: false)) { EmptyView() }
            }
        }
    }

    private var accountPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsGroup("This Mac", footer: "Paste has no online account. Everything stays on this Mac.") {
                SettingsRow("Mac user") { Text(NSFullUserName()).foregroundStyle(.secondary) }
                SettingsRow("Version") {
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev")
                        .foregroundStyle(.secondary)
                }
                SettingsRow("Bindings") { Text("\(model.all.count) saved").foregroundStyle(.secondary) }
            }
            SettingsGroup("Session") {
                SettingsRow("Quit Paste", detail: "Stops Paste. Your Bindings stop working until you open it again.") {
                    Button("Quit Paste", role: .destructive) { NSApplication.shared.terminate(nil) }
                }
            }
        }
    }
}

// MARK: Building blocks

/// A titled card of rows, like a System Settings group.
struct SettingsGroup<Content: View>: View {
    let title: String
    let footer: String?
    @ViewBuilder let content: Content

    init(_ title: String, footer: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.footer = footer
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.title3.weight(.semibold))
            VStack(spacing: 0) { content }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary.opacity(0.6), in: .rect(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.separator))
            if let footer {
                Text(footer).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct SettingsRow<Trailing: View>: View {
    let title: String
    let detail: String?
    @ViewBuilder let trailing: Trailing

    init(_ title: String, detail: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.detail = detail
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                if let detail {
                    Text(detail).font(.callout).foregroundStyle(.secondary).textSelection(.enabled)
                }
            }
            Spacer(minLength: 12)
            trailing
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
