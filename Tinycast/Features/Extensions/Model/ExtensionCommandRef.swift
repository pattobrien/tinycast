import Foundation

struct ExtensionCommandRef: Sendable, Hashable {
    let extensionName: String
    let commandName: String

    /// The `AppEntry.id` an extension command is surfaced under.
    var entryID: String { "extension:\(extensionName)/\(commandName)" }

    init(extensionName: String, commandName: String) {
        self.extensionName = extensionName
        self.commandName = commandName
    }

    init?(entryID: String) {
        guard entryID.hasPrefix("extension:") else { return nil }
        let body = entryID.dropFirst("extension:".count)
        guard let slash = body.lastIndex(of: "/") else { return nil }
        extensionName = String(body[body.startIndex..<slash])
        commandName = String(body[body.index(after: slash)...])
    }
}
