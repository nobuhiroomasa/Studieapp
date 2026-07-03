import SwiftUI

struct QuizCompleteView: View {
    let viewModel: QuizSessionViewModel
    let onRetry: () -> Void
    let onReview: () -> Void
    let onHome: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(Color.appWarning)
                        .frame(width: 88, height: 88)
                        .background(Color.appWarning.opacity(0.12))
                        .clipShape(Circle())

                    Text("演習完了")
                        .font(.title.bold())
                        .foregroundStyle(Color.appTextPrimary)

                    Text("今回の結果を確認しましょう")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

                AppCard {
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("正答率")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.appTextSecondary)

                            Text(viewModel.accuracyPercent.percentText)
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.appPrimary)
                        }
                        .frame(maxWidth: .infinity)

                        Divider()

                        HStack(spacing: 10) {
                            ResultMiniCard(title: "解いた問題", value: "\(viewModel.answeredCount)問")
                            ResultMiniCard(title: "正解", value: "\(viewModel.correctCount)問", color: Color.appSuccess)
                            ResultMiniCard(title: "不正解", value: "\(viewModel.incorrectCount)問", color: Color.appError)
                        }
                    }
                }

                VStack(spacing: 10) {
                    PrimaryButton(
                        title: "もう一度解く",
                        systemImage: "arrow.clockwise",
                        action: onRetry
                    )

                    SecondaryButton(
                        title: "復習する",
                        systemImage: "arrow.counterclockwise",
                        action: onReview
                    )

                    SecondaryButton(
                        title: "ホームへ戻る",
                        systemImage: "house",
                        action: onHome
                    )
                }
            }
            .padding(16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("演習完了")
        .navigationBarBackButtonHidden(true)
    }
}

private struct ResultMiniCard: View {
    let title: String
    let value: String
    var color: Color = Color.appTextPrimary

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
