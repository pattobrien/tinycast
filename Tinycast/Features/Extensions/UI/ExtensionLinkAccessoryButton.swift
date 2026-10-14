import SwiftUI

/// `Form.LinkAccessory`, drawn as a header control that opens its target.
struct ExtensionLinkAccessoryButton: View {
    @Environment(\.metrics) private var metrics
    let link: ExtensionLinkAccessory
    let action: () -> Void

    var body: some View {
        BarButton(chrome: .rounded, action: action) {
            HStack(spacing: metrics.spacing.sm) {
                Text(link.text)
                    .font(metrics.typography.bar)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Image(systemName: "arrow.up.right")
                    .font(metrics.typography.disclosure)
            }
            .foregroundStyle(Theme.Colors.textSecondary)
        }
        .tooltip(link.target, edge: .bottom)
        .accessibilityHint(Text(link.target))
    }
}
