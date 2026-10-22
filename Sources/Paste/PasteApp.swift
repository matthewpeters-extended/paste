import SwiftUI

@main
struct PasteApp: App {
    var body: some Scene {
        MenuBarExtra("Paste", systemImage: "doc.on.clipboard") {
            PopoverView()
        }
        .menuBarExtraStyle(.window)
    }
}
