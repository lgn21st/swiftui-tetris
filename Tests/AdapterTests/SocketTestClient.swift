import Foundation
import Darwin

final class SocketTestClient {
    private let fd: Int32

    private init(fd: Int32) {
        self.fd = fd
    }

    deinit {
        close(fd)
    }

    static func tcp(host: String, port: Int) throws -> SocketTestClient {
        let fd = socket(AF_INET, SOCK_STREAM, 0)
        guard fd >= 0 else { throw SocketTestError.socketCreationFailed }

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(UInt16(port).bigEndian)
        inet_pton(AF_INET, host, &addr.sin_addr)

        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in
                Darwin.connect(fd, ptr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        guard result == 0 else {
            close(fd)
            throw SocketTestError.connectFailed
        }

        return SocketTestClient(fd: fd)
    }

    static func unix(path: String) throws -> SocketTestClient {
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw SocketTestError.socketCreationFailed }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let pathBytes = Array(path.utf8)
        guard pathBytes.count < MemoryLayout.size(ofValue: addr.sun_path) else {
            close(fd)
            throw SocketTestError.pathTooLong
        }

        withUnsafeMutablePointer(to: &addr.sun_path) { ptr in
            ptr.withMemoryRebound(to: UInt8.self, capacity: pathBytes.count) { buffer in
                for (index, byte) in pathBytes.enumerated() {
                    buffer[index] = byte
                }
            }
        }

        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in
                Darwin.connect(fd, ptr, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }

        guard result == 0 else {
            close(fd)
            throw SocketTestError.connectFailed
        }

        return SocketTestClient(fd: fd)
    }

    func send(line: String) throws {
        let data = Array((line + "\n").utf8)
        let result = data.withUnsafeBytes { buffer -> Int in
            guard let base = buffer.baseAddress else { return -1 }
            return write(fd, base, buffer.count)
        }
        if result < 0 {
            throw SocketTestError.writeFailed
        }
    }
}

enum SocketTestError: Error {
    case socketCreationFailed
    case connectFailed
    case writeFailed
    case pathTooLong
}
