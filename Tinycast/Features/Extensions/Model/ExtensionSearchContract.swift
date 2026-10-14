import Foundation

/// Raycast's `SearchBarInterface`, read once for a `List` or `Grid` root or any of its dropdowns.
struct ExtensionSearchContract: Equatable, Sendable {
    /// True when Tinycast filters the choices itself; false when the extension owns the text.
    let filtersLocally: Bool
    let textHandler: String?
    let isLoading: Bool

    static let inert = ExtensionSearchContract(
        filtersLocally: false, textHandler: nil, isLoading: false)

    init(node: RenderNode) {
        textHandler = node.handler("onSearchTextChange")
        isLoading = node.bool("isLoading") ?? false
        // Raycast filters locally unless the extension takes the search text over.
        filtersLocally =
            node.bool("filtering") ?? (node.object("filtering") != nil || textHandler == nil)
    }

    private init(filtersLocally: Bool, textHandler: String?, isLoading: Bool) {
        self.filtersLocally = filtersLocally
        self.textHandler = textHandler
        self.isLoading = isLoading
    }

    func filter(for query: String) -> Filter {
        let needle = FuzzyMatch.Query(query.trimmingCharacters(in: .whitespaces))
        return Filter(needle: filtersLocally && !needle.isEmpty ? needle : nil)
    }

    struct Filter {
        fileprivate let needle: FuzzyMatch.Query?

        func admits(_ texts: [String]) -> Bool { score(texts) != nil }

        /// The best of `texts`, or nil when none matches; with nothing to filter, all score 0.
        func score(_ texts: [String]) -> Int? {
            guard let needle else { return 0 }
            return texts.compactMap { FuzzyMatch.score(needle, candidate: $0) }.max()
        }
    }
}
