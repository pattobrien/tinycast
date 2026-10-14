import SwiftUI

/// A class, so the coordinator can read the tick back after the dialog resolves.
@MainActor
@Observable
final class ExtensionRememberChoice {
    var isOn = false
}

/// Raycast's `rememberUserChoice` checkbox, worded as Raycast words it.
struct ExtensionRememberChoiceToggle: View {
    @Environment(\.metrics) private var metrics
    @Bindable var state: ExtensionRememberChoice

    var body: some View {
        Toggle(isOn: $state.isOn) {
            Text("Do not show this message again")
                .font(metrics.typography.rowTitle)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .toggleStyle(.checkbox)
    }
}
