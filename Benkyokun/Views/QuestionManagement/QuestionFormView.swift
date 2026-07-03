import SwiftUI

struct QuestionFormView: View {
    @Bindable var viewModel: QuestionFormViewModel
    let submitTitle: String
    let onSubmit: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let errorMessage = viewModel.errorMessage {
                    ErrorMessageView(message: errorMessage)
                }

                textEditorSection(
                    title: "問題文",
                    systemImage: "questionmark.circle",
                    text: $viewModel.questionText,
                    minHeight: 150
                )

                optionSection
                correctOptionSection
                categorySection

                textEditorSection(
                    title: "解説",
                    systemImage: "lightbulb",
                    text: $viewModel.explanation,
                    minHeight: 130
                )

                PrimaryButton(
                    title: submitTitle,
                    systemImage: "checkmark",
                    action: onSubmit
                )
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
    }

    private var optionSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                QuestionFormSectionTitle(title: "選択肢", systemImage: "list.bullet")

                VStack(spacing: 10) {
                    optionTextField(title: "選択肢A", text: $viewModel.optionA)
                    optionTextField(title: "選択肢B", text: $viewModel.optionB)
                    optionTextField(title: "選択肢C", text: $viewModel.optionC)
                    optionTextField(title: "選択肢D", text: $viewModel.optionD)
                }
            }
        }
    }

    private var correctOptionSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                QuestionFormSectionTitle(title: "正解", systemImage: "checkmark.circle")

                HStack(spacing: 8) {
                    ForEach(AnswerOption.allCases) { option in
                        CategoryChip(
                            title: option.rawValue,
                            isSelected: viewModel.correctOption == option
                        ) {
                            viewModel.correctOption = option
                            viewModel.errorMessage = nil
                        }
                    }
                }
            }
        }
    }

    private var categorySection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                QuestionFormSectionTitle(title: "分野", systemImage: "square.grid.2x2")

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], alignment: .leading, spacing: 8) {
                    ForEach(QuestionCategory.storableCases) { category in
                        CategoryChip(
                            title: category.rawValue,
                            isSelected: viewModel.category == category
                        ) {
                            viewModel.category = category
                            viewModel.errorMessage = nil
                        }
                    }
                }
            }
        }
    }

    private func textEditorSection(
        title: String,
        systemImage: String,
        text: Binding<String>,
        minHeight: CGFloat
    ) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                QuestionFormSectionTitle(title: title, systemImage: systemImage)

                TextEditor(text: text)
                    .frame(minHeight: minHeight)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(Color.appBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    }
            }
        }
    }

    private func optionTextField(title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .textInputAutocapitalization(.never)
            .submitLabel(.next)
            .padding(12)
            .background(Color.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }
    }
}

private struct QuestionFormSectionTitle: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
    }
}
