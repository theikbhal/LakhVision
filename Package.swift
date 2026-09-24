// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LakhVision",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "LakhVision",
            path: "Sources/LakhVision"
        )
    ]
)
