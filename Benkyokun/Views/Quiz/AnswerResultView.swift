import SwiftUI

struct AnswerResultView: View {
    let viewModel: QuizSessionViewModel
    let onNext: () -> Void

    var body: some View {
        Group {
            if let result = viewModel.currentAnswerResult {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        resultHeader(result)
                        answerComparison(result)
                        explanation(result)

                        if result.isCorrect == false {
                            reviewAddedMessage
                        }

                        PrimaryButton(
                            title: viewModel.hasNextQuestion ? "次の問題へ" : "結果を見る",
                            systemImage: viewModel.hasNextQuestion ? "arrow.right" : "flag.checkered",
                            action: onNext
                        )
                    }
                    .padding(16)
                }
            } else {
                EmptyStateView(
                    title: "回答結果がありません",
                    message: "問題演習から回答してください。",
                    systemImage: "checkmark.circle"
                )
                .padding(16)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("回答結果")
        .navigationBarBackButtonHidden(true)
    }

    private func resultHeader(_ result: QuizAnswerResult) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 16) {
                Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 68, height: 68)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    Text(result.isCorrect ? "正解！" : "不正解")
                        .font(.title.bold())
                        .foregroundStyle(.white)

                    Text(result.isCorrect ? "いいペースです！" : "復習して覚えましょう")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.92))
                }

                Spacer(minLength: 0)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(result.isCorrect ? Color.appSuccess : Color.appError)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: (result.isCorrect ? Color.appSuccess : Color.appError).opacity(0.18), radius: 12, x: 0, y: 6)
    }

    private func answerComparison(_ result: QuizAnswerResult) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                ResultRow(
                    title: "あなたの回答",
                    option: result.selectedOption,
                    text: result.question.optionText(for: result.selectedOption),
                    color: result.isCorrect ? Color.appSuccess : Color.appError
                )

                Divider()

                ResultRow(
                    title: "正解",
                    option: result.correctOption,
                    text: result.question.optionText(for: result.correctOption),
                    color: Color.appSuccess
                )
            }
        }
    }

    private func explanation(_ result: QuizAnswerResult) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("解説", systemImage: "lightbulb")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                Text(result.question.explanation)
                    .font(.body)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var reviewAddedMessage: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .font(.title3)
                .foregroundStyle(Color.appError)

            VStack(alignment: .leading, spacing: 4) {
                Text("復習リストに追加しました")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                Text("あとで復習画面から解き直せます。")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.appErrorLight)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.appError.opacity(0.18), lineWidth: 1)
        }
    }
}

private struct ResultRow: View {
    let title: String
    let option: AnswerOption
    let text: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextSecondary)

            HStack(alignment: .top, spacing: 10) {
                Text(option.rawValue)
                    .font(.headline.bold())
                    .frame(width: 34, height: 34)
                    .background(color.opacity(0.16))
                    .foregroundStyle(color)
                    .clipShape(Circle())

                Text(text)
                    .font(.body)
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
        }
    }
}
