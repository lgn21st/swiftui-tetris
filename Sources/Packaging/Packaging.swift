import Foundation

public enum Packaging {
    public static func infoPlist(
        bundleID: String,
        name: String,
        execName: String,
        version: String,
        build: String
    ) -> String {
        let escapedName = name.replacingOccurrences(of: "&", with: "&amp;")
        let escapedExec = execName.replacingOccurrences(of: "&", with: "&amp;")
        let escapedID = bundleID.replacingOccurrences(of: "&", with: "&amp;")
        let escapedVersion = version.replacingOccurrences(of: "&", with: "&amp;")
        let escapedBuild = build.replacingOccurrences(of: "&", with: "&amp;")

        return """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
        <plist version=\"1.0\">
        <dict>
            <key>CFBundleName</key>
            <string>\(escapedName)</string>
            <key>CFBundleDisplayName</key>
            <string>\(escapedName)</string>
            <key>CFBundleIdentifier</key>
            <string>\(escapedID)</string>
            <key>CFBundleExecutable</key>
            <string>\(escapedExec)</string>
            <key>CFBundleShortVersionString</key>
            <string>\(escapedVersion)</string>
            <key>CFBundleVersion</key>
            <string>\(escapedBuild)</string>
            <key>CFBundlePackageType</key>
            <string>APPL</string>
            <key>LSMinimumSystemVersion</key>
            <string>13.0</string>
        </dict>
        </plist>
        """
    }

    public static func createAppBundle(
        binaryPath: URL,
        outputBundlePath: URL,
        bundleID: String,
        name: String,
        version: String,
        build: String
    ) throws {
        let fileManager = FileManager.default
        let contentsURL = outputBundlePath.appendingPathComponent("Contents", isDirectory: true)
        let macosURL = contentsURL.appendingPathComponent("MacOS", isDirectory: true)
        try fileManager.createDirectory(at: macosURL, withIntermediateDirectories: true)

        let execName = binaryPath.lastPathComponent
        let plist = infoPlist(bundleID: bundleID, name: name, execName: execName, version: version, build: build)
        let plistURL = contentsURL.appendingPathComponent("Info.plist")
        try plist.write(to: plistURL, atomically: true, encoding: .utf8)

        let bundledBinaryURL = macosURL.appendingPathComponent(execName)
        if fileManager.fileExists(atPath: bundledBinaryURL.path) {
            try fileManager.removeItem(at: bundledBinaryURL)
        }
        try fileManager.copyItem(at: binaryPath, to: bundledBinaryURL)

        var attributes = try fileManager.attributesOfItem(atPath: bundledBinaryURL.path)
        if let permissions = attributes[.posixPermissions] as? NSNumber {
            let value = permissions.intValue | 0o111
            attributes[.posixPermissions] = NSNumber(value: value)
            try fileManager.setAttributes(attributes, ofItemAtPath: bundledBinaryURL.path)
        }
    }
}
