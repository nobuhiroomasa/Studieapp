import Foundation
import Observation
import SwiftData

@Observable
final class HomeViewModel {
    private(set) var summary = StudyStatsSummary.empty()
    private(set) var reviewTargetCount = 0
    private(set) var errorMessage: String?

    private(set) var examDate: Date?
    private(set) var dailyQuestionTarget = 10
    private(set) var totalQuestionTarget = 300
    private(set) var targetAccuracyPercent = 80.0

    var todayAnswerCountText: String {
        "\(summary.todayAnswerCount)問"
    }

    var dailyQuestionTargetText: String {
        "\(dailyQuestionTarget)問"
    }

    var todayProgress: Double {
        GoalProgressService.todayTargetProgress(
            answeredCount: summary.todayAnswerCount,
            dailyQuestionTarget: dailyQuestionTarget
        )
    }

    var todayProgressPercentText: String {
        (todayProgress * 100).percentText
    }

    var examDaysText: String {
        guard let daysUntilExam = GoalProgressService.daysUntilExam(examDate: examDate) else {
            return "試験日未設定"
        }

        return "あと\(daysUntilExam)日"
    }

    var examDateSubtitleText: String {
        guard let examDate else {
            return "目標を設定しましょう"
        }

        return examDate.formatted(date: .abbreviated, time: .omitted)
    }

    var overallAccuracyText: String {
        summary.overallAccuracyPercent.percentText
    }

    var overallAccuracySubtitleText: String {
        "目標 \(targetAccuracyPercent.percentText)"
    }

    var consecutiveStudyDayCountText: String {
        "\(summary.consecutiveStudyDayCount)日"
    }

    var totalAnswerCountText: String {
        "\(summary.totalAnswerCount)問"
    }

    var reviewTargetCountText: String {
        "\(reviewTargetCount)問"
    }

    var hasNoAnswerHistory: Bool {
        summary.totalAnswerCount == 0
    }

    func load(modelContext: ModelContext) {
        do {
            summary = try StudyStatsService.fetchSummary(modelContext: modelContext)
            reviewTargetCount = try ReviewService.fetchReviewTargets(modelContext: modelContext).count

            if let goal = try StudyGoalRepository.fetchGoal(modelContext: modelContext) {
                examDate = goal.examDate
                dailyQuestionTarget = goal.dailyQuestionTarget
                totalQuestionTarget = goal.totalQuestionTarget
                targetAccuracyPercent = goal.targetAccuracyPercent
            } else {
                examDate = nil
                dailyQuestionTarget = 10
                totalQuestionTarget = 300
                targetAccuracyPercent = 80.0
            }

            errorMessage = nil
        } catch {
            summary = StudyStatsSummary.empty()
            reviewTargetCount = 0
            examDate = nil
            dailyQuestionTarget = 10
            totalQuestionTarget = 300
            targetAccuracyPercent = 80.0
            errorMessage = "ホームの学習状況を読み込めませんでした。"
        }
    }
}
