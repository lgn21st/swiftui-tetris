import Foundation
import Darwin

final class SocketTestClient {
    private var fd: Int32

    private init(fd: Int32) {
        self.fd = fd
    }

    deinit {
        closeConnection()
    }

    func closeConnection() {
        guard fd >= 0 else { return }
        close(fd)
        fd = -1
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

    func send(lineData: Data) throws {
        var data = lineData
        data.append(0x0A)
        let result = data.withUnsafeBytes { buffer -> Int in
            guard let base = buffer.baseAddress else { return -1 }
            return write(fd, base, buffer.count)
        }
        if result < 0 {
            throw SocketTestError.writeFailed
        }
    }

    func readLine(timeoutMs: Int) throws -> Data? {
        let flags = fcntl(fd, F_GETFL, 0)
        _ = fcntl(fd, F_SETFL, flags | O_NONBLOCK)
        let deadline = Date().addingTimeInterval(Double(timeoutMs) / 1000.0)
        var buffer = Data()

        while Date() < deadline {
            var chunk = [UInt8](repeating: 0, count: 1024)
            let readCount = read(fd, &chunk, chunk.count)
            if readCount > 0 {
                buffer.append(contentsOf: chunk.prefix(readCount))
                if let range = buffer.firstRange(of: Data([0x0A])) {
                    return buffer.subdata(in: buffer.startIndex..<range.lowerBound)
                }
            } else if readCount == 0 {
                return nil
            } else {
                if errno != EWOULDBLOCK && errno != EAGAIN {
                    return nil
                }
            }
            usleep(5_000)
        }

        return nil
    }
}

enum SocketTestError: Error {
    case socketCreationFailed
    case connectFailed
    case writeFailed
}
