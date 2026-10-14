import CoreGraphics

/// How large the palette and its floating siblings render; an unset key reads as `.standard`.
enum InterfaceSize: String, CaseIterable, Identifiable, Sendable {
    case standard
    case large
    case larger

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: "Default"
        case .large: "Large"
        case .larger: "Larger"
        }
    }

    var metrics: InterfaceMetrics {
        switch self {
        case .standard: .standard
        case .large: InterfaceMetrics(scale: 1.1)
        case .larger: InterfaceMetrics(scale: 1.2)
        }
    }
}
