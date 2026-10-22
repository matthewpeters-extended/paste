import SwiftUI

struct PopoverView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("No Bindings yet")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 80)
                .background(.quaternary, in: ConcentricRectangle())

            Button("Quit Paste") { NSApplication.shared.terminate(nil) }
                .frame(maxWidth: .infinity)
        }
        .padding(12)
        .frame(width: 300)
        .containerShape(.rect(cornerRadius: 24))
    }
}
