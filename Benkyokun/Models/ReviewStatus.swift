import Foundation
import SwiftData

@Model
final class ReviewStatus {
    @Attribute(.unique) var id: UUID

    var questionId: UUID
    var isReviewTarget: Bool
    var wrongCount: Int
    var consecutiveReviewCorrectCount: Int
    var lastWrongAt: Date?
    var lastReviewedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        questionId: UUID,
        isReviewTarget: Bool = true,
        wrongCount: Int = 1,
        consecutiveReviewCorrectCount: Int = 0,
        lastWrongAt: Date? = Date(),
        lastReviewedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.questionId = questionId
        self.isReviewTarget = isReviewTarget
        self.wrongCount = wrongCount
        self.consecutiveReviewCorrectCount = consecutiveReviewCorrectCount
        self.lastWrongAt = lastWrongAt
        self.lastReviewedAt = lastReviewedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension ReviewStatus {
    func registerWrong(at date: Date = Date()) {
        isReviewTarget = true
        wrongCount += 1
        consecutiveReviewCorrectCount = 0
        lastWrongAt = date
        updatedAt = date
    }

    func registerReviewCorrect(at date: Date = Date()) {
        consecutiveReviewCorrectCount += 1
        lastReviewedAt = date

        if consecutiveReviewCorrectCount >= 2 {
            isReviewTarget = false
        }

        updatedAt = date
    }
}
