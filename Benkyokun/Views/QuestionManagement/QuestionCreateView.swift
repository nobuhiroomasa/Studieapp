import SwiftData
import SwiftUI

struct QuestionCreateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = QuestionFormViewModel()

    var body: some View {
        QuestionFormView(
            viewModel: viewModel,
            submitTitle: "保存する",
            onSubmit: save
        )
        .navigationTitle("問題追加")
    }

    private func save() {
        guard let input = viewModel.makeValidatedInput() else {
            return
        }

        do {
            try QuestionRepository.addQuestion(
                input: input,
                modelContext: modelContext
            )
            dismiss()
        } catch {
            viewModel.setRepositoryError(error)
        }
    }
}
