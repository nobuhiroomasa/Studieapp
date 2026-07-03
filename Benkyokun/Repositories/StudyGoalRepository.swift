import Foundation
import SwiftData

struct StudyGoalInput {
    let examDate: Date?
    let dailyQuestionTarget: Int
    let totalQuestionTarget: Int
    let targetAccuracyPercent: Double
}

struct StudyGoalRepository {
    static func fetchGoal(modelContext: ModelContext) throws -> StudyGoal? {
        var descriptor = FetchDescriptor<StudyGoal>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        descriptor.fetchLimit = 1

        return try modelContext.fetch(descriptor).first
    }

    @discardableResult
    static func saveGoal(
        input: StudyGoalInput,
        modelContext: ModelContext
    ) throws -> StudyGoal {
        if let goal = try fetchGoal(modelContext: modelContext) {
            try updateGoal(
                goal,
                input: input,
                modelContext: modelContext
            )
            return goal
        } else {
            return try createGoal(
                input: input,
                modelContext: modelContext
            )
        }
    }

    @discardableResult
    static func createGoal(
        input: StudyGoalInput,
        modelContext: ModelContext
    ) throws -> StudyGoal {
        let now = Date()
        let goal = StudyGoal(
            examDate: input.examDate,
            dailyQuestionTarget: input.dailyQuestionTarget,
            totalQuestionTarget: input.totalQuestionTarget,
            targetAccuracyPercent: input.targetAccuracyPercent,
            createdAt: now,
            updatedAt: now
        )

        modelContext.insert(goal)
        try modelContext.save()
        return goal
    }

    static func updateGoal(
        _ goal: StudyGoal,
        input: StudyGoalInput,
        modelContext: ModelContext
    ) throws {
        goal.examDate = input.examDate
        goal.dailyQuestionTarget = input.dailyQuestionTarget
        goal.totalQuestionTarget = input.totalQuestionTarget
        goal.targetAccuracyPercent = input.targetAccuracyPercent
        goal.updatedAt = Date()

        try modelContext.save()
    }
}
