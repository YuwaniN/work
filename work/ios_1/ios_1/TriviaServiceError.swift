//
//  TriviaServiceError.swift
//  ios_1
//
//  Created by Yuwani on 2026-07-09.
//


import Foundation

enum TriviaServiceError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed
}

struct TriviaService {
    private let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"

    func fetchQuestions() async throws -> [QuizQuestion] {
        guard let url = URL(string: urlString) else {
            throw TriviaServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TriviaServiceError.invalidResponse
        }

        let decoded: TriviaResponse
        do {
            decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
        } catch {
            throw TriviaServiceError.decodingFailed
        }

        return decoded.results.map { dto in
            let question = dto.question.decodedHTML
            let correct = dto.correctAnswer.decodedHTML
            let incorrect = dto.incorrectAnswers.map { $0.decodedHTML }

            return QuizQuestion(
                text: question,
                correctAnswer: correct,
                answers: ([correct] + incorrect).shuffled()
            )
        }
    }
}