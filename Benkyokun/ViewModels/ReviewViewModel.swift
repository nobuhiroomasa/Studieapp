import Foundation
import Observation
import SwiftData

@Observable
final class ReviewViewModel {
    private(set) var reviewTargets: [ReviewTargetItem] = []
    private(set) var errorMessage: String?

    var reviewTargetCount: Int {
        reviewTargets.count
    }

    var reviewQuestions: [Question] {
        reviewTargets.map(\.question)
    }

    var canStartReview: Bool {
        reviewTargets.isEmpty == false
    }

    func load(modelContext: ModelContext) {
        do {
            reviewTargets = try ReviewService.fetchReviewTargets(modelContext: modelContext)
            errorMessage = nil
        } catch {
            reviewTargets = []
            errorMessage = "復習対象を読み込めませんでした。"
        }
    }
}
