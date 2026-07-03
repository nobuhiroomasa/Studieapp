import SwiftData
import SwiftUI

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = ReviewViewModel()
    @State private var sessionViewModel: QuizSessionViewModel?
    @State private var isReviewSessionPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                if let errorMessage = viewModel.errorMessage {
                    ErrorMessageView(message: errorMessage)
                }

                if viewModel.reviewTargets.isEmpty {
                    EmptyStateView(
                        title: "復習する問題はありません",
                        message: "問題を解いて苦手を見つけましょう。",
                        systemImage: "checkmark.circle"
                    )
                } else {
                    PrimaryButton(
                        title: "復習を開始する",
                        systemImage: "play.fill",
                        isDisabled: viewModel.canStartReview == false,
                        action: startReview
                    )

                    VStack(spacing: 12) {
                        ForEach(viewModel.reviewTargets) { item in
                            ReviewTargetCard(item: item)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("復習")
        .onAppear {
            viewModel.load(modelContext: modelContext)
        }
        .navigationDestination(isPresented: $isReviewSessionPresented) {
            if let sessionViewModel {
                QuizSessionRootView(viewModel: sessionViewModel)
            }
        }
    }

    private var header: some View {
        AppCard {
            HStack(spacing: 14) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(Color.appPrimary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("復習対象")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    Text("\(viewModel.reviewTargetCount)問")
                        .font(.title2.bold())
                        .foregroundStyle(Color.appPrimary)
                }

                Spacer()
            }
        }
    }

    private func startReview() {
        guard viewModel.canStartReview else {
            return
        }

        sessionViewModel = QuizSessionViewModel(
            questions: viewModel.reviewQuestions,
            mode: .review
        )
        isReviewSessionPresented = true
    }
}

private struct ReviewTargetCard: View {
    let item: ReviewTargetItem

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    CategoryChip(title: item.question.category.rawValue, isSelected: true)
                    Spacer()
                    Text("不正解 \(item.reviewStatus.wrongCount)回")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appError)
                }

                Text(item.question.questionText)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("最終不正解: \(lastWrongText)")
                        .font(.caption)
                }
                .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var lastWrongText: String {
        guard let lastWrongAt = item.reviewStatus.lastWrongAt else {
            return "未記録"
        }

        return lastWrongAt.formatted(date: .abbreviated, time: .shortened)
    }
}
