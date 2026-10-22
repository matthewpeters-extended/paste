// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Paste",
    platforms: [.macOS(.v15)],
    targets: [
        .target(name: "PasteCore"),
        .testTarget(name: "PasteCoreTests", dependencies: ["PasteCore"]),
    ]
)
