// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swiftui-teris",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Renderer", targets: ["Renderer"]),
        .library(name: "UI", targets: ["UI"]),
        .library(name: "Packaging", targets: ["Packaging"]),
        .executable(name: "App", targets: ["App"]),
        .executable(name: "Packager", targets: ["Packager"])
    ],
    targets: [
        .target(name: "Core", path: "Sources/Core"),
        .target(name: "Renderer", dependencies: ["Core"], path: "Sources/Renderer"),
        .target(name: "UI", dependencies: ["Core", "Renderer"], path: "Sources/UI"),
        .target(name: "Packaging", path: "Sources/Packaging"),
        .executableTarget(name: "App", dependencies: ["UI"], path: "Sources/App"),
        .executableTarget(name: "Packager", dependencies: ["Packaging"], path: "Sources/Packager"),
        .testTarget(name: "CoreTests", dependencies: ["Core"], path: "Tests/CoreTests"),
        .testTarget(name: "RendererTests", dependencies: ["Renderer", "Core"], path: "Tests/RendererTests"),
        .testTarget(name: "PackagingTests", dependencies: ["Packaging"], path: "Tests/PackagingTests"),
        .testTarget(name: "UIIntegrationTests", dependencies: ["UI", "Core"], path: "Tests/UIIntegrationTests")
    ]
)
