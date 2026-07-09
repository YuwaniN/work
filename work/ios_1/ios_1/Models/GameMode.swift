import Foundation

enum GameMode: String, Codable, CaseIterable {
    case tapFrenzy
    case lightItUp
    case quizRush

    var displayName: String {
        switch self {
        case .tapFrenzy: return "Tap Frenzy"
        case .lightItUp: return "Light It Up"
        case .quizRush: return "Quiz Rush"
        }
    }

    var symbolName: String {
        switch self {
        case .tapFrenzy: return "gamecontroller"
        case .lightItUp: return "bolt"
        case .quizRush: return "questionmark.circle"
        }
    }
}
