import CoreGraphics
import Foundation

struct PalettePlacementRequest: Sendable, Equatable {
    let windowServerRegion: CGRect

    static func parse(_ items: [URLQueryItem]) -> PalettePlacementRequest? {
        guard let raw = items.first(where: { $0.name.lowercased() == "frame" })?.value else {
            return nil
        }
        let fields = raw.split(separator: ",", omittingEmptySubsequences: false)
        let numbers = fields.compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard fields.count == 4, numbers.count == 4, numbers.allSatisfy(\.isFinite),
            numbers[2] > 0, numbers[3] > 0
        else { return nil }
        return PalettePlacementRequest(
            windowServerRegion: CGRect(x: numbers[0], y: numbers[1], width: numbers[2], height: numbers[3]))
    }
}
