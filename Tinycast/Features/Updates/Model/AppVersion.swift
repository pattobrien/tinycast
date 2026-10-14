import Foundation

/// A released version: `MAJOR.MINOR.PATCH`, optionally `-beta.N`, then optionally `-fork.M`.
struct AppVersion: Comparable, Hashable, Sendable, CustomStringConvertible {
    let major: Int
    let minor: Int
    let patch: Int
    /// Nil on a stable release, which outranks every prerelease of the same triple.
    let beta: Int?
    /// A fork build sorts just above the upstream version it was cut from.
    let fork: Int?

    init?(_ text: String) {
        var body = Substring(text.trimmingCharacters(in: .whitespacesAndNewlines))
        // Release tags carry a leading `v`; `CFBundleShortVersionString` never does.
        if body.first == "v" { body = body.dropFirst() }

        let halves = body.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
        let numbers = halves[0].split(separator: ".", omittingEmptySubsequences: false)
        guard numbers.count == 3,
            let major = Self.number(numbers[0]),
            let minor = Self.number(numbers[1]),
            let patch = Self.number(numbers[2])
        else { return nil }

        var labels = halves.dropFirst().flatMap {
            $0.split(separator: "-", omittingEmptySubsequences: false)
        }
        // `beta` is the only prerelease channel that ships, so anything else is unreadable.
        beta = Self.counter(named: "beta", in: &labels)
        fork = Self.counter(named: "fork", in: &labels)
        guard labels.isEmpty else { return nil }
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    var isPrerelease: Bool { beta != nil }

    var description: String {
        let triple = "\(major).\(minor).\(patch)"
        let prerelease = beta.map { "-beta.\($0)" } ?? ""
        return triple + prerelease + (fork.map { "-fork.\($0)" } ?? "")
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }
        switch (lhs.beta, rhs.beta) {
        case (nil, nil): break
        // A prerelease leads to its release, so it sorts below one and never above it.
        case (.some, nil): return true
        case (nil, .some): return false
        case (.some(let left), .some(let right)) where left != right: return left < right
        case (.some, .some): break
        }
        switch (lhs.fork, rhs.fork) {
        case (nil, nil), (.some, nil): return false
        case (nil, .some): return true
        case (.some(let left), .some(let right)): return left < right
        }
    }

    private static func counter(named name: String, in labels: inout [Substring]) -> Int? {
        guard let label = labels.first else { return nil }
        let parts = label.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 2, parts[0] == name, let count = number(parts[1]) else { return nil }
        labels.removeFirst()
        return count
    }

    /// Rejects a signed or padded field, which `Int` would silently reinterpret.
    private static func number(_ text: Substring) -> Int? {
        guard !text.isEmpty, text.allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
        return Int(text)
    }
}

extension AppVersion: Codable {
    init(from decoder: any Decoder) throws {
        let text = try decoder.singleValueContainer().decode(String.self)
        guard let parsed = AppVersion(text) else {
            throw DecodingError.dataCorruptedError(
                in: try decoder.singleValueContainer(), debugDescription: "Not a version: \(text)")
        }
        self = parsed
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
