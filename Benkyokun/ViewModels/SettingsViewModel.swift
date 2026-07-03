import Foundation
import Observation
import SwiftData

struct AppInfoItem: Identifiable {
    let title: String
    let value: String

    var id: String { title }
}

@Observable
final class SettingsViewModel {
    private(set) var errorMessage: String?
    private(set) var successMessage: String?

    let appInfoItems = [
        AppInfoItem(title: "アプリ名", value: "勉強くん"),
        AppInfoItem(title: "バージョン", value: "1.0.0"),
        AppInfoItem(title: "対象", value: "第二種電気工事士 筆記試験"),
        AppInfoItem(title: "データ保存", value: "端末内保存"),
        AppInfoItem(title: "ログイン", value: "なし")
    ]

    func resetLearningData(modelContext: ModelContext) {
        do {
            try deleteAllAnswerHistories(modelContext: modelContext)
            try deleteAllReviewStatuses(modelContext: modelContext)
            try deleteAllStudyGoals(modelContext: modelContext)
            try resetQuestions(modelContext: modelContext)

            try modelContext.save()

            successMessage = "学習データを削除しました。"
            errorMessage = nil
        } catch {
            successMessage = nil
            errorMessage = "データリセットに失敗しました。"
        }
    }

    private func deleteAllAnswerHistories(modelContext: ModelContext) throws {
        let histories = try modelContext.fetch(FetchDescriptor<AnswerHistory>())
        histories.forEach { modelContext.delete($0) }
    }

    private func deleteAllReviewStatuses(modelContext: ModelContext) throws {
        let reviewStatuses = try modelContext.fetch(FetchDescriptor<ReviewStatus>())
        reviewStatuses.forEach { modelContext.delete($0) }
    }

    private func deleteAllStudyGoals(modelContext: ModelContext) throws {
        let goals = try modelContext.fetch(FetchDescriptor<StudyGoal>())
        goals.forEach { modelContext.delete($0) }
    }

    private func resetQuestions(modelContext: ModelContext) throws {
        let questions = try modelContext.fetch(FetchDescriptor<Question>())
        let now = Date()

        for question in questions {
            switch question.sourceType {
            case .initial:
                if question.isDeleted {
                    question.isDeleted = false
                    question.updatedAt = now
                }
            case .userCreated:
                question.markAsDeleted(at: now)
            }
        }
    }
}
