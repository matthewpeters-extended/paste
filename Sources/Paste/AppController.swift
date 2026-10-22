import Foundation

/// Owns the pieces that have to exist from launch, before the popover is ever opened.
@MainActor
final class AppController {
    let model = BindingsModel()
    let permission = PermissionMonitor()
    private var listener: KeystrokeListener?

    init() {
        let listener = KeystrokeListener { [model] combo in model.text(for: combo) }
        self.listener = listener
        permission.onChange = { granted in
            if granted { listener.startIfPossible() } else { listener.stop() }
        }
        if permission.isGranted { listener.startIfPossible() }
    }
}
