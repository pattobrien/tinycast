import Foundation

/// `appearance.overrides` as settings.json spells it: design-token keys to final point values.
enum InterfaceOverridesFileFormat {
    typealias Decoded = (overrides: [InterfaceToken: CGFloat], problems: [String])

    static func json(_ overrides: [InterfaceToken: CGFloat]) -> SettingsFileJSON {
        .object(
            InterfaceToken.allCases.compactMap { token in
                overrides[token].map {
                    SettingsFileJSON.Member(key: token.key, value: .number(Double($0)))
                }
            })
    }

    /// A token the object leaves out is cleared; one with an unusable value keeps its current one.
    static func overrides(
        from json: SettingsFileJSON, current: [InterfaceToken: CGFloat]
    ) -> Decoded? {
        guard let members = json.members else { return nil }
        var decoded: Decoded = ([:], [])
        for member in members {
            guard let token = InterfaceToken(key: member.key) else {
                decoded.problems.append("no design token is called “\(member.key)”")
                continue
            }
            guard let points = member.value.number, token.accepts(points) else {
                decoded.overrides[token] = current[token]
                decoded.problems.append("“\(member.key)” must be a number of points, \(range(of: token))")
                continue
            }
            decoded.overrides[token] = CGFloat(points)
        }
        return decoded
    }

    private static func range(of token: InterfaceToken) -> String {
        if case .typography = token { return "more than 0" }
        return "0 or more"
    }
}
