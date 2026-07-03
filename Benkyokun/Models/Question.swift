import Foundation
import SwiftData

@Model
final class Question {
    @Attribute(.unique) var id: UUID

    var questionText: String
    var optionA: String
    var optionB: String
    var optionC: String
    var optionD: String

    var correctOptionRaw: String
    var explanation: String
    var categoryRaw: String
    var sourceTypeRaw: String

    var isDeleted: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        questionText: String,
        optionA: String,
        optionB: String,
        optionC: String,
        optionD: String,
        correctOption: AnswerOption,
        explanation: String,
        category: QuestionCategory,
        sourceType: QuestionSourceType = .userCreated,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        precondition(category.canBeStoredInQuestion, "Question.categoryRaw must not store QuestionCategory.all")

        self.id = id
        self.questionText = questionText
        self.optionA = optionA
        self.optionB = optionB
        self.optionC = optionC
        self.optionD = optionD
        self.correctOptionRaw = correctOption.rawValue
        self.explanation = explanation
        self.categoryRaw = category.rawValue
        self.sourceTypeRaw = sourceType.rawValue
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Question {
    var correctOption: AnswerOption {
        AnswerOption(rawValue: correctOptionRaw) ?? .a
    }

    var category: QuestionCategory {
        QuestionCategory(rawValue: categoryRaw) ?? .electricalTheory
    }

    var sourceType: QuestionSourceType {
        QuestionSourceType(rawValue: sourceTypeRaw) ?? .userCreated
    }

    func optionText(for option: AnswerOption) -> String {
        switch option {
        case .a:
            return optionA
        case .b:
            return optionB
        case .c:
            return optionC
        case .d:
            return optionD
        }
    }

    func markAsDeleted(at date: Date = Date()) {
        isDeleted = true
        updatedAt = date
    }
}
