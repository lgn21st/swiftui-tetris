import Foundation

public enum AssetLocator {
    public static func repoRoot() -> URL? {
        let cwd = FileManager.default.currentDirectoryPath
        return URL(fileURLWithPath: cwd, isDirectory: true)
    }

    public static func sfxDirectory() -> URL? {
        guard let root = repoRoot() else { return nil }
        let url = root.appendingPathComponent("assets/sfx", isDirectory: true)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
}
