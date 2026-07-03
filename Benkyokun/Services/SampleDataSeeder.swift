import Foundation
import SwiftData

struct SampleDataSeeder {
    static func seedIfNeeded(modelContext: ModelContext) throws {
        let appSetting = try fetchOrCreateAppSetting(modelContext: modelContext)
        let sampleQuestions = try loadSampleQuestions()
        var existingInitialQuestionTexts = try fetchExistingInitialQuestionTexts(modelContext: modelContext)
        var didChange = false

        for sampleQuestion in sampleQuestions {
            let normalizedQuestionText = sampleQuestion.questionText.normalizedForSeedComparison

            guard existingInitialQuestionTexts.contains(normalizedQuestionText) == false else {
                continue
            }

            modelContext.insert(sampleQuestion.makeQuestion())
            existingInitialQuestionTexts.insert(normalizedQuestionText)
            didChange = true
        }

        let now = Date()

        if appSetting.hasSeededSampleQuestions == false {
            appSetting.hasSeededSampleQuestions = true
            didChange = true
        }

        if didChange {
            appSetting.updatedAt = now
            try modelContext.save()
        }
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

    private static func fetchExistingInitialQuestionTexts(modelContext: ModelContext) throws -> Set<String> {
        let descriptor = FetchDescriptor<Question>()

        return Set(
            try modelContext.fetch(descriptor)
                .filter { $0.sourceType == .initial }
                .map { $0.questionText.normalizedForSeedComparison }
        )
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

private extension String {
    var normalizedForSeedComparison: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
