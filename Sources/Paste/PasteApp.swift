import SwiftUI

@main
struct PasteApp: App {
    @State private var model = BindingsModel()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(model: model)
        } label: {
            Image(systemName: model.isPaused ? "pause.circle" : "doc.on.clipboard")
        }
        .menuBarExtraStyle(.window)
    }
}
