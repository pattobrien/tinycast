import AppKit
import SwiftUI

@main
@MainActor
struct InterfaceOverridesTests {
    static var failures = 0
    static var passes = 0

    static func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
        if condition() {
            passes += 1
        } else {
            failures += 1
            print("FAIL: \(message)")
        }
    }

    static func expect(_ actual: CGFloat, _ expected: CGFloat, _ message: String) {
        expect(abs(actual - expected) < 0.001, "\(message) — got \(actual), want \(expected)")
    }

    static func main() throws {
        overridesLandAfterTheScale()
        overridesLandOnMicro()
        derivedTokensFollowTheirInputs()
        noOverrideKeepsThemeVerbatim()
        everyTokenIsHonoured()
        try everyPropertyHasAToken()
        try everyTokenHasAReader()
        keysRoundTrip()
        try theFileApplies()
        try badValuesKeepTheirOverride()
        try theObjectIsTheWholeSet()
        try theFileRoundTrips()
        storedOverridesDropWhatNoTokenAccepts()
        try theDocsListEveryKey()

        print("\(passes) passed, \(failures) failed")
        if failures > 0 { exit(1) }
    }

    static func points(_ font: Font) -> CGFloat {
        font.resolve(in: EnvironmentValues().fontResolutionContext).pointSize
    }

    static func overridesLandAfterTheScale() {
        let m = InterfaceSize.large.metrics.overriding([
            .spacing(.sm): 4, .size(.resultRowIcon): 16, .typography(.rowTitle): 12
        ])
        expect(m.spacing.sm, 4, "an override is the final value, not scaled again")
        expect(m.spacing.md, 9, "an untouched token still scales")
        expect(m.size.resultRowIcon, 16, "a size override applies")
        expect(m.size.panelWidth, 825, "the panel still scales")
        expect(points(m.typography.rowTitle), 12, "a typography override is the font's point size")
        expect(
            points(m.typography.rowTrailing),
            13,
            "an untouched font still scales")
        expect(
            m.overriding([.spacing(.sm): 6]).spacing.sm == 6
                && m.overriding([.spacing(.sm): 6]).size.resultRowIcon == 16,
            "overriding again keeps the earlier overrides")
    }

    static func overridesLandOnMicro() {
        let m = InterfaceSize.micro.metrics.overriding([
            .size(.resultRowIcon): 20, .spacing(.rowVertical): 1, .size(.headerPadding): 4,
            .typography(.searchFieldSize): 15, .typography(.rowTitle): 12
        ])
        expect(m.size.resultRowIcon, 20, "an override replaces Micro's stated row icon")
        expect(m.spacing.rowVertical, 1, "an override replaces Micro's stated row padding")
        expect(m.size.compactHeight, 36, "the compact bar follows Micro's header and the overridden padding")
        expect(m.typography.searchFieldSize, 15, "an override replaces Micro's search field size")
        expect(m.typography.searchFieldNSFont.pointSize, 15, "the search field NSFont follows its key")
        expect(points(m.typography.rowTitle), 12, "a typography override applies at Micro's text scale")
        expect(m.radius.row, 3, "an untouched chrome token keeps Micro's value")
        expect(m.size.panelWidth, 600, "an untouched geometry token keeps Micro's scale")
        expect(m.spacing.md, 6, "an untouched spacing keeps Micro's scale")
        expect(
            m.typography.rowTrailing == Theme.Typography.rowTrailing, "an untouched font stays Theme's own")
    }

    static func derivedTokensFollowTheirInputs() {
        let header = InterfaceMetrics.standard.overriding(
            [.size(.headerHeight): 30, .size(.headerPadding): 4])
        expect(header.size.compactHeight, 38, "the compact bar follows an overridden header")
        expect(
            header.overriding([.size(.compactHeight): 50]).size.compactHeight, 50,
            "an explicit compactHeight wins")

        let menu = InterfaceMetrics.standard.overriding([.size(.menuIcon): 16, .spacing(.md): 4])
        expect(menu.size.menuRowHeight, 24, "a menu row follows its overridden glyph and padding")
        expect(
            menu.size.menuRowsMaxHeight, 138,
            "the menu cap follows the overridden row")

        let button = InterfaceMetrics.standard.overriding([.size(.menuButton): 40])
        expect(
            button.size.dialogButtonHeight, 38,
            "a dialog button stays its reduction below an overridden menu button")
    }

    static func noOverrideKeepsThemeVerbatim() {
        let m = InterfaceMetrics.standard.overriding([.typography(.chip): 15])
        expect(m.typography.rowTitle == Theme.Typography.rowTitle, "an untouched font is Theme's own")
        expect(
            m.typography.searchFieldNSFont == Theme.Typography.searchFieldNSFont,
            "an untouched NSFont is Theme's own")
        expect(m.typography.chipNSFont.pointSize, 15, "the chip's NSFont follows its key")
        expect(points(m.typography.chip), 15, "the chip follows its key")
        expect(
            m.typography.chipNSFont.familyName
                == NSFont.preferredFont(forTextStyle: .callout).familyName,
            "an overridden font keeps its style's family")
    }

    /// Exhaustive, so a token added without a property fails to compile here.
    static func value(_ token: InterfaceToken, in m: InterfaceMetrics) -> CGFloat {
        switch token {
        case .spacing(let token):
            switch token {
            case .xxs: m.spacing.xxs
            case .xs: m.spacing.xs
            case .sm: m.spacing.sm
            case .md: m.spacing.md
            case .lg: m.spacing.lg
            case .xl: m.spacing.xl
            case .dialogInset: m.spacing.dialogInset
            case .xxl: m.spacing.xxl
            case .xxxl: m.spacing.xxxl
            case .sectionHeaderBottom: m.spacing.sectionHeaderBottom
            case .sectionSpacing: m.spacing.sectionSpacing
            case .emojiSectionSpacing: m.spacing.emojiSectionSpacing
            case .rowVertical: m.spacing.rowVertical
            case .chatTranscriptBottom: m.spacing.chatTranscriptBottom
            case .chatFollowTailSlack: m.spacing.chatFollowTailSlack
            case .chatLine: m.spacing.chatLine
            }
        case .radius(let token):
            switch token {
            case .panel: m.radius.panel
            case .row: m.radius.row
            case .formField: m.radius.formField
            case .emojiCell: m.radius.emojiCell
            case .menu: m.radius.menu
            case .menuRow: m.radius.menuRow
            case .barControl: m.radius.barControl
            case .menuPanel: m.radius.menuPanel
            case .dialogSymbol: m.radius.dialogSymbol
            case .dialog: m.radius.dialog
            case .thumbnail: m.radius.thumbnail
            case .attachmentChip: m.radius.attachmentChip
            case .card: m.radius.card
            case .codeBlock: m.radius.codeBlock
            case .keyCap: m.radius.keyCap
            case .tooltip: m.radius.tooltip
            }
        case .size(let token):
            switch token {
            case .panelWidth: m.size.panelWidth
            case .panelHeight: m.size.panelHeight
            case .headerHeight: m.size.headerHeight
            case .headerIconSlot: m.size.headerIconSlot
            case .searchFieldMinWidth: m.size.searchFieldMinWidth
            case .headerPadding: m.size.headerPadding
            case .compactHeight: m.size.compactHeight
            case .bottomBarHeight: m.size.bottomBarHeight
            case .barButtonHeight: m.size.barButtonHeight
            case .rowIcon: m.size.rowIcon
            case .resultRowIcon: m.size.resultRowIcon
            case .colorDot: m.size.colorDot
            case .calendarBarWidth: m.size.calendarBarWidth
            case .calendarBarHeight: m.size.calendarBarHeight
            case .keyCap: m.size.keyCap
            case .compactKeyCap: m.size.compactKeyCap
            case .heroKeyCap: m.size.heroKeyCap
            case .menuButton: m.size.menuButton
            case .checkbox: m.size.checkbox
            case .menuWidth: m.size.menuWidth
            case .formMenuMinimumWidth: m.size.formMenuMinimumWidth
            case .formMenuExtraRowsHeight: m.size.formMenuExtraRowsHeight
            case .formFieldFocusStroke: m.size.formFieldFocusStroke
            case .actionMenuWidth: m.size.actionMenuWidth
            case .clipboardFilterMenuWidth: m.size.clipboardFilterMenuWidth
            case .fileSearchFilterMenuWidth: m.size.fileSearchFilterMenuWidth
            case .emojiCategoryMenuWidth: m.size.emojiCategoryMenuWidth
            case .menuIcon: m.size.menuIcon
            case .menuBrandIcon: m.size.menuBrandIcon
            case .barBrandIcon: m.size.barBrandIcon
            case .menuRowSpacing: m.size.menuRowSpacing
            case .menuSectionHeader: m.size.menuSectionHeader
            case .menuRowHeight: m.size.menuRowHeight
            case .menuRowsMaxHeight: m.size.menuRowsMaxHeight
            case .clipboardListWidth: m.size.clipboardListWidth
            case .clipboardMediaHeight: m.size.clipboardMediaHeight
            case .clipboardPreviewPixel: m.size.clipboardPreviewPixel
            case .emojiGridInset: m.size.emojiGridInset
            case .markdownListMarker: m.size.markdownListMarker
            case .markdownQuoteBar: m.size.markdownQuoteBar
            case .chatMessageAction: m.size.chatMessageAction
            case .chatSourceBadge: m.size.chatSourceBadge
            case .chatJumpToLatest: m.size.chatJumpToLatest
            case .chatImageThumb: m.size.chatImageThumb
            case .chatAttachmentGlyph: m.size.chatAttachmentGlyph
            case .chatAttachmentThumb: m.size.chatAttachmentThumb
            case .chatAttachmentRemove: m.size.chatAttachmentRemove
            case .chatAttachmentInset: m.size.chatAttachmentInset
            case .quickActionPanel: m.size.quickActionPanel
            case .quickActionHeaderIcon: m.size.quickActionHeaderIcon
            case .quickActionScrollFade: m.size.quickActionScrollFade
            case .quickActionPanelBody: m.size.quickActionPanelBody
            case .quickActionPanelMinBody: m.size.quickActionPanelMinBody
            case .dialogCompactWidth: m.size.dialogCompactWidth
            case .dialogWidth: m.size.dialogWidth
            case .dialogButtonHeight: m.size.dialogButtonHeight
            case .dialogSymbol: m.size.dialogSymbol
            case .dialogSymbolContainer: m.size.dialogSymbolContainer
            case .dialogIcon: m.size.dialogIcon
            case .hudMaxWidth: m.size.hudMaxWidth
            case .hudWidth: m.size.hudWidth
            case .hudHeight: m.size.hudHeight
            case .volumeTrackHeight: m.size.volumeTrackHeight
            case .volumeReadout: m.size.volumeReadout
            }
        case .typography(let token):
            switch token {
            case .searchFieldSize: m.typography.searchFieldSize
            case .headerIcon: points(m.typography.headerIcon)
            case .rowTitle: points(m.typography.rowTitle)
            case .rowTrailing: points(m.typography.rowTrailing)
            case .sectionHeader: points(m.typography.sectionHeader)
            case .panelTitle: points(m.typography.panelTitle)
            case .calcResult: points(m.typography.calcResult)
            case .keyCap: points(m.typography.keyCap)
            case .compactKeyCap: points(m.typography.compactKeyCap)
            case .heroKeyCap: points(m.typography.heroKeyCap)
            case .markdownHeading1: points(m.typography.markdownHeading1)
            case .markdownHeading2: points(m.typography.markdownHeading2)
            case .markdownHeading3: points(m.typography.markdownHeading3)
            case .code: points(m.typography.code)
            case .inlineCode: points(m.typography.inlineCode)
            case .bar: points(m.typography.bar)
            case .chip: points(m.typography.chip)
            case .disclosure: points(m.typography.disclosure)
            case .menuRow: points(m.typography.menuRow)
            case .menuShortcut: points(m.typography.menuShortcut)
            case .menuIcon: points(m.typography.menuIcon)
            }
        }
    }

    static func everyTokenIsHonoured() {
        let everything = Dictionary(uniqueKeysWithValues: InterfaceToken.allCases.map { ($0, CGFloat(17)) })
        for size in InterfaceSize.allCases {
            let m = size.metrics.overriding(everything)
            for token in InterfaceToken.allCases {
                expect(value(token, in: m), 17, "\(token.key) honours its override at \(size.rawValue)")
            }
            expect(points(m.typography.searchField), 17, "searchField follows typography.searchFieldSize")
            expect(
                m.typography.searchFieldNSFont.pointSize, 17,
                "searchFieldNSFont follows typography.searchFieldSize")
            expect(m.typography.chipNSFont.pointSize, 17, "chipNSFont follows typography.chip")
        }
    }

    static let twins = [
        "typography.searchField": "typography.searchFieldSize",
        "typography.searchFieldNSFont": "typography.searchFieldSize",
        "typography.chipNSFont": "typography.chip"
    ]

    /// Text, because a property added without a token compiles and silently can't be overridden.
    static func everyPropertyHasAToken() throws {
        let source = try String(
            contentsOfFile: "Tinycast/DesignSystem/InterfaceMetrics.swift", encoding: .utf8)
        var declared: [String] = []
        var group: String?
        var depth = 0
        for line in source.split(separator: "\n", omittingEmptySubsequences: false) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if group == nil,
                let opened = trimmed.firstMatch(of: /^struct (Spacing|Radius|Size|Typography):/)
            {
                group = opened.1.lowercased()
            }
            guard let current = group else { continue }
            if depth == 1, let property = trimmed.firstMatch(of: /^(?:@\w+ )*var (\w+)\s*:/) {
                declared.append("\(current).\(property.1)")
            }
            depth += trimmed.count(where: { $0 == "{" }) - trimmed.count(where: { $0 == "}" })
            if depth == 0 { group = nil }
        }
        let keys = Set(InterfaceToken.allCases.map(\.key))
        let untokened = declared.filter { !keys.contains($0) && twins[$0] == nil }
        let unread = keys.subtracting(declared)
        expect(
            declared.count == keys.count + twins.count,
            "the scan found every property — got \(declared.count)")
        expect(untokened.isEmpty, "every property has a token — missing: \(untokened)")
        expect(unread.isEmpty, "every token has a property — missing: \(unread.sorted())")
    }

    /// Text, because a token nothing reads still parses, validates and persists without effect.
    static func everyTokenHasAReader() throws {
        let definitions: Set = [
            "Tinycast/DesignSystem/InterfaceMetrics.swift", "Tinycast/DesignSystem/InterfaceToken.swift"
        ]
        guard let paths = FileManager.default.enumerator(atPath: "Tinycast")?.allObjects as? [String]
        else { return expect(false, "the Tinycast sources are enumerable") }
        let tokenPath = /\b(spacing|radius|size|typography)\.(\w+)\b/.wordBoundaryKind(.simple)
        var read: Set<String> = []
        for path in paths.map({ "Tinycast/\($0)" }) where path.hasSuffix(".swift") {
            guard !definitions.contains(path) else { continue }
            let source = try String(contentsOfFile: path, encoding: .utf8)
            for match in source.matches(of: tokenPath) {
                let key = "\(match.1).\(match.2)"
                read.insert(twins[key] ?? key)
            }
            for match in source.matches(of: /textNSFont\([^)]*?token: \.(\w+)/) {
                read.insert("typography.\(match.1)")
            }
        }
        let unread = InterfaceToken.allCases.map(\.key).filter { !read.contains($0) }
        expect(unread.isEmpty, "every token is read outside its definition — unread: \(unread)")
    }

    static func keysRoundTrip() {
        let keys = InterfaceToken.allCases.map(\.key)
        expect(Set(keys).count == keys.count, "no two tokens share a key")
        expect(InterfaceToken(key: "size.panelWidth") == .size(.panelWidth), "a key parses to its token")
        expect(InterfaceToken(key: "spacing.bogus") == nil, "an unknown key parses to nothing")
        expect(InterfaceToken(key: "typography.searchField") == nil, "a twin has no key of its own")
        expect(
            InterfaceToken.allCases.allSatisfy { InterfaceToken(key: $0.key) == $0 },
            "every key parses back to its token")
    }

    static func file(_ text: String) throws -> SettingsFileJSON {
        SettingsFileJSON(
            jsonObject: try JSONSerialization.jsonObject(
                with: Data(text.utf8), options: .fragmentsAllowed))
    }

    static func theFileApplies() throws {
        let json = try file(
            #"{"spacing.sm": 4, "size.resultRowIcon": 16, "typography.rowTitle": 12, "spacing.bogus": 3, "radius.row": "big"}"#
        )
        guard
            let decoded = InterfaceOverridesFileFormat.overrides(
                from: json, current: [.radius(.row): 7])
        else { return expect(false, "an object decodes") }
        let m = InterfaceSize.large.metrics.overriding(decoded.overrides)
        expect(m.spacing.sm, 4, "spacing.sm applies as its final value")
        expect(m.spacing.md, 9, "spacing.md still scales")
        expect(m.size.resultRowIcon, 16, "size.resultRowIcon applies")
        expect(m.size.panelWidth, 825, "size.panelWidth still scales")
        expect(m.radius.row, 7, "a bad radius.row keeps its current override")
        expect(points(m.typography.rowTitle), 12, "typography.rowTitle resolves to 12 pt")
        expect(
            decoded.problems == [
                "“radius.row” must be a number of points, 0 or more",
                "no design token is called “spacing.bogus”"
            ], "each bad entry is reported once — got \(decoded.problems)")
    }

    static func badValuesKeepTheirOverride() throws {
        let json = try file(
            #"{"spacing.xs": 2.5, "spacing.lg": -1, "radius.card": 0, "typography.chip": 0, "typography.bar": null}"#
        )
        let current: [InterfaceToken: CGFloat] = [.spacing(.lg): 11, .typography(.chip): 15]
        let decoded = InterfaceOverridesFileFormat.overrides(from: json, current: current)
        expect(
            decoded?.overrides == [
                .spacing(.xs): 2.5, .spacing(.lg): 11, .radius(.card): 0, .typography(.chip): 15
            ], "a fraction and a zero length apply; a bad value keeps or leaves unset")
        expect(
            decoded?.problems == [
                "“spacing.lg” must be a number of points, 0 or more",
                "“typography.bar” must be a number of points, more than 0",
                "“typography.chip” must be a number of points, more than 0"
            ], "a negative length and a non-positive font are reported — got \(decoded?.problems ?? [])")
    }

    static func theObjectIsTheWholeSet() throws {
        let current: [InterfaceToken: CGFloat] = [.spacing(.sm): 4, .size(.panelWidth): 900]
        let cleared = InterfaceOverridesFileFormat.overrides(from: try file("{}"), current: current)
        expect(cleared?.overrides == [:], "{} clears every override")
        expect(cleared?.problems == [], "{} is no problem")
        let kept = InterfaceOverridesFileFormat.overrides(
            from: try file(#"{"spacing.sm": 5}"#), current: current)
        expect(kept?.overrides == [.spacing(.sm): 5], "a token the object leaves out is cleared")
        for text in ["null", "[]", "3", #""big""#] {
            let json = try file(text)
            expect(
                InterfaceOverridesFileFormat.overrides(from: json, current: current) == nil,
                "\(text) is not an object")
        }
    }

    static func theFileRoundTrips() throws {
        let overrides: [InterfaceToken: CGFloat] = [
            .typography(.rowTitle): 12, .spacing(.sm): 4, .size(.panelWidth): 812.5
        ]
        let json = InterfaceOverridesFileFormat.json(overrides)
        expect(
            json.members?.map(\.key) == ["spacing.sm", "size.panelWidth", "typography.rowTitle"],
            "the object lists tokens in InterfaceToken order")
        let decoded = InterfaceOverridesFileFormat.overrides(from: json, current: [:])
        expect(decoded?.overrides == overrides, "what the app writes reads back the same")
        expect(decoded?.problems == [], "what the app writes has no problem")
    }

    static func storedOverridesDropWhatNoTokenAccepts() {
        let stored = [
            "spacing.bogus": 3, "typography.rowTitle": 0, "radius.row": -1, "size.panelWidth": 900.0
        ]
        expect(
            InterfaceToken.overrides(stored: stored) == [.size(.panelWidth): 900],
            "an unknown key or refused value drops from storage")
        expect(
            InterfaceToken.stored([.size(.panelWidth): 900, .typography(.chip): 14])
                == ["size.panelWidth": 900, "typography.chip": 14], "storage keys by token path")
    }

    /// The doc's list is what a user copies from, so it must name every key in file order.
    static func theDocsListEveryKey() throws {
        let doc = try String(contentsOfFile: "docs/features/settings-file.md", encoding: .utf8)
        guard let start = doc.range(of: "### Override keys\n") else {
            return expect(false, "settings-file.md has an Override keys section")
        }
        let section = doc[start.upperBound...].prefix { $0 != "#" }
        var listed: [String] = []
        var group = ""
        for line in section.split(separator: "\n") where line.hasPrefix("- `") || line.hasPrefix("  `") {
            var names = line.matches(of: /`([^`]+)`/).map { String($0.1) }
            if line.hasPrefix("- ") { group = names.removeFirst() }
            listed += names.map { "\(group).\($0)" }
        }
        let keys = InterfaceToken.allCases.map(\.key)
        expect(
            listed == keys,
            "the doc lists every key in order — missing \(Set(keys).subtracting(listed).sorted()), "
                + "extra \(Set(listed).subtracting(keys).sorted())"
        )
    }
}
