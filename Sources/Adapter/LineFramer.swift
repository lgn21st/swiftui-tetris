import Foundation

struct LineFramer {
    private var buffer = Data()

    mutating func append(_ data: Data) -> [Data] {
        buffer.append(data)
        var lines: [Data] = []

        while let range = buffer.firstRange(of: Data([0x0A])) {
            let line = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
            lines.append(line)
            buffer.removeSubrange(buffer.startIndex...range.lowerBound)
        }

        return lines
    }
}
