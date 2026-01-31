import Foundation
import Darwin

public enum SocketTransportConfiguration: Equatable {
    case unix(path: String)
    case tcp(host: String, port: Int)
}

public final class SocketServerTransport {
    public var onReceive: ((UUID, Data) -> Void)?
    public var onDisconnect: ((UUID) -> Void)?
    public private(set) var boundPort: Int?
    public private(set) var boundPath: String?

    private let configuration: SocketTransportConfiguration
    private let idleTimeoutMs: Int?
    private let queue = DispatchQueue(label: "adapter.socket.transport")
    private var listenerFd: Int32 = -1
    private var listenerSource: DispatchSourceRead?
    private var idleTimer: DispatchSourceTimer?
    private var connections: [UUID: ConnectionState] = [:]

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
            closeAllConnections()
            if listenerFd >= 0 {
                close(listenerFd)
            }
            listenerFd = -1
            listenerSource?.cancel()
            listenerSource = nil
            idleTimer?.cancel()
            idleTimer = nil

            if let path = boundPath {
                unlink(path)
            }
            boundPath = nil
        }
    }

    public func send(line: Data, to connectionId: UUID) {
        queue.async {
            guard let connection = self.connections[connectionId] else { return }
            var data = line
            data.append(0x0A)
            _ = data.withUnsafeBytes { buffer in
                guard let base = buffer.baseAddress else { return -1 }
                return write(connection.fd, base, buffer.count)
            }
        }
    }

    public func broadcast(line: Data, to connectionIds: [UUID]) {
        for connectionId in connectionIds {
            send(line: line, to: connectionId)
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
        setNonBlocking(fd: fd)
        let id = UUID()
        let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: queue)
        let state = ConnectionState(fd: fd, source: source)
        connections[id] = state
        source.setEventHandler { [weak self] in
            self?.readAvailable(connectionId: id)
        }
        source.setCancelHandler { [weak self] in
            self?.connections[id]?.source = nil
        }
        source.resume()
        startIdleTimerIfNeeded()
    }

    private func readAvailable(connectionId: UUID) {
        guard let connection = connections[connectionId] else { return }
        var buffer = [UInt8](repeating: 0, count: 4096)
        let readCount = read(connection.fd, &buffer, buffer.count)
        if readCount <= 0 {
            closeConnection(connectionId: connectionId)
            return
        }

        connection.lastRead = .now()
        let data = Data(buffer.prefix(readCount))
        let lines = connection.framer.append(data)
        for line in lines {
            onReceive?(connectionId, line)
        }
    }

    private func closeConnection(connectionId: UUID) {
        guard let connection = connections.removeValue(forKey: connectionId) else { return }
        close(connection.fd)
        connection.source?.cancel()
        onDisconnect?(connectionId)
    }

    private func closeAllConnections() {
        let ids = Array(connections.keys)
        for id in ids {
            closeConnection(connectionId: id)
        }
    }

    private func setupUnixListener(path: String) throws {
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw SocketTransportError.socketCreationFailed }
        defer {
            // Only keep the fd open after a successful listen.
            if listenerFd != fd {
                close(fd)
            }
        }

        if FileManager.default.fileExists(atPath: path) {
            if canConnectUnix(path: path) {
                throw SocketTransportError.addressInUse
            }
            unlink(path)
        }

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

        listenerFd = fd
        boundPath = path
    }

    private func canConnectUnix(path: String) -> Bool {
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { return false }
        defer { close(fd) }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let pathBytes = Array(path.utf8)
        guard pathBytes.count < MemoryLayout.size(ofValue: addr.sun_path) else {
            return false
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

        return result == 0
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
        guard idleTimer == nil else { return }
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + .milliseconds(idleTimeoutMs), repeating: .milliseconds(idleTimeoutMs))
        timer.setEventHandler { [weak self] in
            guard let self else { return }
            let now = DispatchTime.now()
            let ids = Array(self.connections.keys)
            for id in ids {
                guard let connection = self.connections[id] else { continue }
                let elapsedMs = Int((now.uptimeNanoseconds - connection.lastRead.uptimeNanoseconds) / 1_000_000)
                if elapsedMs >= idleTimeoutMs {
                    self.closeConnection(connectionId: id)
                }
            }
        }
        idleTimer = timer
        timer.resume()
    }
}

private final class ConnectionState {
    let fd: Int32
    var source: DispatchSourceRead?
    var framer: LineFramer
    var lastRead: DispatchTime

    init(fd: Int32, source: DispatchSourceRead) {
        self.fd = fd
        self.source = source
        self.framer = LineFramer()
        self.lastRead = .now()
    }
}

public enum SocketTransportError: Error {
    case socketCreationFailed
    case pathTooLong
    case addressInUse
    case bindFailed
    case listenFailed
}
