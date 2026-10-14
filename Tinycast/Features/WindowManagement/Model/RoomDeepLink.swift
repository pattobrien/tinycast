import Foundation

/// A `tinycast://window-room/<uuid-or-name>` link.
enum RoomDeepLink: Equatable, Sendable {
    case id(UUID)
    case name(String)

    init?(url: URL) {
        guard url.scheme?.lowercased() == "tinycast", url.host()?.lowercased() == "window-room"
        else { return nil }
        let target = String(url.path(percentEncoded: false).dropFirst())
        guard !target.isEmpty else { return nil }
        self = UUID(uuidString: target).map(Self.id) ?? .name(target)
    }

    var url: URL {
        let target =
            switch self {
            case .id(let id): id.uuidString
            case .name(let name): name
            }
        return URL(string: "tinycast://window-room/")!.appending(path: target)
    }
}
