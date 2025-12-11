import Foundation

enum FocusTab: String, CaseIterable, Identifiable {
    case start
    case presets
    case history
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .start: return "Start"
        case .presets: return "Presets"
        case .history: return "History"
        }
    }
    
    var icon: String {
        switch self {
        case .start: return "play.circle.fill"
        case .presets: return "rectangle.stack.fill"
        case .history: return "clock.fill"
        }
    }
}