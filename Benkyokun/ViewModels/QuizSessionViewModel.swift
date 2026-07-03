import Foundation
import Observation
import SwiftData

struct QuizAnswerResult {
    let question: Question
    let selectedOption: AnswerOption
    let correctOption: AnswerOption
    let isCorrect: Bool
}

enum QuizSessionError: LocalizedError {
    case noCurrentQuestion

    var errorDescription: String? {
        switch self {
        case .noCurrentQuestion:
            return "表示できる問題がありません。"
        }
    }
}

@Observable
final class QuizSessionViewModel {
    private(set) var questions: [Question]
    let mode: QuizMode
    private(set) var currentIndex = 0
    private(set) var correctCount = 0
    private(set) var incorrectCount = 0
    private(set) var selectedAnswer: AnswerOption?
    private(set) var currentAnswerResult: QuizAnswerResult?
    private(set) var isCompleted = false

    init(questions: [Question], mode: QuizMode = .random) {
        self.questions = questions
        self.mode = mode
    }

    var currentQuestion: Question? {
        guard isCompleted == false,
              questions.indices.contains(currentIndex) else {
            return nil
        }

        return questions[currentIndex]
    }

    var currentQuestionNumber: Int {
        guard questions.isEmpty == false else {
            return 0
        }

        return min(currentIndex + 1, questions.count)
    }

    var totalQuestionCount: Int {
        questions.count
    }

    var answeredCount: Int {
        correctCount + incorrectCount
    }

    var hasNextQuestion: Bool {
        currentIndex + 1 < questions.count
    }

    var accuracyPercent: Double {
        guard answeredCount > 0 else {
            return 0
        }

        return Double(correctCount) / Double(answeredCount) * 100
    }

    func answer(
        _ selectedOption: AnswerOption,
        modelContext: ModelContext
    ) throws -> QuizAnswerResult {
        guard let currentQuestion else {
            throw QuizSessionError.noCurrentQuestion
        }

        let result = try QuizService.recordAnswer(
            question: currentQuestion,
            selectedOption: selectedOption,
            quizMode: mode,
            modelContext: modelContext
        )

        selectedAnswer = selectedOption
        currentAnswerResult = result

        if result.isCorrect {
            correctCount += 1
        } else {
            incorrectCount += 1
        }

        return result
    }

    func moveToNextQuestion() {
        selectedAnswer = nil
        currentAnswerResult = nil

        if hasNextQuestion {
            currentIndex += 1
        } else {
            isCompleted = true
        }
    }

    func finishEarly() {
        selectedAnswer = nil
        currentAnswerResult = nil
        isCompleted = true
    }
}
