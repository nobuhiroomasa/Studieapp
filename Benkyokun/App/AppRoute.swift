import Foundation

enum AppRoute: Hashable {
    case quizSetting
    case quiz
    case answerResult
    case quizComplete
    case review
    case questionCreate
    case questionEdit(questionId: UUID)
    case questionList
    case studyRecord
    case goalSetting
    case settings
}
