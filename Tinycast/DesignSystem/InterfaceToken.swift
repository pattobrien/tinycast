import Foundation

/// One `InterfaceMetrics` value, named by its path there; each case name is its property's name.
enum InterfaceToken: Hashable, Sendable, CaseIterable {
    case spacing(Spacing)
    case radius(Radius)
    case size(Size)
    case typography(Typography)

    enum Spacing: String, CaseIterable, Sendable {
        case xxs, xs, sm, md, lg, xl, dialogInset, xxl, xxxl, sectionHeaderBottom, sectionSpacing
        case emojiSectionSpacing, rowVertical, chatTranscriptBottom, chatFollowTailSlack, chatLine
    }

    enum Radius: String, CaseIterable, Sendable {
        case panel, row, formField, emojiCell, menu, menuRow, barControl, menuPanel, dialogSymbol
        case dialog, thumbnail, glyph, attachmentChip, card, codeBlock, keyCap, tooltip
    }

    enum Size: String, CaseIterable, Sendable {
        case panelWidth, panelHeight, headerHeight, headerIconSlot, searchFieldMinWidth
        case headerPadding, compactHeight, bottomBarHeight, barButtonHeight, rowIcon, resultRowIcon
        case colorDot, calendarBarWidth, calendarBarHeight, keyCap, compactKeyCap, heroKeyCap
        case menuButton, checkbox
        case menuWidth, formMenuMinimumWidth, formMenuExtraRowsHeight, formFieldFocusStroke
        case actionMenuWidth, clipboardFilterMenuWidth, fileSearchFilterMenuWidth
        case emojiCategoryMenuWidth, menuIcon, menuBrandIcon, barBrandIcon, menuRowSpacing
        case menuSectionHeader, menuRowHeight, menuRowsMaxHeight, clipboardListWidth
        case clipboardMediaHeight, clipboardPreviewPixel, emojiGridInset, emojiCell
        case markdownListMarker, markdownQuoteBar, chatMessageAction, chatSourceBadge
        case chatJumpToLatest, chatImageThumb, chatAttachmentGlyph, chatAttachmentThumb
        case chatAttachmentRemove, chatAttachmentInset
        case quickActionPanel, quickActionHeaderIcon, quickActionScrollFade, quickActionPanelBody
        case quickActionPanelMinBody
        case dialogCompactWidth, dialogWidth, dialogButtonHeight, dialogSymbol
        case dialogSymbolContainer, dialogIcon, hudMaxWidth, hudWidth, hudHeight
        case volumeTrackHeight, volumeReadout
    }

    /// A font's point size; `searchFieldSize` also sizes `searchField` and its `NSFont` twin.
    enum Typography: String, CaseIterable, Sendable {
        case searchFieldSize, headerIcon, rowTitle, rowTrailing, sectionHeader, panelTitle
        case calcResult, keyCap, compactKeyCap, heroKeyCap, markdownHeading1, markdownHeading2
        case markdownHeading3, code, inlineCode, bar, chip, disclosure, menuRow, menuShortcut
        case menuIcon
    }

    static let allCases: [InterfaceToken] =
        Spacing.allCases.map(spacing) + Radius.allCases.map(radius) + Size.allCases.map(size)
        + Typography.allCases.map(typography)

    private static let byKey = Dictionary(uniqueKeysWithValues: allCases.map { ($0.key, $0) })

    var key: String {
        switch self {
        case .spacing(let token): "spacing.\(token.rawValue)"
        case .radius(let token): "radius.\(token.rawValue)"
        case .size(let token): "size.\(token.rawValue)"
        case .typography(let token): "typography.\(token.rawValue)"
        }
    }

    init?(key: String) {
        guard let token = Self.byKey[key] else { return nil }
        self = token
    }
}
