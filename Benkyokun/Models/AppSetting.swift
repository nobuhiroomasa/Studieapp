import Foundation
import SwiftData

@Model
final class AppSetting {
    @Attribute(.unique) var id: UUID

    var hasSeededSampleQuestions: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        hasSeededSampleQuestions: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.hasSeededSampleQuestions = hasSeededSampleQuestions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
