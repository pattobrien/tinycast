import SwiftUI

/// A `confirmAlert` `icon`, resolved against the appearance the dialog is drawn in.
struct ExtensionAlertIcon: View {
    @Environment(\.metrics) private var metrics
    @Environment(\.isDarkAppearance) private var isDark
    let icon: RenderValue
    let assetsPath: String?

    var body: some View {
        ExtensionIconView(
            resolved: ExtensionImage.resolve(icon, assetsPath: assetsPath, isDark: isDark),
            size: metrics.size.dialogSymbol)
    }
}
