// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swiftui-teris",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Renderer", targets: ["Renderer"]),
        .library(name: "UI", targets: ["UI"]),
        .executable(name: "App", targets: ["App"])
    ],
    targets: [
        .target(name: "Core", path: "Sources/Core"),
        .target(name: "Renderer", dependencies: ["Core"], path: "Sources/Renderer"),
        .target(name: "UI", dependencies: ["Core", "Renderer"], path: "Sources/UI"),
        .executableTarget(name: "App", dependencies: ["UI"], path: "Sources/App"),
        .testTarget(name: "CoreTests", dependencies: ["Core"], path: "Tests/CoreTests")
    ]
)
