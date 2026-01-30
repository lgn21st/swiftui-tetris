import Foundation
import Darwin

public enum SocketTransportConfiguration: Equatable {
    case unix(path: String)
    case tcp(host: String, port: Int)
}

public final class SocketServerTransport {
    public var onReceive: ((Data) -> Void)?
    public var onDisconnect: (() -> Void)?
    public private(set) var boundPort: Int?
    public private(set) var boundPath: String?

    private let configuration: SocketTransportConfiguration
    private let idleTimeoutMs: Int?
    private let queue = DispatchQueue(label: "adapter.socket.transport")
    private var listenerFd: Int32 = -1
    private var connectionFd: Int32 = -1
    private var listenerSource: DispatchSourceRead?
    private var connectionSource: DispatchSourceRead?
    private var idleTimer: DispatchSourceTimer?
    private var lastRead: DispatchTime = .now()
    private var framer = LineFramer()

    public init(configuration: SocketTransportConfiguration, idleTimeoutMs: Int? = nil) {
        self.configuration = configuration
        self.idleTimeoutMs = idleTimeoutMs
    }

    public func start() throws {
        try queue.sync {
            guard listenerFd == -1 else { return }
            switch configuration {
            case .unix(let path):
                try setupUnixListener(path: path)
            case .tcp(let host, let port):
                try setupTcpListener(host: host, port: port)
            }
            startListenerSource()
        }
    }

    public func stop() {
        queue.sync {
            closeConnection()
            if listenerFd >= 0 {
                close(listenerFd)
            }
            listenerFd = -1
            listenerSource?.cancel()
            listenerSource = nil
        }
    }

    public func send(line: Data) {
        queue.async {
            guard self.connectionFd >= 0 else { return }
            var data = line
            data.append(0x0A)
            _ = data.withUnsafeBytes { buffer in
                guard let base = buffer.baseAddress else { return -1 }
                return write(self.connectionFd, base, buffer.count)
            }
        }
    }

    private func startListenerSource() {
        let source = DispatchSource.makeReadSource(fileDescriptor: listenerFd, queue: queue)
        source.setEventHandler { [weak self] in
            self?.acceptConnection()
        }
        source.setCancelHandler { [weak self] in
            self?.listenerSource = nil
        }
        listenerSource = source
        source.resume()
    }

    private func acceptConnection() {
        var addr = sockaddr_storage()
        var len = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let fd = withUnsafeMutablePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in
                Darwin.accept(listenerFd, ptr, &len)
            }
        }
        guard fd >= 0 else { return }

        if connectionFd >= 0 {
            closeConnection()
        }

        connectionFd = fd
        setNonBlocking(fd: connectionFd)
        lastRead = .now()
        startConnectionSource()
        startIdleTimerIfNeeded()
    }

    private func startConnectionSource() {
        let source = DispatchSource.makeReadSource(fileDescriptor: connectionFd, queue: queue)
        source.setEventHandler { [weak self] in
            self?.readAvailable()
        }
        source.setCancelHandler { [weak self] in
            self?.connectionSource = nil
        }
        connectionSource = source
        source.resume()
    }

    private func readAvailable() {
        var buffer = [UInt8](repeating: 0, count: 4096)
        let readCount = read(connectionFd, &buffer, buffer.count)
        if readCount <= 0 {
            closeConnection()
            return
        }

        lastRead = .now()
        let data = Data(buffer.prefix(readCount))
        let lines = framer.append(data)
        for line in lines {
            onReceive?(line)
        }
    }

    private func closeConnection() {
        if connectionFd >= 0 {
            close(connectionFd)
        }
        connectionFd = -1
        connectionSource?.cancel()
        connectionSource = nil
        idleTimer?.cancel()
        idleTimer = nil
        framer = LineFramer()
        onDisconnect?()
    }

    private func setupUnixListener(path: String) throws {
        unlink(path)
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw SocketTransportError.socketCreationFailed }
        listenerFd = fd
        boundPath = path

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let pathBytes = Array(path.utf8)
        guard pathBytes.count < MemoryLayout.size(ofValue: addr.sun_path) else {
            throw SocketTransportError.pathTooLong
        }

        withUnsafeMutablePointer(to: &addr.sun_path) { ptr in
            ptr.withMemoryRebound(to: UInt8.self, capacity: pathBytes.count) { buffer in
                for (index, byte) in pathBytes.enumerated() {
                    buffer[index] = byte
                }
            }
        }

        let bindResult = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in
                Darwin.bind(fd, ptr, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard bindResult == 0 else { throw SocketTransportError.bindFailed }
        guard listen(fd, 8) == 0 else { throw SocketTransportError.listenFailed }
        setNonBlocking(fd: fd)
    }

    private func setupTcpListener(host: String, port: Int) throws {
        let fd = socket(AF_INET, SOCK_STREAM, 0)
        guard fd >= 0 else { throw SocketTransportError.socketCreationFailed }
        listenerFd = fd

        var value: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(MemoryLayout<Int32>.size))

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(UInt16(port).bigEndian)
        inet_pton(AF_INET, host, &addr.sin_addr)

        let bindResult = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in
                Darwin.bind(fd, ptr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        guard bindResult == 0 else { throw SocketTransportError.bindFailed }
        guard listen(fd, 8) == 0 else { throw SocketTransportError.listenFailed }
        setNonBlocking(fd: fd)

        var boundAddr = sockaddr_in()
        var len = socklen_t(MemoryLayout<sockaddr_in>.size)
        let result = withUnsafeMutablePointer(to: &boundAddr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in
                getsockname(fd, ptr, &len)
            }
        }
        if result == 0 {
            boundPort = Int(UInt16(bigEndian: boundAddr.sin_port))
        }
    }

    private func setNonBlocking(fd: Int32) {
        let flags = fcntl(fd, F_GETFL, 0)
        _ = fcntl(fd, F_SETFL, flags | O_NONBLOCK)
    }

    private func startIdleTimerIfNeeded() {
        guard let idleTimeoutMs else { return }
        idleTimer?.cancel()
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + .milliseconds(idleTimeoutMs), repeating: .milliseconds(idleTimeoutMs))
        timer.setEventHandler { [weak self] in
            guard let self else { return }
            let elapsedMs = Int((DispatchTime.now().uptimeNanoseconds - self.lastRead.uptimeNanoseconds) / 1_000_000)
            if elapsedMs >= idleTimeoutMs {
                self.closeConnection()
            }
        }
        idleTimer = timer
        timer.resume()
    }
}

public enum SocketTransportError: Error {
    case socketCreationFailed
    case pathTooLong
    case bindFailed
    case listenFailed
}
