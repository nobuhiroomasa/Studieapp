import Foundation
import Observation
import SwiftData

@Observable
final class StudyRecordViewModel {
    private(set) var summary = StudyStatsSummary.empty()
    private(set) var errorMessage: String?

    private(set) var dailyQuestionTarget = 10
    private(set) var totalQuestionTarget = 300
    private(set) var targetAccuracyPercent = 80.0

    var isEmpty: Bool {
        summary.totalAnswerCount == 0
    }

    var totalAnswerCountText: String {
        "\(summary.totalAnswerCount)問"
    }

    var correctCountText: String {
        "\(summary.correctCount)問"
    }

    var incorrectCountText: String {
        "\(summary.incorrectCount)問"
    }

    var overallAccuracyText: String {
        summary.overallAccuracyPercent.percentText
    }

    var todayAnswerCountText: String {
        "\(summary.todayAnswerCount)問"
    }

    var todayAccuracyText: String {
        summary.todayAccuracyPercent.percentText
    }

    var todayGoalProgress: Double {
        GoalProgressService.todayTargetProgress(
            answeredCount: summary.todayAnswerCount,
            dailyQuestionTarget: dailyQuestionTarget
        )
    }

    var totalGoalProgress: Double {
        GoalProgressService.totalAnswerProgress(
            answeredCount: summary.totalAnswerCount,
            totalQuestionTarget: totalQuestionTarget
        )
    }

    var goalProgressItems: [GoalProgressItem] {
        [
            GoalProgressItem(
                title: "今日の目標",
                currentText: "\(summary.todayAnswerCount)問",
                targetText: "\(dailyQuestionTarget)問",
                progress: todayGoalProgress
            ),
            GoalProgressItem(
                title: "総回答数目標",
                currentText: "\(summary.totalAnswerCount)問",
                targetText: "\(totalQuestionTarget)問",
                progress: totalGoalProgress
            )
        ]
    }

    func load(modelContext: ModelContext) {
        do {
            summary = try StudyStatsService.fetchSummary(modelContext: modelContext)

            if let goal = try StudyGoalRepository.fetchGoal(modelContext: modelContext) {
                dailyQuestionTarget = goal.dailyQuestionTarget
                totalQuestionTarget = goal.totalQuestionTarget
                targetAccuracyPercent = goal.targetAccuracyPercent
            } else {
                dailyQuestionTarget = 10
                totalQuestionTarget = 300
                targetAccuracyPercent = 80.0
            }

            errorMessage = nil
        } catch {
            summary = StudyStatsSummary.empty()
            errorMessage = "学習記録を読み込めませんでした。"
        }
    }
}
