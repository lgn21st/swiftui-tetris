import Foundation
import Darwin

final class SocketTestClient {
    private var fd: Int32
    private var readBuffer = Data()

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
        try sendAll(Data((line + "\n").utf8))
    }

    func send(lineData: Data) throws {
        var data = lineData
        data.append(0x0A)
        try sendAll(data)
    }

    func readLine(timeoutMs: Int) throws -> Data? {
        let flags = fcntl(fd, F_GETFL, 0)
        _ = fcntl(fd, F_SETFL, flags | O_NONBLOCK)
        let deadline = Date().addingTimeInterval(Double(timeoutMs) / 1000.0)
        while Date() < deadline {
            if let line = takeBufferedLine() {
                return line
            }

            var chunk = [UInt8](repeating: 0, count: 16 * 1024)
            let readCount = read(fd, &chunk, chunk.count)
            if readCount > 0 {
                readBuffer.append(contentsOf: chunk.prefix(readCount))
                continue
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

    private func takeBufferedLine() -> Data? {
        guard let newline = readBuffer.firstIndex(of: 0x0A) else { return nil }
        let line = Data(readBuffer[..<newline])
        readBuffer.removeSubrange(...newline)
        return line
    }

    private func sendAll(_ data: Data) throws {
        try data.withUnsafeBytes { buffer in
            guard let base = buffer.baseAddress else { return }
            var sent = 0
            while sent < buffer.count {
                let count = write(fd, base.advanced(by: sent), buffer.count - sent)
                if count > 0 {
                    sent += count
                } else if count < 0, errno == EWOULDBLOCK || errno == EAGAIN {
                    usleep(1_000)
                } else {
                    throw SocketTestError.writeFailed
                }
            }
        }
    }
}

enum SocketTestError: Error {
    case socketCreationFailed
    case connectFailed
    case writeFailed
}
