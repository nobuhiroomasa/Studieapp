import Foundation
import SwiftData

@Model
final class AnswerHistory {
    @Attribute(.unique) var id: UUID

    var questionId: UUID
    var selectedOptionRaw: String
    var correctOptionRaw: String
    var isCorrect: Bool
    var categoryRaw: String
    var answeredAt: Date

    init(
        id: UUID = UUID(),
        questionId: UUID,
        selectedOption: AnswerOption,
        correctOption: AnswerOption,
        isCorrect: Bool,
        category: QuestionCategory,
        answeredAt: Date = Date()
    ) {
        precondition(category.canBeStoredInQuestion, "AnswerHistory.categoryRaw must not store QuestionCategory.all")

        self.id = id
        self.questionId = questionId
        self.selectedOptionRaw = selectedOption.rawValue
        self.correctOptionRaw = correctOption.rawValue
        self.isCorrect = isCorrect
        self.categoryRaw = category.rawValue
        self.answeredAt = answeredAt
    }
}

extension AnswerHistory {
    var selectedOption: AnswerOption {
        AnswerOption(rawValue: selectedOptionRaw) ?? .a
    }

    var correctOption: AnswerOption {
        AnswerOption(rawValue: correctOptionRaw) ?? .a
    }

    var category: QuestionCategory {
        QuestionCategory(rawValue: categoryRaw) ?? .electricalTheory
    }
}
