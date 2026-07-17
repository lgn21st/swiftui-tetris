import Foundation
import Darwin

public enum SocketTransportConfiguration: Equatable {
    case tcp(host: String, port: Int)
}

public final class SocketServerTransport {
    public var onReceive: ((UUID, Data) -> Void)?
    public var onDisconnect: ((UUID) -> Void)?
    public private(set) var boundPort: Int?

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
            boundPort = nil
        }
    }

    public func send(line: Data, to connectionId: UUID) {
        queue.async {
            guard let connection = self.connections[connectionId] else { return }
            connection.pendingWrite.append(line)
            connection.pendingWrite.append(0x0A)
            self.resumeWriteSourceIfNeeded(connection)
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
        while true {
            var addr = sockaddr_storage()
            var len = socklen_t(MemoryLayout<sockaddr_storage>.size)
            let fd = withUnsafeMutablePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in
                    Darwin.accept(listenerFd, ptr, &len)
                }
            }
            guard fd >= 0 else { return }
            configureConnection(fd: fd)
        }
    }

    private func configureConnection(fd: Int32) {
        setNonBlocking(fd: fd)
        var noSigPipe: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &noSigPipe, socklen_t(MemoryLayout<Int32>.size))
        let id = UUID()
        let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: queue)
        let writeSource = DispatchSource.makeWriteSource(fileDescriptor: fd, queue: queue)
        let state = ConnectionState(fd: fd, source: source, writeSource: writeSource)
        connections[id] = state
        source.setEventHandler { [weak self] in
            self?.readAvailable(connectionId: id)
        }
        source.setCancelHandler { [weak self] in
            self?.connections[id]?.source = nil
        }
        writeSource.setEventHandler { [weak self] in
            self?.flushPendingWrite(connectionId: id)
        }
        writeSource.setCancelHandler { [weak self] in
            self?.connections[id]?.writeSource = nil
        }
        source.resume()
        startIdleTimerIfNeeded()
    }

    private func readAvailable(connectionId: UUID) {
        guard let connection = connections[connectionId] else { return }
        var buffer = [UInt8](repeating: 0, count: 4096)
        while true {
            let readCount = read(connection.fd, &buffer, buffer.count)
            if readCount > 0 {
                connection.lastRead = .now()
                do {
                    let lines = try connection.framer.append(Data(buffer.prefix(readCount)))
                    for line in lines {
                        onReceive?(connectionId, line)
                    }
                } catch {
                    closeConnection(connectionId: connectionId)
                    return
                }
                continue
            }
            if readCount < 0, errno == EWOULDBLOCK || errno == EAGAIN {
                return
            }
            closeConnection(connectionId: connectionId)
            return
        }
    }

    private func resumeWriteSourceIfNeeded(_ connection: ConnectionState) {
        guard !connection.writeSourceResumed else { return }
        connection.writeSourceResumed = true
        connection.writeSource?.resume()
    }

    private func flushPendingWrite(connectionId: UUID) {
        guard let connection = connections[connectionId] else { return }

        while connection.writeOffset < connection.pendingWrite.count {
            let written = connection.pendingWrite.withUnsafeBytes { buffer -> Int in
                guard let base = buffer.baseAddress else { return 0 }
                return write(
                    connection.fd,
                    base.advanced(by: connection.writeOffset),
                    buffer.count - connection.writeOffset
                )
            }
            if written > 0 {
                connection.writeOffset += written
                continue
            }
            if written < 0, errno == EWOULDBLOCK || errno == EAGAIN {
                return
            }
            closeConnection(connectionId: connectionId)
            return
        }

        connection.pendingWrite.removeAll(keepingCapacity: true)
        connection.writeOffset = 0
        if connection.writeSourceResumed {
            connection.writeSource?.suspend()
            connection.writeSourceResumed = false
        }
    }

    private func closeConnection(connectionId: UUID) {
        guard let connection = connections[connectionId] else { return }
        connection.source?.cancel()
        connection.source = nil
        if !connection.writeSourceResumed {
            connection.writeSource?.resume()
        }
        connection.writeSource?.cancel()
        connection.writeSource = nil
        connection.writeSourceResumed = false
        close(connection.fd)
        connections.removeValue(forKey: connectionId)
        onDisconnect?(connectionId)
    }

    private func closeAllConnections() {
        let ids = Array(connections.keys)
        for id in ids {
            closeConnection(connectionId: id)
        }
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
        if bindResult != 0 {
            if errno == EADDRINUSE {
                throw SocketTransportError.addressInUse
            }
            throw SocketTransportError.bindFailed
        }

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
    var writeSource: DispatchSourceWrite?
    var writeSourceResumed: Bool
    var pendingWrite: Data
    var writeOffset: Int
    var framer: LineFramer
    var lastRead: DispatchTime

    init(fd: Int32, source: DispatchSourceRead, writeSource: DispatchSourceWrite) {
        self.fd = fd
        self.source = source
        self.writeSource = writeSource
        self.writeSourceResumed = false
        self.pendingWrite = Data()
        self.writeOffset = 0
        self.framer = LineFramer()
        self.lastRead = .now()
    }
}

public enum SocketTransportError: Error {
    case socketCreationFailed
    case addressInUse
    case bindFailed
    case listenFailed
}
