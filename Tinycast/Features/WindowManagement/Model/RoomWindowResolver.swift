import Foundation

/// A room window's resolve command: it prints the window's number first, and exits 0.
enum RoomWindowResolver {
    enum Failure: Error, Equatable, Sendable {
        case exited(status: Int32)
        case timedOut
        case couldNotStart
        case emptyOutput
        case unparsableOutput
    }

    static func windowID(status: Int32, output: String?) -> Result<UInt32, Failure> {
        guard status == 0 else { return .failure(.exited(status: status)) }
        let line =
            output?.split(whereSeparator: \.isNewline).first?.trimmingCharacters(in: .whitespaces)
            ?? ""
        guard !line.isEmpty else { return .failure(.emptyOutput) }
        guard let id = UInt32(line), id > 0 else { return .failure(.unparsableOutput) }
        return .success(id)
    }
}
