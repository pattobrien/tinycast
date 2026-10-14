import SwiftUI

/// `Theme`'s palette geometry at the user's Interface Size; `.standard` is `Theme` verbatim.
struct InterfaceMetrics: Equatable, Sendable {
    static let standard = InterfaceMetrics(scale: 1)

    let scale: CGFloat
    let textScale: CGFloat
    let chrome: Chrome

    var spacing: Spacing { Spacing(scale: scale, chrome: chrome) }
    var radius: Radius { Radius(scale: scale, chrome: chrome) }
    var size: Size { Size(scale: scale, chrome: chrome) }
    var typography: Typography { Typography(textScale: textScale, chrome: chrome) }

    /// For a tuned length a surface owns itself, where `Theme` states no token for it.
    func scaled(_ value: CGFloat) -> CGFloat { scaledPoints(value, scale) }

    struct Chrome: Equatable, Sendable {
        let searchFieldSize: CGFloat
        let headerIconSize: CGFloat
        let headerHeight: CGFloat
        let headerPadding: CGFloat
        let headerIconSlot: CGFloat
        let resultRowIcon: CGFloat
        let rowIcon: CGFloat
        let rowVertical: CGFloat
        let rowRadius: CGFloat
        let panelRadius: CGFloat
        let bottomBarHeight: CGFloat

        static func scaled(_ scale: CGFloat) -> Chrome {
            Chrome(
                searchFieldSize: scaledPoints(Theme.Typography.searchFieldSize, scale),
                headerIconSize: scaledPoints(Theme.Typography.headerIconSize, scale),
                headerHeight: scaledPoints(Theme.Size.headerHeight, scale),
                headerPadding: scaledPoints(Theme.Size.headerPadding, scale),
                headerIconSlot: scaledPoints(Theme.Size.headerIconSlot, scale),
                resultRowIcon: scaledPoints(Theme.Size.resultRowIcon, scale),
                rowIcon: scaledPoints(Theme.Size.rowIcon, scale),
                rowVertical: scaledPoints(Theme.Spacing.rowVertical, scale),
                rowRadius: scaledPoints(Theme.Radius.row, scale),
                panelRadius: scaledPoints(Theme.Radius.panel, scale),
                bottomBarHeight: scaledPoints(Theme.Size.bottomBarHeight, scale))
        }

        static let micro = Chrome(
            searchFieldSize: Theme.Micro.searchFieldSize,
            headerIconSize: Theme.Micro.headerIconSize,
            headerHeight: Theme.Micro.headerHeight,
            headerPadding: Theme.Micro.headerPadding,
            headerIconSlot: Theme.Micro.headerIconSlot,
            resultRowIcon: Theme.Micro.resultRowIcon,
            rowIcon: Theme.Micro.rowIcon,
            rowVertical: Theme.Micro.rowVertical,
            rowRadius: Theme.Micro.rowRadius,
            panelRadius: Theme.Micro.panelRadius,
            bottomBarHeight: Theme.Micro.bottomBarHeight)
    }

    struct Spacing: Equatable, Sendable {
        let scale: CGFloat
        let chrome: Chrome

        var xxs: CGFloat { scaledPoints(Theme.Spacing.xxs, scale) }
        var xs: CGFloat { scaledPoints(Theme.Spacing.xs, scale) }
        var sm: CGFloat { scaledPoints(Theme.Spacing.sm, scale) }
        var md: CGFloat { scaledPoints(Theme.Spacing.md, scale) }
        var lg: CGFloat { scaledPoints(Theme.Spacing.lg, scale) }
        var xl: CGFloat { scaledPoints(Theme.Spacing.xl, scale) }
        var dialogInset: CGFloat { scaledPoints(Theme.Spacing.dialogInset, scale) }
        var xxl: CGFloat { scaledPoints(Theme.Spacing.xxl, scale) }
        var xxxl: CGFloat { scaledPoints(Theme.Spacing.xxxl, scale) }
        var sectionHeaderBottom: CGFloat { scaledPoints(Theme.Spacing.sectionHeaderBottom, scale) }
        var sectionSpacing: CGFloat { scaledPoints(Theme.Spacing.sectionSpacing, scale) }
        var emojiSectionSpacing: CGFloat { scaledPoints(Theme.Spacing.emojiSectionSpacing, scale) }
        var rowVertical: CGFloat { chrome.rowVertical }
        var chatTranscriptBottom: CGFloat { scaledPoints(Theme.Spacing.chatTranscriptBottom, scale) }
        var chatFollowTailSlack: CGFloat { scaledPoints(Theme.Spacing.chatFollowTailSlack, scale) }
        var chatLine: CGFloat { scaledPoints(Theme.Spacing.chatLine, scale) }
    }

    struct Radius: Equatable, Sendable {
        let scale: CGFloat
        let chrome: Chrome

        var panel: CGFloat { chrome.panelRadius }
        var row: CGFloat { chrome.rowRadius }
        var formField: CGFloat { scaledPoints(Theme.Radius.formField, scale) }
        var emojiCell: CGFloat { scaledPoints(Theme.Radius.emojiCell, scale) }
        var menu: CGFloat { scaledPoints(Theme.Radius.menu, scale) }
        var menuRow: CGFloat { scaledPoints(Theme.Radius.menuRow, scale) }
        var barControl: CGFloat { scaledPoints(Theme.Radius.barControl, scale) }
        var menuPanel: CGFloat { scaledPoints(Theme.Radius.menuPanel, scale) }
        var dialogSymbol: CGFloat { scaledPoints(Theme.Radius.dialogSymbol, scale) }
        var dialog: CGFloat { scaledPoints(Theme.Radius.dialog, scale) }
        var thumbnail: CGFloat { scaledPoints(Theme.Radius.thumbnail, scale) }
        var glyph: CGFloat { scaledPoints(Theme.Radius.glyph, scale) }
        var attachmentChip: CGFloat { scaledPoints(Theme.Radius.attachmentChip, scale) }
        var card: CGFloat { scaledPoints(Theme.Radius.card, scale) }
        var codeBlock: CGFloat { scaledPoints(Theme.Radius.codeBlock, scale) }
        var keyCap: CGFloat { scaledPoints(Theme.Radius.keyCap, scale) }
        var tooltip: CGFloat { scaledPoints(Theme.Radius.tooltip, scale) }
    }

    struct Size: Equatable, Sendable {
        let scale: CGFloat
        let chrome: Chrome

        var panelWidth: CGFloat { scaledPoints(Theme.Size.panelWidth, scale) }
        var panelHeight: CGFloat { scaledPoints(Theme.Size.panelHeight, scale) }
        var headerHeight: CGFloat { chrome.headerHeight }
        var headerIconSlot: CGFloat { chrome.headerIconSlot }
        var searchFieldMinWidth: CGFloat { scaledPoints(Theme.Size.searchFieldMinWidth, scale) }
        var headerPadding: CGFloat { chrome.headerPadding }
        /// Derived, not scaled: the compact bar must stay exactly the header in symmetric slack.
        var compactHeight: CGFloat { headerHeight + headerPadding * 2 }
        var bottomBarHeight: CGFloat { chrome.bottomBarHeight }
        var barButtonHeight: CGFloat { scaledPoints(Theme.Size.barButtonHeight, scale) }
        var rowIcon: CGFloat { chrome.rowIcon }
        var resultRowIcon: CGFloat { chrome.resultRowIcon }
        var colorDot: CGFloat { scaledPoints(Theme.Size.colorDot, scale) }
        var calendarBarWidth: CGFloat { scaledPoints(Theme.Size.calendarBarWidth, scale) }
        var calendarBarHeight: CGFloat { scaledPoints(Theme.Size.calendarBarHeight, scale) }
        var keyCap: CGFloat { scaledPoints(Theme.Size.keyCap, scale) }
        var compactKeyCap: CGFloat { scaledPoints(Theme.Size.compactKeyCap, scale) }
        var heroKeyCap: CGFloat { scaledPoints(Theme.Size.heroKeyCap, scale) }
        var menuButton: CGFloat { scaledPoints(Theme.Size.menuButton, scale) }
        var checkbox: CGFloat { scaledPoints(Theme.Size.checkbox, scale) }

        var menuWidth: CGFloat { scaledPoints(Theme.Size.menuWidth, scale) }
        var formMenuMinimumWidth: CGFloat { scaledPoints(Theme.Size.formMenuMinimumWidth, scale) }
        var formMenuExtraRowsHeight: CGFloat { scaledPoints(Theme.Size.formMenuExtraRowsHeight, scale) }
        var formFieldFocusStroke: CGFloat { scaledPoints(Theme.Size.formFieldFocusStroke, scale) }
        var actionMenuWidth: CGFloat { scaledPoints(Theme.Size.actionMenuWidth, scale) }
        var clipboardFilterMenuWidth: CGFloat { scaledPoints(Theme.Size.clipboardFilterMenuWidth, scale) }
        var fileSearchFilterMenuWidth: CGFloat { scaledPoints(Theme.Size.fileSearchFilterMenuWidth, scale) }
        var emojiCategoryMenuWidth: CGFloat { scaledPoints(Theme.Size.emojiCategoryMenuWidth, scale) }
        var menuIcon: CGFloat { scaledPoints(Theme.Size.menuIcon, scale) }
        var menuBrandIcon: CGFloat { scaledPoints(Theme.Size.menuBrandIcon, scale) }
        var barBrandIcon: CGFloat { scaledPoints(Theme.Size.barBrandIcon, scale) }
        var menuRowSpacing: CGFloat { scaledPoints(Theme.Size.menuRowSpacing, scale) }
        var menuSectionHeader: CGFloat { scaledPoints(Theme.Size.menuSectionHeader, scale) }
        /// Derived like `Theme`'s, so the row cap still counts whole rows at every size.
        var menuRowHeight: CGFloat { menuIcon + Spacing(scale: scale, chrome: chrome).md * 2 }
        var menuRowsMaxHeight: CGFloat {
            (Theme.Size.menuVisibleRows * (menuRowHeight + menuRowSpacing)).rounded()
        }
        var clipboardListWidth: CGFloat { scaledPoints(Theme.Size.clipboardListWidth, scale) }
        var clipboardMediaHeight: CGFloat { scaledPoints(Theme.Size.clipboardMediaHeight, scale) }
        var clipboardPreviewPixel: CGFloat { scaledPoints(Theme.Size.clipboardPreviewPixel, scale) }
        var emojiGridInset: CGFloat { scaledPoints(Theme.Size.emojiGridInset, scale) }
        var emojiCell: CGFloat { scaledPoints(Theme.Size.emojiCell, scale) }

        var markdownListMarker: CGFloat { scaledPoints(Theme.Size.markdownListMarker, scale) }
        var markdownQuoteBar: CGFloat { scaledPoints(Theme.Size.markdownQuoteBar, scale) }
        var chatMessageAction: CGFloat { scaledPoints(Theme.Size.chatMessageAction, scale) }
        var chatSourceBadge: CGFloat { scaledPoints(Theme.Size.chatSourceBadge, scale) }
        var chatJumpToLatest: CGFloat { scaledPoints(Theme.Size.chatJumpToLatest, scale) }
        var chatImageThumb: CGFloat { scaledPoints(Theme.Size.chatImageThumb, scale) }
        var chatAttachmentGlyph: CGFloat { scaledPoints(Theme.Size.chatAttachmentGlyph, scale) }
        var chatAttachmentThumb: CGFloat { scaledPoints(Theme.Size.chatAttachmentThumb, scale) }
        var chatAttachmentRemove: CGFloat { scaledPoints(Theme.Size.chatAttachmentRemove, scale) }
        var chatAttachmentInset: CGFloat { scaledPoints(Theme.Size.chatAttachmentInset, scale) }

        var quickActionPanel: CGFloat { scaledPoints(Theme.Size.quickActionPanel, scale) }
        var quickActionHeaderIcon: CGFloat { scaledPoints(Theme.Size.quickActionHeaderIcon, scale) }
        var quickActionScrollFade: CGFloat { scaledPoints(Theme.Size.quickActionScrollFade, scale) }
        var quickActionPanelBody: CGFloat { scaledPoints(Theme.Size.quickActionPanelBody, scale) }
        var quickActionPanelMinBody: CGFloat { scaledPoints(Theme.Size.quickActionPanelMinBody, scale) }

        var dialogCompactWidth: CGFloat { scaledPoints(Theme.Size.dialogCompactWidth, scale) }
        var dialogWidth: CGFloat { scaledPoints(Theme.Size.dialogWidth, scale) }
        var dialogButtonHeight: CGFloat {
            menuButton
                - scaledPoints(Theme.Size.menuButton - Theme.Size.dialogButtonHeight, scale)
        }
        var dialogSymbol: CGFloat { scaledPoints(Theme.Size.dialogSymbol, scale) }
        var dialogSymbolContainer: CGFloat {
            scaledPoints(Theme.Size.dialogSymbolContainer, scale)
        }
        var dialogIcon: CGFloat { scaledPoints(Theme.Size.dialogIcon, scale) }
        var hudMaxWidth: CGFloat { scaledPoints(Theme.Size.hudMaxWidth, scale) }
        var hudWidth: CGFloat { scaledPoints(Theme.Size.hudWidth, scale) }
        var hudHeight: CGFloat { scaledPoints(Theme.Size.hudHeight, scale) }
        var volumeTrackHeight: CGFloat { scaledPoints(Theme.Size.volumeTrackHeight, scale) }
        var volumeReadout: CGFloat { scaledPoints(Theme.Size.volumeReadout, scale) }
    }

    /// `NSFont` is the only public source of a text style's size and face.
    struct Typography: Sendable {
        let textScale: CGFloat
        let chrome: Chrome

        var searchFieldSize: CGFloat { chrome.searchFieldSize }
        var searchField: Font {
            searchFieldSize == Theme.Typography.searchFieldSize
                ? Theme.Typography.searchField
                : .system(size: searchFieldSize, weight: .regular)
        }
        /// Isolated because `Theme`'s twin is, not because resolving a font needs main.
        @MainActor var searchFieldNSFont: NSFont {
            searchFieldSize == Theme.Typography.searchFieldSize
                ? Theme.Typography.searchFieldNSFont
                : NSFont.systemFont(ofSize: searchFieldSize, weight: .regular)
        }
        var headerIcon: Font {
            chrome.headerIconSize == Theme.Typography.headerIconSize
                ? Theme.Typography.headerIcon
                : .system(size: chrome.headerIconSize, weight: .medium)
        }

        var rowTitle: Font { font(Theme.Typography.rowTitle, .body) }
        var rowTrailing: Font { font(Theme.Typography.rowTrailing, .callout) }
        var sectionHeader: Font { font(Theme.Typography.sectionHeader, .subheadline, .medium) }
        var panelTitle: Font { font(Theme.Typography.panelTitle, .headline) }
        var calcResult: Font { font(Theme.Typography.calcResult, .title1) }
        var keyCap: Font { font(Theme.Typography.keyCap, .caption1) }
        var compactKeyCap: Font { font(Theme.Typography.compactKeyCap, .caption2) }
        var heroKeyCap: Font { font(Theme.Typography.heroKeyCap, .body) }
        var markdownHeading1: Font { font(Theme.Typography.markdownHeading1, .title2, .semibold) }
        var markdownHeading2: Font { font(Theme.Typography.markdownHeading2, .title3, .semibold) }
        var markdownHeading3: Font { font(Theme.Typography.markdownHeading3, .headline) }
        var code: Font {
            textScale == 1
                ? Theme.Typography.code
                : .system(size: nsFont(.callout).pointSize, design: .monospaced)
        }
        var inlineCode: Font { font(Theme.Typography.inlineCode, .body).monospaced() }
        var bar: Font { font(Theme.Typography.bar, .callout, .medium) }
        var chip: Font { font(Theme.Typography.chip, .callout) }
        @MainActor var chipNSFont: NSFont { textScale == 1 ? Theme.Typography.chipNSFont : nsFont(.callout) }
        var disclosure: Font { font(Theme.Typography.disclosure, .caption1, .semibold) }
        var menuRow: Font { font(Theme.Typography.menuRow, .body) }
        var menuShortcut: Font { font(Theme.Typography.menuShortcut, .callout) }
        var menuIcon: Font { font(Theme.Typography.menuIcon, .body) }

        /// The AppKit twin of a text style, for text an `NSTextView` draws beside SwiftUI's own.
        func textNSFont(
            _ style: NSFont.TextStyle, weight: NSFont.Weight? = nil, monospaced: Bool = false
        ) -> NSFont {
            let base = nsFont(style)
            if monospaced { return .monospacedSystemFont(ofSize: base.pointSize, weight: weight ?? .regular) }
            guard let weight else { return base }
            return .systemFont(ofSize: base.pointSize, weight: weight)
        }

        /// Like `Theme`'s own: the style carries the face, an explicit weight overrides it.
        private func font(
            _ base: Font, _ style: NSFont.TextStyle, _ weight: Font.Weight? = nil
        )
            -> Font
        {
            guard textScale != 1 else { return base }
            let scaled = Font(nsFont(style))
            return weight.map(scaled.weight) ?? scaled
        }

        /// Its own descriptor, so `.headline` stays Bold and `.caption2` Medium, not lighter.
        private func nsFont(_ style: NSFont.TextStyle) -> NSFont {
            let base = NSFont.preferredFont(forTextStyle: style)
            guard textScale != 1 else { return base }
            return NSFont(descriptor: base.fontDescriptor, size: scaledPoints(base.pointSize, textScale)) ?? base
        }
    }
}

extension InterfaceMetrics {
    init(scale: CGFloat) {
        self.init(scale: scale, textScale: scale, chrome: .scaled(scale))
    }
}

/// Whole points: a fractional row pitch lands keycap edges and the dissolve mask off-pixel.
private func scaledPoints(_ value: CGFloat, _ scale: CGFloat) -> CGFloat {
    scale == 1 ? value : (value * scale).rounded()
}

extension EnvironmentValues {
    /// `.standard` by default, so a shared `DesignSystem` view outside the palette never scales.
    @Entry var metrics = InterfaceMetrics.standard
}
