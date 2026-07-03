import Foundation
import SwiftData

struct QuizService {
    static func fetchQuestions(
        mode: QuizMode,
        category: QuestionCategory,
        questionCount: Int?,
        modelContext: ModelContext
    ) throws -> [Question] {
        let questionDescriptor = FetchDescriptor<Question>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        var questions = try modelContext.fetch(questionDescriptor)
            .filter { $0.isDeleted == false }

        if mode == .review {
            let reviewDescriptor = FetchDescriptor<ReviewStatus>()
            let reviewQuestionIds = Set(
                try modelContext.fetch(reviewDescriptor)
                    .filter { $0.isReviewTarget }
                    .map(\.questionId)
            )

            questions = questions.filter { reviewQuestionIds.contains($0.id) }
        }

        if category != .all {
            questions = questions.filter { $0.categoryRaw == category.rawValue }
        }

        if mode == .random {
            questions.shuffle()
        }

        if let questionCount {
            questions = Array(questions.prefix(questionCount))
        }

        return questions
    }

    static func recordAnswer(
        question: Question,
        selectedOption: AnswerOption,
        quizMode: QuizMode,
        modelContext: ModelContext
    ) throws -> QuizAnswerResult {
        let correctOption = question.correctOption
        let isCorrect = selectedOption == correctOption
        let answeredAt = Date()

        let answerHistory = AnswerHistory(
            questionId: question.id,
            selectedOption: selectedOption,
            correctOption: correctOption,
            isCorrect: isCorrect,
            category: question.category,
            answeredAt: answeredAt
        )
        modelContext.insert(answerHistory)

        if isCorrect, quizMode == .review {
            try registerReviewCorrectAnswer(
                questionId: question.id,
                at: answeredAt,
                modelContext: modelContext
            )
        } else if isCorrect == false {
            try registerWrongAnswer(
                questionId: question.id,
                isReviewMode: quizMode == .review,
                at: answeredAt,
                modelContext: modelContext
            )
        }

        try modelContext.save()

        return QuizAnswerResult(
            question: question,
            selectedOption: selectedOption,
            correctOption: correctOption,
            isCorrect: isCorrect
        )
    }

    private static func registerWrongAnswer(
        questionId: UUID,
        isReviewMode: Bool,
        at date: Date,
        modelContext: ModelContext
    ) throws {
        let descriptor = FetchDescriptor<ReviewStatus>(
            sortBy: [SortDescriptor(\.createdAt)]
        )

        if let existingStatus = try modelContext.fetch(descriptor).first(where: { $0.questionId == questionId }) {
            existingStatus.isReviewTarget = true
            existingStatus.wrongCount += 1
            existingStatus.consecutiveReviewCorrectCount = 0
            existingStatus.lastWrongAt = date

            if isReviewMode {
                existingStatus.lastReviewedAt = date
            }

            existingStatus.updatedAt = date
        } else {
            let reviewStatus = ReviewStatus(
                questionId: questionId,
                isReviewTarget: true,
                wrongCount: 1,
                consecutiveReviewCorrectCount: 0,
                lastWrongAt: date,
                lastReviewedAt: isReviewMode ? date : nil,
                createdAt: date,
                updatedAt: date
            )
            modelContext.insert(reviewStatus)
        }
    }

    private static func registerReviewCorrectAnswer(
        questionId: UUID,
        at date: Date,
        modelContext: ModelContext
    ) throws {
        let descriptor = FetchDescriptor<ReviewStatus>(
            sortBy: [SortDescriptor(\.createdAt)]
        )

        guard let existingStatus = try modelContext.fetch(descriptor).first(where: { $0.questionId == questionId }) else {
            return
        }

        existingStatus.consecutiveReviewCorrectCount += 1
        existingStatus.lastReviewedAt = date

        if existingStatus.consecutiveReviewCorrectCount >= 2 {
            existingStatus.isReviewTarget = false
        }

        existingStatus.updatedAt = date
    }
}
