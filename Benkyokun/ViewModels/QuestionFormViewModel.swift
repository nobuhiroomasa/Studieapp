import Foundation
import Observation

@Observable
final class QuestionFormViewModel {
    var questionText = ""
    var optionA = ""
    var optionB = ""
    var optionC = ""
    var optionD = ""
    var correctOption: AnswerOption?
    var category: QuestionCategory?
    var explanation = ""
    var errorMessage: String?

    init() {
    }

    init(question: Question) {
        questionText = question.questionText
        optionA = question.optionA
        optionB = question.optionB
        optionC = question.optionC
        optionD = question.optionD
        correctOption = question.correctOption
        category = question.category.canBeStoredInQuestion ? question.category : nil
        explanation = question.explanation
    }

    func makeValidatedInput() -> QuestionFormInput? {
        let trimmedQuestionText = questionText.trimmedForSave
        let trimmedOptionA = optionA.trimmedForSave
        let trimmedOptionB = optionB.trimmedForSave
        let trimmedOptionC = optionC.trimmedForSave
        let trimmedOptionD = optionD.trimmedForSave
        let trimmedExplanation = explanation.trimmedForSave

        guard trimmedQuestionText.isEmpty == false else {
            errorMessage = "問題文を入力してください。"
            return nil
        }

        guard trimmedOptionA.isEmpty == false,
              trimmedOptionB.isEmpty == false,
              trimmedOptionC.isEmpty == false,
              trimmedOptionD.isEmpty == false else {
            errorMessage = "選択肢A〜Dをすべて入力してください。"
            return nil
        }

        guard let correctOption else {
            errorMessage = "正解を選択してください。"
            return nil
        }

        guard let category,
              category.canBeStoredInQuestion else {
            errorMessage = "分野を選択してください。"
            return nil
        }

        errorMessage = nil

        return QuestionFormInput(
            questionText: trimmedQuestionText,
            optionA: trimmedOptionA,
            optionB: trimmedOptionB,
            optionC: trimmedOptionC,
            optionD: trimmedOptionD,
            correctOption: correctOption,
            category: category,
            explanation: trimmedExplanation
        )
    }

    func setRepositoryError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
}

private extension String {
    var trimmedForSave: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
