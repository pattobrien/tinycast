import CoreGraphics

/// How large the palette and its floating siblings render; an unset key reads as `.standard`.
enum InterfaceSize: String, CaseIterable, Identifiable, Sendable {
    case micro
    case standard
    case large
    case larger

    var id: String { rawValue }

    var title: String {
        switch self {
        case .micro: "Micro"
        case .standard: "Default"
        case .large: "Large"
        case .larger: "Larger"
        }
    }

    var metrics: InterfaceMetrics {
        switch self {
        case .micro: InterfaceMetrics(scale: Theme.Micro.scale, textScale: 1, chrome: .micro)
        case .standard: .standard
        case .large: InterfaceMetrics(scale: 1.1)
        case .larger: InterfaceMetrics(scale: 1.2)
        }
    }
}
