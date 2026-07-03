import Foundation
import Observation
import SwiftData

@Observable
final class QuestionListViewModel {
    private(set) var questions: [Question] = []
    private(set) var errorMessage: String?

    var questionCount: Int {
        questions.count
    }

    func load(
        searchText: String,
        category: QuestionCategory,
        sourceFilter: QuestionSourceFilter,
        modelContext: ModelContext
    ) {
        do {
            questions = try QuestionRepository.fetchQuestions(
                searchText: searchText,
                category: category,
                sourceFilter: sourceFilter,
                modelContext: modelContext
            )
            errorMessage = nil
        } catch {
            questions = []
            errorMessage = "問題を読み込めませんでした。"
        }
    }
}
