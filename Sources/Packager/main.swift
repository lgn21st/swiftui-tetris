import Foundation
import Packaging

struct Arguments {
    var binaryPath: URL
    var outputPath: URL
    var bundleID: String
    var name: String
    var version: String
    var build: String
    var iconPath: URL?
    var entitlementsPath: URL?
}

func parseArgs() -> Arguments? {
    var args = CommandLine.arguments.dropFirst()
    func nextValue() -> String? {
        guard let value = args.first else { return nil }
        args = args.dropFirst()
        return value
    }

    var binaryPath: String?
    var outputPath: String?
    var bundleID: String = "com.example.swiftui-teris"
    var name: String = "SwiftUITeris"
    var version: String = "0.1.0"
    var build: String = "1"
    var iconPath: String?
    var entitlementsPath: String?

    while let arg = nextValue() {
        switch arg {
        case "--binary-path":
            binaryPath = nextValue()
        case "--output":
            outputPath = nextValue()
        case "--bundle-id":
            if let value = nextValue() { bundleID = value }
        case "--name":
            if let value = nextValue() { name = value }
        case "--version":
            if let value = nextValue() { version = value }
        case "--build":
            if let value = nextValue() { build = value }
        case "--icon-path":
            iconPath = nextValue()
        case "--entitlements":
            entitlementsPath = nextValue()
        case "--help", "-h":
            return nil
        default:
            return nil
        }
    }

    guard let binary = binaryPath, let output = outputPath else { return nil }
    return Arguments(
        binaryPath: URL(fileURLWithPath: binary),
        outputPath: URL(fileURLWithPath: output),
        bundleID: bundleID,
        name: name,
        version: version,
        build: build,
        iconPath: iconPath.map { URL(fileURLWithPath: $0) },
        entitlementsPath: entitlementsPath.map { URL(fileURLWithPath: $0) }
    )
}

func printUsage() {
    let usage = """
    Usage:
      Packager --binary-path <path> --output <path> [options]

    Options:
      --bundle-id <id>     Bundle identifier (default: com.example.swiftui-teris)
      --name <name>        App name (default: SwiftUITeris)
      --version <ver>      CFBundleShortVersionString (default: 0.1.0)
      --build <build>      CFBundleVersion (default: 1)
      --icon-path <path>   Path to .icns file (optional)
      --entitlements <path> Path to entitlements plist (optional)
    """
    print(usage)
}

guard let args = parseArgs() else {
    printUsage()
    exit(1)
}

do {
    try Packaging.createAppBundle(
        binaryPath: args.binaryPath,
        outputBundlePath: args.outputPath,
        bundleID: args.bundleID,
        name: args.name,
        version: args.version,
        build: args.build,
        iconPath: args.iconPath,
        entitlementsPath: args.entitlementsPath
    )
} catch {
    fputs("Packaging failed: \(error)\n", stderr)
    exit(1)
}
