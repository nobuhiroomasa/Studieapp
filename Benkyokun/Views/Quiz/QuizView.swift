import SwiftData
import SwiftUI

struct QuizView: View {
    @Environment(\.modelContext) private var modelContext

    let viewModel: QuizSessionViewModel
    let onAnswered: () -> Void
    let onFinishEarly: () -> Void

    @State private var errorMessage: String?
    @State private var showsFinishConfirmation = false

    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        QuizProgressBar(
                            current: viewModel.currentQuestionNumber,
                            total: viewModel.totalQuestionCount
                        )

                        HStack {
                            CategoryChip(title: question.category.rawValue, isSelected: true)
                            Spacer()
                        }

                        AppCard {
                            Text(question.questionText)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.appTextPrimary)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        VStack(spacing: 10) {
                            ForEach(AnswerOption.allCases) { option in
                                AnswerOptionButton(
                                    option: option,
                                    text: question.optionText(for: option)
                                ) {
                                    answer(option)
                                }
                            }
                        }

                        if let errorMessage {
                            ErrorMessageView(message: errorMessage)
                        }

                        SecondaryButton(
                            title: "演習を終了する",
                            systemImage: "xmark.circle"
                        ) {
                            showsFinishConfirmation = true
                        }
                        .padding(.top, 8)
                    }
                    .padding(16)
                    .padding(.bottom, 16)
                }
            } else {
                EmptyStateView(
                    title: "表示できる問題がありません",
                    message: "条件を変更してもう一度お試しください。",
                    systemImage: "questionmark.circle"
                )
                .padding(16)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("問題演習")
        .navigationBarBackButtonHidden(true)
        .confirmationDialog(
            "演習を終了しますか？",
            isPresented: $showsFinishConfirmation,
            titleVisibility: .visible
        ) {
            Button("終了する", role: .destructive) {
                onFinishEarly()
            }
            Button("続ける", role: .cancel) {
            }
        } message: {
            Text("未回答の問題は結果に含まれません。")
        }
    }

    private func answer(_ option: AnswerOption) {
        do {
            _ = try viewModel.answer(option, modelContext: modelContext)
            onAnswered()
        } catch {
            errorMessage = "回答を保存できませんでした。もう一度お試しください。"
        }
    }
}
