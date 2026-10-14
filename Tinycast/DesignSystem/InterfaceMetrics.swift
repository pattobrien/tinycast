import SwiftUI

/// `Theme`'s palette geometry at the user's Interface Size; `.standard` is `Theme` verbatim.
struct InterfaceMetrics: Equatable, Sendable {
    static let standard = InterfaceMetrics(scale: 1)

    let scale: CGFloat
    let textScale: CGFloat
    let chrome: Chrome
    /// Final points, so an override is never scaled again.
    let overrides: [InterfaceToken: CGFloat]

    init(
        scale: CGFloat, textScale: CGFloat, chrome: Chrome,
        overrides: [InterfaceToken: CGFloat] = [:]
    ) {
        self.scale = scale
        self.textScale = textScale
        self.chrome = chrome
        self.overrides = overrides
    }

    var spacing: Spacing { Spacing(scale: scale, chrome: chrome, overrides: overrides) }
    var radius: Radius { Radius(scale: scale, chrome: chrome, overrides: overrides) }
    var size: Size { Size(scale: scale, chrome: chrome, overrides: overrides) }
    var typography: Typography {
        Typography(textScale: textScale, chrome: chrome, overrides: overrides)
    }

    func overriding(_ overrides: [InterfaceToken: CGFloat]) -> InterfaceMetrics {
        InterfaceMetrics(
            scale: scale, textScale: textScale, chrome: chrome,
            overrides: self.overrides.merging(overrides) { $1 })
    }

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
        let overrides: [InterfaceToken: CGFloat]

        var xxs: CGFloat { points(.xxs, Theme.Spacing.xxs) }
        var xs: CGFloat { points(.xs, Theme.Spacing.xs) }
        var sm: CGFloat { points(.sm, Theme.Spacing.sm) }
        var md: CGFloat { points(.md, Theme.Spacing.md) }
        var lg: CGFloat { points(.lg, Theme.Spacing.lg) }
        var xl: CGFloat { points(.xl, Theme.Spacing.xl) }
        var dialogInset: CGFloat { points(.dialogInset, Theme.Spacing.dialogInset) }
        var xxl: CGFloat { points(.xxl, Theme.Spacing.xxl) }
        var xxxl: CGFloat { points(.xxxl, Theme.Spacing.xxxl) }
        var sectionHeaderBottom: CGFloat { points(.sectionHeaderBottom, Theme.Spacing.sectionHeaderBottom) }
        var sectionSpacing: CGFloat { points(.sectionSpacing, Theme.Spacing.sectionSpacing) }
        var emojiSectionSpacing: CGFloat { points(.emojiSectionSpacing, Theme.Spacing.emojiSectionSpacing) }
        var rowVertical: CGFloat { overrides[.spacing(.rowVertical)] ?? chrome.rowVertical }
        var chatTranscriptBottom: CGFloat {
            points(.chatTranscriptBottom, Theme.Spacing.chatTranscriptBottom)
        }
        var chatFollowTailSlack: CGFloat { points(.chatFollowTailSlack, Theme.Spacing.chatFollowTailSlack) }
        var chatLine: CGFloat { points(.chatLine, Theme.Spacing.chatLine) }

        private func points(_ token: InterfaceToken.Spacing, _ base: CGFloat) -> CGFloat {
            overrides[.spacing(token)] ?? scaledPoints(base, scale)
        }
    }

    struct Radius: Equatable, Sendable {
        let scale: CGFloat
        let chrome: Chrome
        let overrides: [InterfaceToken: CGFloat]

        var panel: CGFloat { overrides[.radius(.panel)] ?? chrome.panelRadius }
        var row: CGFloat { overrides[.radius(.row)] ?? chrome.rowRadius }
        var formField: CGFloat { points(.formField, Theme.Radius.formField) }
        var emojiCell: CGFloat { points(.emojiCell, Theme.Radius.emojiCell) }
        var menu: CGFloat { points(.menu, Theme.Radius.menu) }
        var menuRow: CGFloat { points(.menuRow, Theme.Radius.menuRow) }
        var barControl: CGFloat { points(.barControl, Theme.Radius.barControl) }
        var menuPanel: CGFloat { points(.menuPanel, Theme.Radius.menuPanel) }
        var dialogSymbol: CGFloat { points(.dialogSymbol, Theme.Radius.dialogSymbol) }
        var dialog: CGFloat { points(.dialog, Theme.Radius.dialog) }
        var thumbnail: CGFloat { points(.thumbnail, Theme.Radius.thumbnail) }
        var attachmentChip: CGFloat { points(.attachmentChip, Theme.Radius.attachmentChip) }
        var card: CGFloat { points(.card, Theme.Radius.card) }
        var codeBlock: CGFloat { points(.codeBlock, Theme.Radius.codeBlock) }
        var keyCap: CGFloat { points(.keyCap, Theme.Radius.keyCap) }
        var tooltip: CGFloat { points(.tooltip, Theme.Radius.tooltip) }

        private func points(_ token: InterfaceToken.Radius, _ base: CGFloat) -> CGFloat {
            overrides[.radius(token)] ?? scaledPoints(base, scale)
        }
    }

    struct Size: Equatable, Sendable {
        let scale: CGFloat
        let chrome: Chrome
        let overrides: [InterfaceToken: CGFloat]

        var panelWidth: CGFloat { points(.panelWidth, Theme.Size.panelWidth) }
        var panelHeight: CGFloat { points(.panelHeight, Theme.Size.panelHeight) }
        var headerHeight: CGFloat { overrides[.size(.headerHeight)] ?? chrome.headerHeight }
        var headerIconSlot: CGFloat { overrides[.size(.headerIconSlot)] ?? chrome.headerIconSlot }
        var searchFieldMinWidth: CGFloat { points(.searchFieldMinWidth, Theme.Size.searchFieldMinWidth) }
        var headerPadding: CGFloat { overrides[.size(.headerPadding)] ?? chrome.headerPadding }
        /// Derived, not scaled: the compact bar must stay exactly the header in symmetric slack.
        var compactHeight: CGFloat {
            overrides[.size(.compactHeight)] ?? headerHeight + headerPadding * 2
        }
        var bottomBarHeight: CGFloat { overrides[.size(.bottomBarHeight)] ?? chrome.bottomBarHeight }
        var barButtonHeight: CGFloat { points(.barButtonHeight, Theme.Size.barButtonHeight) }
        var rowIcon: CGFloat { overrides[.size(.rowIcon)] ?? chrome.rowIcon }
        var resultRowIcon: CGFloat { overrides[.size(.resultRowIcon)] ?? chrome.resultRowIcon }
        var colorDot: CGFloat { points(.colorDot, Theme.Size.colorDot) }
        var calendarBarWidth: CGFloat { points(.calendarBarWidth, Theme.Size.calendarBarWidth) }
        var calendarBarHeight: CGFloat { points(.calendarBarHeight, Theme.Size.calendarBarHeight) }
        var keyCap: CGFloat { points(.keyCap, Theme.Size.keyCap) }
        var compactKeyCap: CGFloat { points(.compactKeyCap, Theme.Size.compactKeyCap) }
        var heroKeyCap: CGFloat { points(.heroKeyCap, Theme.Size.heroKeyCap) }
        var menuButton: CGFloat { points(.menuButton, Theme.Size.menuButton) }
        var checkbox: CGFloat { points(.checkbox, Theme.Size.checkbox) }

        var menuWidth: CGFloat { points(.menuWidth, Theme.Size.menuWidth) }
        var formMenuMinimumWidth: CGFloat { points(.formMenuMinimumWidth, Theme.Size.formMenuMinimumWidth) }
        var formMenuExtraRowsHeight: CGFloat {
            points(.formMenuExtraRowsHeight, Theme.Size.formMenuExtraRowsHeight)
        }
        var formFieldFocusStroke: CGFloat { points(.formFieldFocusStroke, Theme.Size.formFieldFocusStroke) }
        var actionMenuWidth: CGFloat { points(.actionMenuWidth, Theme.Size.actionMenuWidth) }
        var clipboardFilterMenuWidth: CGFloat {
            points(.clipboardFilterMenuWidth, Theme.Size.clipboardFilterMenuWidth)
        }
        var fileSearchFilterMenuWidth: CGFloat {
            points(.fileSearchFilterMenuWidth, Theme.Size.fileSearchFilterMenuWidth)
        }
        var emojiCategoryMenuWidth: CGFloat {
            points(.emojiCategoryMenuWidth, Theme.Size.emojiCategoryMenuWidth)
        }
        var menuIcon: CGFloat { points(.menuIcon, Theme.Size.menuIcon) }
        var menuBrandIcon: CGFloat { points(.menuBrandIcon, Theme.Size.menuBrandIcon) }
        var barBrandIcon: CGFloat { points(.barBrandIcon, Theme.Size.barBrandIcon) }
        var menuRowSpacing: CGFloat { points(.menuRowSpacing, Theme.Size.menuRowSpacing) }
        var menuSectionHeader: CGFloat { points(.menuSectionHeader, Theme.Size.menuSectionHeader) }
        /// Derived like `Theme`'s, so the row cap still counts whole rows at every size.
        var menuRowHeight: CGFloat {
            overrides[.size(.menuRowHeight)]
                ?? menuIcon + Spacing(scale: scale, chrome: chrome, overrides: overrides).md * 2
        }
        var menuRowsMaxHeight: CGFloat {
            overrides[.size(.menuRowsMaxHeight)]
                ?? (Theme.Size.menuVisibleRows * (menuRowHeight + menuRowSpacing)).rounded()
        }
        var clipboardListWidth: CGFloat { points(.clipboardListWidth, Theme.Size.clipboardListWidth) }
        var clipboardMediaHeight: CGFloat { points(.clipboardMediaHeight, Theme.Size.clipboardMediaHeight) }
        var clipboardPreviewPixel: CGFloat {
            points(.clipboardPreviewPixel, Theme.Size.clipboardPreviewPixel)
        }
        var emojiGridInset: CGFloat { points(.emojiGridInset, Theme.Size.emojiGridInset) }

        var markdownListMarker: CGFloat { points(.markdownListMarker, Theme.Size.markdownListMarker) }
        var markdownQuoteBar: CGFloat { points(.markdownQuoteBar, Theme.Size.markdownQuoteBar) }
        var chatMessageAction: CGFloat { points(.chatMessageAction, Theme.Size.chatMessageAction) }
        var chatSourceBadge: CGFloat { points(.chatSourceBadge, Theme.Size.chatSourceBadge) }
        var chatJumpToLatest: CGFloat { points(.chatJumpToLatest, Theme.Size.chatJumpToLatest) }
        var chatImageThumb: CGFloat { points(.chatImageThumb, Theme.Size.chatImageThumb) }
        var chatAttachmentGlyph: CGFloat { points(.chatAttachmentGlyph, Theme.Size.chatAttachmentGlyph) }
        var chatAttachmentThumb: CGFloat { points(.chatAttachmentThumb, Theme.Size.chatAttachmentThumb) }
        var chatAttachmentRemove: CGFloat { points(.chatAttachmentRemove, Theme.Size.chatAttachmentRemove) }
        var chatAttachmentInset: CGFloat { points(.chatAttachmentInset, Theme.Size.chatAttachmentInset) }

        var quickActionPanel: CGFloat { points(.quickActionPanel, Theme.Size.quickActionPanel) }
        var quickActionHeaderIcon: CGFloat {
            points(.quickActionHeaderIcon, Theme.Size.quickActionHeaderIcon)
        }
        var quickActionScrollFade: CGFloat {
            points(.quickActionScrollFade, Theme.Size.quickActionScrollFade)
        }
        var quickActionPanelBody: CGFloat { points(.quickActionPanelBody, Theme.Size.quickActionPanelBody) }
        var quickActionPanelMinBody: CGFloat {
            points(.quickActionPanelMinBody, Theme.Size.quickActionPanelMinBody)
        }

        var dialogCompactWidth: CGFloat { points(.dialogCompactWidth, Theme.Size.dialogCompactWidth) }
        var dialogWidth: CGFloat { points(.dialogWidth, Theme.Size.dialogWidth) }
        var dialogButtonHeight: CGFloat {
            let reduction = scaledPoints(Theme.Size.menuButton - Theme.Size.dialogButtonHeight, scale)
            return overrides[.size(.dialogButtonHeight)] ?? max(menuButton - reduction, 0)
        }
        var dialogSymbol: CGFloat { points(.dialogSymbol, Theme.Size.dialogSymbol) }
        var dialogSymbolContainer: CGFloat {
            points(.dialogSymbolContainer, Theme.Size.dialogSymbolContainer)
        }
        var dialogIcon: CGFloat { points(.dialogIcon, Theme.Size.dialogIcon) }
        var hudMaxWidth: CGFloat { points(.hudMaxWidth, Theme.Size.hudMaxWidth) }
        var hudWidth: CGFloat { points(.hudWidth, Theme.Size.hudWidth) }
        var hudHeight: CGFloat { points(.hudHeight, Theme.Size.hudHeight) }
        var volumeTrackHeight: CGFloat { points(.volumeTrackHeight, Theme.Size.volumeTrackHeight) }
        var volumeReadout: CGFloat { points(.volumeReadout, Theme.Size.volumeReadout) }

        private func points(_ token: InterfaceToken.Size, _ base: CGFloat) -> CGFloat {
            overrides[.size(token)] ?? scaledPoints(base, scale)
        }
    }

    /// `NSFont` is the only public source of a text style's size and face.
    struct Typography: Sendable {
        let textScale: CGFloat
        let chrome: Chrome
        let overrides: [InterfaceToken: CGFloat]

        var searchFieldSize: CGFloat {
            overrides[.typography(.searchFieldSize)] ?? chrome.searchFieldSize
        }
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
            let size = overrides[.typography(.headerIcon)] ?? chrome.headerIconSize
            return size == Theme.Typography.headerIconSize
                ? Theme.Typography.headerIcon
                : .system(size: size, weight: .medium)
        }

        var rowTitle: Font { font(.rowTitle, Theme.Typography.rowTitle, .body) }
        var rowTrailing: Font { font(.rowTrailing, Theme.Typography.rowTrailing, .callout) }
        var sectionHeader: Font {
            font(.sectionHeader, Theme.Typography.sectionHeader, .subheadline, .medium)
        }
        var panelTitle: Font { font(.panelTitle, Theme.Typography.panelTitle, .headline) }
        var calcResult: Font { font(.calcResult, Theme.Typography.calcResult, .title1) }
        var keyCap: Font { font(.keyCap, Theme.Typography.keyCap, .caption1) }
        var compactKeyCap: Font { font(.compactKeyCap, Theme.Typography.compactKeyCap, .caption2) }
        var heroKeyCap: Font { font(.heroKeyCap, Theme.Typography.heroKeyCap, .body) }
        var markdownHeading1: Font {
            font(.markdownHeading1, Theme.Typography.markdownHeading1, .title2, .semibold)
        }
        var markdownHeading2: Font {
            font(.markdownHeading2, Theme.Typography.markdownHeading2, .title3, .semibold)
        }
        var markdownHeading3: Font {
            font(.markdownHeading3, Theme.Typography.markdownHeading3, .headline)
        }
        var code: Font {
            isVerbatim(.code)
                ? Theme.Typography.code
                : .system(size: nsFont(.callout, .code).pointSize, design: .monospaced)
        }
        var inlineCode: Font { font(.inlineCode, Theme.Typography.inlineCode, .body).monospaced() }
        var bar: Font { font(.bar, Theme.Typography.bar, .callout, .medium) }
        var chip: Font { font(.chip, Theme.Typography.chip, .callout) }
        @MainActor var chipNSFont: NSFont {
            isVerbatim(.chip) ? Theme.Typography.chipNSFont : nsFont(.callout, .chip)
        }
        var disclosure: Font { font(.disclosure, Theme.Typography.disclosure, .caption1, .semibold) }
        var menuRow: Font { font(.menuRow, Theme.Typography.menuRow, .body) }
        var menuShortcut: Font { font(.menuShortcut, Theme.Typography.menuShortcut, .callout) }
        var menuIcon: Font { font(.menuIcon, Theme.Typography.menuIcon, .body) }

        /// The AppKit twin of a text style, for text an `NSTextView` draws beside SwiftUI's own.
        func textNSFont(
            _ style: NSFont.TextStyle, token: InterfaceToken.Typography? = nil,
            weight: NSFont.Weight? = nil, monospaced: Bool = false
        ) -> NSFont {
            let base = nsFont(style, token)
            if monospaced { return .monospacedSystemFont(ofSize: base.pointSize, weight: weight ?? .regular) }
            guard let weight else { return base }
            return .systemFont(ofSize: base.pointSize, weight: weight)
        }

        private func isVerbatim(_ token: InterfaceToken.Typography) -> Bool {
            textScale == 1 && overrides[.typography(token)] == nil
        }

        /// Like `Theme`'s own: the style carries the face, an explicit weight overrides it.
        private func font(
            _ token: InterfaceToken.Typography, _ base: Font, _ style: NSFont.TextStyle,
            _ weight: Font.Weight? = nil
        )
            -> Font
        {
            guard !isVerbatim(token) else { return base }
            let resized = Font(nsFont(style, token))
            return weight.map(resized.weight) ?? resized
        }

        /// Its own descriptor, so `.headline` stays Bold and `.caption2` Medium, not lighter.
        private func nsFont(
            _ style: NSFont.TextStyle, _ token: InterfaceToken.Typography? = nil
        ) -> NSFont {
            let base = NSFont.preferredFont(forTextStyle: style)
            let override = token.flatMap { overrides[.typography($0)] }
            guard textScale != 1 || override != nil else { return base }
            let size = override ?? scaledPoints(base.pointSize, textScale)
            return NSFont(descriptor: base.fontDescriptor, size: size) ?? base
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
