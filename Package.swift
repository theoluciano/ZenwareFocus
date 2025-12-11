// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZenwareFocus",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ZenwareFocus",
            targets: ["ZenwareFocus"]
        )
    ],
    dependencies: [
        // We'll add dependencies as needed
    ],
    targets: [
        .executableTarget(
            name: "ZenwareFocus",
            dependencies: [],
            path: "Sources/ZenwareFocus"
        )
    ]
)