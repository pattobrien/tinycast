import Foundation

struct ExtensionAlert: Sendable, Equatable {
    let title: String
    let message: String?
    let primaryTitle: String
    let dismissTitle: String
    let isDestructive: Bool
    let icon: RenderValue?
    let remembersChoice: Bool

    init(payload: [String: RenderValue]) {
        title = payload["title"]?.stringValue ?? "Are you sure?"
        message = payload["message"]?.stringValue
        let primary = payload["primaryAction"]?.objectValue
        primaryTitle = primary?["title"]?.stringValue ?? "Confirm"
        dismissTitle = payload["dismissAction"]?.objectValue?["title"]?.stringValue ?? "Cancel"
        isDestructive = primary?["style"]?.stringValue == "destructive"
        icon = payload["icon"]
        remembersChoice = payload["rememberUserChoice"]?.boolValue ?? false
    }

    /// The only way to mint a key, so no answer is recorded for an alert that never offered one.
    func rememberKey(command: ExtensionCommandRef) -> ExtensionAlertKey? {
        guard remembersChoice else { return nil }
        return ExtensionAlertKey(command: command, alert: self)
    }
}

/// "The same alert": one command and the words the user read; icon and styles are not identity.
struct ExtensionAlertKey: Hashable, Sendable {
    let command: ExtensionCommandRef
    /// Sorted-keys JSON of the wording, so no title or message can forge another alert's key.
    let identity: String

    private struct Wording: Codable {
        let title: String
        let message: String?
        let primaryTitle: String
        let dismissTitle: String
    }

    fileprivate init?(command: ExtensionCommandRef, alert: ExtensionAlert) {
        let wording = Wording(
            title: alert.title, message: alert.message, primaryTitle: alert.primaryTitle,
            dismissTitle: alert.dismissTitle)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(wording),
            let identity = String(data: data, encoding: .utf8)
        else { return nil }
        self.command = command
        self.identity = identity
    }
}
