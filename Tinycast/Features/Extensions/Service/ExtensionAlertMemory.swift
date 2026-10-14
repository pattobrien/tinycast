import Foundation

/// Raycast's `rememberUserChoice`: a ticked answer is replayed instead of asking again.
@MainActor
enum ExtensionAlertMemory {
    typealias Present = (ExtensionAlert, _ offersRemember: Bool) async -> (
        confirmed: Bool, remember: Bool
    )

    /// Without a command there is nowhere to keep an answer, so the alert just asks.
    static func confirm(
        _ alert: ExtensionAlert, from command: ExtensionCommandRef?,
        launchType: ExtensionLaunchType, storage: ExtensionStorage, present: Present
    ) async -> Bool {
        let key = command.flatMap(alert.rememberKey(command:))
        if let key, let answer = storage.rememberedAnswer(for: key) { return answer }
        // A background run has nobody to ask, so only an answer already given reaches it.
        guard launchType == .userInitiated else { return false }
        let answer = await present(alert, key != nil)
        if let key, answer.remember { storage.remember(answer.confirmed, for: key) }
        return answer.confirmed
    }
}
