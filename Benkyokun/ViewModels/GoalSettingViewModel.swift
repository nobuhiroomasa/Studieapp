import Foundation
import Observation
import SwiftData

@Observable
final class GoalSettingViewModel {
    var isExamDateEnabled = false
    var examDate = Date()
    var dailyQuestionTarget = 10
    var totalQuestionTarget = 300
    var targetAccuracyPercent = 80.0
    var errorMessage: String?

    private var currentGoal: StudyGoal?

    func load(modelContext: ModelContext) {
        do {
            if let goal = try StudyGoalRepository.fetchGoal(modelContext: modelContext) {
                currentGoal = goal
                isExamDateEnabled = goal.examDate != nil
                examDate = goal.examDate ?? Date()
                dailyQuestionTarget = goal.dailyQuestionTarget
                totalQuestionTarget = goal.totalQuestionTarget
                targetAccuracyPercent = goal.targetAccuracyPercent
            }

            errorMessage = nil
        } catch {
            errorMessage = "目標設定を読み込めませんでした。"
        }
    }

    func save(modelContext: ModelContext) -> Bool {
        guard let input = makeValidatedInput() else {
            return false
        }

        do {
            currentGoal = try StudyGoalRepository.saveGoal(
                input: input,
                modelContext: modelContext
            )
            errorMessage = nil
            return true
        } catch {
            errorMessage = "目標設定を保存できませんでした。"
            return false
        }
    }

    private func makeValidatedInput() -> StudyGoalInput? {
        let selectedExamDate = isExamDateEnabled ? examDate.startOfDay : nil

        if let selectedExamDate,
           selectedExamDate < Date().startOfDay {
            errorMessage = "試験日は今日以降の日付を設定してください。"
            return nil
        }

        guard dailyQuestionTarget >= 1 else {
            errorMessage = "1日の目標回答数は1問以上にしてください。"
            return nil
        }

        guard totalQuestionTarget >= 1 else {
            errorMessage = "目標総回答数は1問以上にしてください。"
            return nil
        }

        guard (1...100).contains(targetAccuracyPercent) else {
            errorMessage = "目標正答率は1〜100%で設定してください。"
            return nil
        }

        errorMessage = nil

        return StudyGoalInput(
            examDate: selectedExamDate,
            dailyQuestionTarget: dailyQuestionTarget,
            totalQuestionTarget: totalQuestionTarget,
            targetAccuracyPercent: targetAccuracyPercent
        )
    }
}
