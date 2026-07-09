//
//  TriviaResponse.swift
//  ios_1
//
//  Created by Yuwani on 2026-07-09.
//


import Foundation
internal import UIKit

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

// MARK: - Cleaned-up model used by the app (shuffled answers, decoded HTML)

struct QuizQuestion: Identifiable {
    let id = UUID()
    let text: String
    let correctAnswer: String
    let answers: [String] // correct + incorrect, pre-shuffled
}

// Open Trivia DB HTML-encodes special characters (e.g. &quot; &#039;)
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
