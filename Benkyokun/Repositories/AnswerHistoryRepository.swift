import Foundation
import SwiftData

struct AnswerHistoryRepository {
    static func fetchAll(modelContext: ModelContext) throws -> [AnswerHistory] {
        let descriptor = FetchDescriptor<AnswerHistory>(
            sortBy: [SortDescriptor(\.answeredAt, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }
}
