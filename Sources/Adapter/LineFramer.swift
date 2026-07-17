import Foundation

struct LineFramer {
    private var buffer = Data()
    private let maxLineBytes: Int

    init(maxLineBytes: Int = 65_536) {
        self.maxLineBytes = max(maxLineBytes, 1)
    }

    mutating func append(_ data: Data) throws -> [Data] {
        buffer.append(data)
        var lines: [Data] = []
        var lineStart = buffer.startIndex

        while let newline = buffer[lineStart...].firstIndex(of: 0x0A) {
            guard buffer.distance(from: lineStart, to: newline) <= maxLineBytes else {
                buffer.removeAll(keepingCapacity: true)
                throw LineFramerError.lineTooLong
            }
            lines.append(buffer.subdata(in: lineStart..<newline))
            lineStart = buffer.index(after: newline)
        }

        if lineStart != buffer.startIndex {
            buffer.removeSubrange(buffer.startIndex..<lineStart)
        }
        guard buffer.count <= maxLineBytes else {
            buffer.removeAll(keepingCapacity: true)
            throw LineFramerError.lineTooLong
        }

        return lines
    }
}

enum LineFramerError: Error, Equatable {
    case lineTooLong
}
