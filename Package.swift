// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Paste",
    platforms: [.macOS("26.0")],
    targets: [
        .target(name: "PasteCore"),
        .executableTarget(name: "Paste", dependencies: ["PasteCore"]),
        .testTarget(name: "PasteCoreTests", dependencies: ["PasteCore"]),
    ]
)
