import SwiftData
import SwiftUI

struct QuestionEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let question: Question
    @State private var viewModel: QuestionFormViewModel
    @State private var showsDeleteConfirmation = false

    init(question: Question) {
        self.question = question
        _viewModel = State(initialValue: QuestionFormViewModel(question: question))
    }

    var body: some View {
        QuestionFormView(
            viewModel: viewModel,
            submitTitle: "更新する",
            onSubmit: save
        )
        .navigationTitle("問題編集")
        .toolbar {
            if canDelete {
                Button(role: .destructive) {
                    showsDeleteConfirmation = true
                } label: {
                    Label("削除", systemImage: "trash")
                }
            }
        }
        .confirmationDialog(
            "この問題を削除しますか？",
            isPresented: $showsDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("削除する", role: .destructive) {
                deleteQuestion()
            }
            Button("キャンセル", role: .cancel) {
            }
        } message: {
            Text("削除しても回答履歴は残ります。")
        }
    }

    private var canDelete: Bool {
        question.sourceType == .userCreated
    }

    private func save() {
        guard let input = viewModel.makeValidatedInput() else {
            return
        }

        do {
            try QuestionRepository.updateQuestion(
                question,
                input: input,
                modelContext: modelContext
            )
            dismiss()
        } catch {
            viewModel.setRepositoryError(error)
        }
    }

    private func deleteQuestion() {
        do {
            try QuestionRepository.logicallyDelete(
                question,
                modelContext: modelContext
            )
            dismiss()
        } catch {
            viewModel.setRepositoryError(error)
        }
    }
}
