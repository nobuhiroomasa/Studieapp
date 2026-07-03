import Foundation
import SwiftData

enum QuestionSourceFilter: String, CaseIterable, Identifiable {
    case all = "すべて"
    case initial = "初期問題"
    case userCreated = "追加問題"

    var id: String { rawValue }

    var sourceType: QuestionSourceType? {
        switch self {
        case .all:
            return nil
        case .initial:
            return .initial
        case .userCreated:
            return .userCreated
        }
    }
}

struct QuestionFormInput {
    let questionText: String
    let optionA: String
    let optionB: String
    let optionC: String
    let optionD: String
    let correctOption: AnswerOption
    let category: QuestionCategory
    let explanation: String
}

enum QuestionRepositoryError: LocalizedError {
    case initialQuestionCannotBeDeleted

    var errorDescription: String? {
        switch self {
        case .initialQuestionCannotBeDeleted:
            return "初期問題は削除できません。"
        }
    }
}

struct QuestionRepository {
    static func fetchQuestions(
        searchText: String = "",
        category: QuestionCategory = .all,
        sourceFilter: QuestionSourceFilter = .all,
        modelContext: ModelContext
    ) throws -> [Question] {
        let descriptor = FetchDescriptor<Question>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return try modelContext.fetch(descriptor)
            .filter { $0.isDeleted == false }
            .filter { question in
                guard category != .all else {
                    return true
                }

                return question.categoryRaw == category.rawValue
            }
            .filter { question in
                guard let sourceType = sourceFilter.sourceType else {
                    return true
                }

                return question.sourceTypeRaw == sourceType.rawValue
            }
            .filter { question in
                guard trimmedSearchText.isEmpty == false else {
                    return true
                }

                return question.questionText.localizedCaseInsensitiveContains(trimmedSearchText)
                    || question.optionA.localizedCaseInsensitiveContains(trimmedSearchText)
                    || question.optionB.localizedCaseInsensitiveContains(trimmedSearchText)
                    || question.optionC.localizedCaseInsensitiveContains(trimmedSearchText)
                    || question.optionD.localizedCaseInsensitiveContains(trimmedSearchText)
                    || question.explanation.localizedCaseInsensitiveContains(trimmedSearchText)
            }
    }

    @discardableResult
    static func addQuestion(
        input: QuestionFormInput,
        modelContext: ModelContext
    ) throws -> Question {
        let now = Date()
        let question = Question(
            questionText: input.questionText,
            optionA: input.optionA,
            optionB: input.optionB,
            optionC: input.optionC,
            optionD: input.optionD,
            correctOption: input.correctOption,
            explanation: input.explanation,
            category: input.category,
            sourceType: .userCreated,
            isDeleted: false,
            createdAt: now,
            updatedAt: now
        )

        modelContext.insert(question)
        try modelContext.save()
        return question
    }

    static func updateQuestion(
        _ question: Question,
        input: QuestionFormInput,
        modelContext: ModelContext
    ) throws {
        question.questionText = input.questionText
        question.optionA = input.optionA
        question.optionB = input.optionB
        question.optionC = input.optionC
        question.optionD = input.optionD
        question.correctOptionRaw = input.correctOption.rawValue
        question.categoryRaw = input.category.rawValue
        question.explanation = input.explanation
        question.updatedAt = Date()

        try modelContext.save()
    }

    static func logicallyDelete(
        _ question: Question,
        modelContext: ModelContext
    ) throws {
        guard question.sourceType == .userCreated else {
            throw QuestionRepositoryError.initialQuestionCannotBeDeleted
        }

        question.markAsDeleted()
        try modelContext.save()
    }
}
