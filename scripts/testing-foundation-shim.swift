// CLT 16.x advertises this optional cross-import overlay but ships no module.
// Re-exporting both parents restores their normal cross-import behavior.
@_exported import Foundation
@_exported import Testing
