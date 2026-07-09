import Foundation
internal import UIKit

// MARK: - Error

enum TriviaAPIError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed
}

// MARK: - Raw API response (matches opentdb.com JSON exactly)

struct TriviaResponse: Codable {
    let results: [TriviaQuestionDTO]
}

struct TriviaQuestionDTO: Codable {
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

// MARK: - API Service

struct TriviaAPI {
    private let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"

    func fetchQuestions() async throws -> [TriviaQuestion] {
        guard let url = URL(string: urlString) else {
            throw TriviaAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TriviaAPIError.invalidResponse
        }

        let decoded: TriviaResponse
        do {
            decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
        } catch {
            throw TriviaAPIError.decodingFailed
        }

        return decoded.results.map { dto in
            let question = dto.question.decodedHTML
            let correct = dto.correctAnswer.decodedHTML
            let incorrect = dto.incorrectAnswers.map { $0.decodedHTML }

            return TriviaQuestion(
                text: question,
                correctAnswer: correct,
                answers: ([correct] + incorrect).shuffled()
            )
        }
    }
}

// MARK: - HTML Decoding Helper

extension String {
    var decodedHTML: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        return attributed.string
    }
}
