import Foundation

public enum Packaging {
    public static func infoPlist(
        bundleID: String,
        name: String,
        execName: String,
        version: String,
        build: String,
        iconFileName: String? = nil
    ) -> String {
        let escapedName = name.replacingOccurrences(of: "&", with: "&amp;")
        let escapedExec = execName.replacingOccurrences(of: "&", with: "&amp;")
        let escapedID = bundleID.replacingOccurrences(of: "&", with: "&amp;")
        let escapedVersion = version.replacingOccurrences(of: "&", with: "&amp;")
        let escapedBuild = build.replacingOccurrences(of: "&", with: "&amp;")

        var iconEntry = ""
        if let iconFileName {
            let escapedIcon = iconFileName.replacingOccurrences(of: "&", with: "&amp;")
            iconEntry = "\n    <key>CFBundleIconFile</key>\n    <string>\(escapedIcon)</string>"
        }

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
            <string>14.0</string>\(iconEntry)
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
        build: String,
        iconPath: URL? = nil,
        entitlementsPath: URL? = nil,
        assetsPath: URL? = nil
    ) throws {
        let fileManager = FileManager.default
        let contentsURL = outputBundlePath.appendingPathComponent("Contents", isDirectory: true)
        let macosURL = contentsURL.appendingPathComponent("MacOS", isDirectory: true)
        let resourcesURL = contentsURL.appendingPathComponent("Resources", isDirectory: true)
        try fileManager.createDirectory(at: macosURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: resourcesURL, withIntermediateDirectories: true)

        let execName = binaryPath.lastPathComponent
        let iconFileName = iconPath?.lastPathComponent
        let plist = infoPlist(
            bundleID: bundleID,
            name: name,
            execName: execName,
            version: version,
            build: build,
            iconFileName: iconFileName
        )
        let plistURL = contentsURL.appendingPathComponent("Info.plist")
        try plist.write(to: plistURL, atomically: true, encoding: .utf8)

        let bundledBinaryURL = macosURL.appendingPathComponent(execName)
        if fileManager.fileExists(atPath: bundledBinaryURL.path) {
            try fileManager.removeItem(at: bundledBinaryURL)
        }
        try fileManager.copyItem(at: binaryPath, to: bundledBinaryURL)

        if let iconPath {
            let destIconURL = resourcesURL.appendingPathComponent(iconPath.lastPathComponent)
            if fileManager.fileExists(atPath: destIconURL.path) {
                try fileManager.removeItem(at: destIconURL)
            }
            try fileManager.copyItem(at: iconPath, to: destIconURL)
        }

        if let assetsPath {
            let destAssetsURL = resourcesURL.appendingPathComponent("assets", isDirectory: true)
            if fileManager.fileExists(atPath: destAssetsURL.path) {
                try fileManager.removeItem(at: destAssetsURL)
            }
            try fileManager.createDirectory(at: destAssetsURL, withIntermediateDirectories: true)
            try copyDirectoryContents(from: assetsPath, to: destAssetsURL)
        }

        if let entitlementsPath {
            let destEntitlementsURL = contentsURL.appendingPathComponent("Entitlements.plist")
            if fileManager.fileExists(atPath: destEntitlementsURL.path) {
                try fileManager.removeItem(at: destEntitlementsURL)
            }
            try fileManager.copyItem(at: entitlementsPath, to: destEntitlementsURL)
        }

        var attributes = try fileManager.attributesOfItem(atPath: bundledBinaryURL.path)
        if let permissions = attributes[.posixPermissions] as? NSNumber {
            let value = permissions.intValue | 0o111
            attributes[.posixPermissions] = NSNumber(value: value)
            try fileManager.setAttributes(attributes, ofItemAtPath: bundledBinaryURL.path)
        }
    }

    private static func copyDirectoryContents(from source: URL, to destination: URL) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(atPath: source.path)
        for entry in contents where entry != ".DS_Store" {
            let srcURL = source.appendingPathComponent(entry)
            let destURL = destination.appendingPathComponent(entry)
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: srcURL.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    try fileManager.createDirectory(at: destURL, withIntermediateDirectories: true)
                    try copyDirectoryContents(from: srcURL, to: destURL)
                } else {
                    if fileManager.fileExists(atPath: destURL.path) {
                        try fileManager.removeItem(at: destURL)
                    }
                    try fileManager.copyItem(at: srcURL, to: destURL)
                }
            }
        }
    }
}
