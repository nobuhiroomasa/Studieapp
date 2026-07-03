import Foundation
import SwiftData

struct GoalProgressService {
    static func daysUntilExam(
        examDate: Date?,
        from currentDate: Date = Date()
    ) -> Int? {
        guard let examDate else {
            return nil
        }

        return max(0, DateCalculator.days(from: currentDate, to: examDate))
    }

    static func todayAnswerCount(
        modelContext: ModelContext,
        date: Date = Date()
    ) throws -> Int {
        let startOfDay = date.startOfDay
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        let descriptor = FetchDescriptor<AnswerHistory>(
            predicate: #Predicate<AnswerHistory> { history in
                history.answeredAt >= startOfDay && history.answeredAt < endOfDay
            }
        )

        return try modelContext.fetchCount(descriptor)
    }

    static func totalAnswerCount(modelContext: ModelContext) throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<AnswerHistory>())
    }

    static func todayTargetProgress(
        goal: StudyGoal,
        modelContext: ModelContext,
        date: Date = Date()
    ) throws -> Double {
        let answeredCount = try todayAnswerCount(
            modelContext: modelContext,
            date: date
        )

        return todayTargetProgress(
            answeredCount: answeredCount,
            dailyQuestionTarget: goal.dailyQuestionTarget
        )
    }

    static func totalAnswerProgress(
        goal: StudyGoal,
        modelContext: ModelContext
    ) throws -> Double {
        let answeredCount = try totalAnswerCount(modelContext: modelContext)

        return totalAnswerProgress(
            answeredCount: answeredCount,
            totalQuestionTarget: goal.totalQuestionTarget
        )
    }

    static func todayTargetProgress(
        answeredCount: Int,
        dailyQuestionTarget: Int
    ) -> Double {
        progressRatio(
            currentValue: answeredCount,
            targetValue: dailyQuestionTarget
        )
    }

    static func totalAnswerProgress(
        answeredCount: Int,
        totalQuestionTarget: Int
    ) -> Double {
        progressRatio(
            currentValue: answeredCount,
            targetValue: totalQuestionTarget
        )
    }

    private static func progressRatio(
        currentValue: Int,
        targetValue: Int
    ) -> Double {
        guard targetValue > 0 else {
            return 0
        }

        return min(Double(currentValue) / Double(targetValue), 1)
    }
}
