import Foundation
import SwiftData

struct SampleDataSeeder {
    static func seedIfNeeded(modelContext: ModelContext) throws {
        let appSetting = try fetchOrCreateAppSetting(modelContext: modelContext)

        guard appSetting.hasSeededSampleQuestions == false else {
            return
        }

        let sampleQuestions = try loadSampleQuestions()

        for sampleQuestion in sampleQuestions {
            modelContext.insert(sampleQuestion.makeQuestion())
        }

        let now = Date()
        appSetting.hasSeededSampleQuestions = true
        appSetting.updatedAt = now

        try modelContext.save()
    }

    private static func fetchOrCreateAppSetting(modelContext: ModelContext) throws -> AppSetting {
        var descriptor = FetchDescriptor<AppSetting>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        descriptor.fetchLimit = 1

        if let appSetting = try modelContext.fetch(descriptor).first {
            return appSetting
        }

        let appSetting = AppSetting()
        modelContext.insert(appSetting)
        return appSetting
    }

    private static func loadSampleQuestions() throws -> [SampleQuestion] {
        guard let url = Bundle.main.url(forResource: "SampleQuestions", withExtension: "json") else {
            throw SampleDataSeederError.resourceNotFound
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([SampleQuestion].self, from: data)
    }
}

private struct SampleQuestion: Decodable {
    let questionText: String
    let optionA: String
    let optionB: String
    let optionC: String
    let optionD: String
    let correctOption: String
    let category: String
    let explanation: String

    func makeQuestion() -> Question {
        guard let answerOption = AnswerOption(rawValue: correctOption) else {
            preconditionFailure("SampleQuestions.json contains an invalid correctOption: \(correctOption)")
        }

        guard let questionCategory = QuestionCategory(rawValue: category),
              questionCategory.canBeStoredInQuestion else {
            preconditionFailure("SampleQuestions.json contains an invalid category: \(category)")
        }

        return Question(
            questionText: questionText,
            optionA: optionA,
            optionB: optionB,
            optionC: optionC,
            optionD: optionD,
            correctOption: answerOption,
            explanation: explanation,
            category: questionCategory,
            sourceType: .initial,
            isDeleted: false
        )
    }
}

private enum SampleDataSeederError: Error {
    case resourceNotFound
}
