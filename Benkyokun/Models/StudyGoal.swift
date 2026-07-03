import Foundation
import SwiftData

@Model
final class StudyGoal {
    @Attribute(.unique) var id: UUID

    var examDate: Date?
    var dailyQuestionTarget: Int
    var totalQuestionTarget: Int
    var targetAccuracyPercent: Double
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        examDate: Date? = nil,
        dailyQuestionTarget: Int = 10,
        totalQuestionTarget: Int = 300,
        targetAccuracyPercent: Double = 80.0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.examDate = examDate
        self.dailyQuestionTarget = dailyQuestionTarget
        self.totalQuestionTarget = totalQuestionTarget
        self.targetAccuracyPercent = targetAccuracyPercent
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
