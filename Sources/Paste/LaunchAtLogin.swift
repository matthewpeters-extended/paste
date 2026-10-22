import Observation
import ServiceManagement

@MainActor
@Observable
final class LaunchAtLogin {
    private(set) var isEnabled = SMAppService.mainApp.status == .enabled
    var error: String?

    /// Turns it on the first time Paste ever runs; after that the person's choice is left alone.
    init(defaults: UserDefaults = .standard) {
        guard !defaults.bool(forKey: "hasConfiguredLaunchAtLogin") else { return }
        defaults.set(true, forKey: "hasConfiguredLaunchAtLogin")
        set(true)
    }

    func set(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
            error = nil
        } catch {
            self.error = "Couldn't change Launch at login: \(error.localizedDescription)"
        }
        isEnabled = SMAppService.mainApp.status == .enabled
    }
}
