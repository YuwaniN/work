import Foundation

// MARK: - Cleaned-up model used by the app (shuffled answers, decoded HTML)

struct TriviaQuestion: Identifiable {
    let id = UUID()
    let text: String
    let correctAnswer: String
    let answers: [String] // correct + incorrect, pre-shuffled
}
