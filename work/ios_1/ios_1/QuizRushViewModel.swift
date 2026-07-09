import Foundation
internal import Combine

enum QuizViewState {
    case loading
    case loaded
    case failed
}

@MainActor
final class QuizRushViewModel: ObservableObject {
    @Published private(set) var questions: [QuizQuestion] = []
    @Published private(set) var currentIndex = 0
    @Published private(set) var score = 0
    @Published private(set) var streak = 0
    @Published private(set) var state: QuizViewState = .loading

    // Drives the green flash / red shake polish in the view
    @Published private(set) var lastAnswerWasCorrect: Bool?

    private let service: TriviaService

    init(service: TriviaService = TriviaService()) {
        self.service = service
    }

    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var isFinished: Bool {
        state == .loaded && currentIndex >= questions.count && !questions.isEmpty
    }

    /// Called from the view's .task modifier and from the Retry / Play Again buttons.
    func load() async {
        state = .loading
        currentIndex = 0
        score = 0
        streak = 0
        lastAnswerWasCorrect = nil

        do {
            questions = try await service.fetchQuestions()
            state = .loaded
        } catch {
            state = .failed
        }
    }

    func submitAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }

        if answer == question.correctAnswer {
            streak += 1
            let streakBonus = streak > 1 ? streak : 0
            score += 10 + streakBonus
            lastAnswerWasCorrect = true
        } else {
            streak = 0
            score = max(0, score - 5)
            lastAnswerWasCorrect = false
        }

        currentIndex += 1
    }
}
