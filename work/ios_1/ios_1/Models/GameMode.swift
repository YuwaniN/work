import SwiftUI

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case tapFrenzy
    case lightItUp
    case quizRush

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tapFrenzy: return "Tap Frenzy"
        case .lightItUp: return "Light It Up"
        case .quizRush: return "Quiz Rush"
        }
    }

    var symbolName: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "bolt.fill"
        case .quizRush: return "questionmark.circle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .tapFrenzy: return .green
        case .lightItUp: return .yellow
        case .quizRush: return .blue
        }
    }
}
