import Foundation
import SwiftData

struct ReviewTargetItem: Identifiable {
    let question: Question
    let reviewStatus: ReviewStatus

    var id: UUID {
        question.id
    }
}

struct ReviewService {
    static func fetchReviewTargets(modelContext: ModelContext) throws -> [ReviewTargetItem] {
        let reviewDescriptor = FetchDescriptor<ReviewStatus>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        let activeStatuses = try modelContext.fetch(reviewDescriptor)
            .filter { $0.isReviewTarget }

        let questionDescriptor = FetchDescriptor<Question>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        let questions = try modelContext.fetch(questionDescriptor)
            .filter { $0.isDeleted == false }

        let questionsById = Dictionary(
            uniqueKeysWithValues: questions.map { ($0.id, $0) }
        )

        var seenQuestionIds = Set<UUID>()

        return activeStatuses.compactMap { status in
            guard seenQuestionIds.contains(status.questionId) == false,
                  let question = questionsById[status.questionId] else {
                return nil
            }

            seenQuestionIds.insert(status.questionId)
            return ReviewTargetItem(question: question, reviewStatus: status)
        }
    }
}
