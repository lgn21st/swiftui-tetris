import Foundation

public enum AssetLocator {
    public static func repoRoot() -> URL? {
        let cwd = FileManager.default.currentDirectoryPath
        return URL(fileURLWithPath: cwd, isDirectory: true)
    }

    public static func sfxDirectory() -> URL? {
        sfxDirectory(bundle: .main, cwd: nil)
    }

    public static func sfxDirectory(bundle: Bundle = .main, cwd: String? = nil) -> URL? {
        if let resourceURL = bundle.resourceURL {
            let bundled = resourceURL.appendingPathComponent("assets/sfx", isDirectory: true)
            if FileManager.default.fileExists(atPath: bundled.path) {
                return bundled
            }
        }
        let rootURL: URL?
        if let cwd {
            rootURL = URL(fileURLWithPath: cwd, isDirectory: true)
        } else {
            rootURL = repoRoot()
        }
        guard let rootURL else { return nil }
        let url = rootURL.appendingPathComponent("assets/sfx", isDirectory: true)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
}
