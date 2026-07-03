import SwiftData
import SwiftUI

struct QuizSettingView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedQuizMode: QuizMode = .random
    @State private var selectedCategory: QuestionCategory = .all
    @State private var selectedQuestionCount: Int? = 10
    @State private var errorMessage: String?
    @State private var sessionViewModel: QuizSessionViewModel?
    @State private var isSessionPresented = false

    private let categoryColumns = [
        GridItem(.adaptive(minimum: 96), spacing: 8)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("問題演習")
                        .font(.title2.bold())
                        .foregroundStyle(Color.appTextPrimary)

                    Text("出題条件を選んで学習を始めましょう")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }

                quizModeSection
                categorySection
                questionCountSection

                if let errorMessage {
                    ErrorMessageView(message: errorMessage)
                }
            }
            .padding(16)
            .padding(.bottom, 88)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("問題演習")
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()

                PrimaryButton(
                    title: "この条件で開始",
                    systemImage: "play.fill",
                    action: startQuiz
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)
            }
            .background(Color.appBackground)
        }
        .navigationDestination(isPresented: $isSessionPresented) {
            if let sessionViewModel {
                QuizSessionRootView(viewModel: sessionViewModel)
            }
        }
    }

    private var quizModeSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "出題方法", systemImage: "questionmark.circle")

                VStack(spacing: 10) {
                    ForEach(QuizMode.allCases) { mode in
                        SelectionRow(
                            title: mode.rawValue,
                            systemImage: systemImage(for: mode),
                            isSelected: selectedQuizMode == mode
                        ) {
                            selectedQuizMode = mode
                            errorMessage = nil
                        }
                    }
                }
            }
        }
    }

    private var categorySection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "分野", systemImage: "square.grid.2x2")

                LazyVGrid(columns: categoryColumns, alignment: .leading, spacing: 8) {
                    ForEach(QuestionCategory.allCases) { category in
                        CategoryChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                            errorMessage = nil
                        }
                    }
                }
            }
        }
    }

    private var questionCountSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "問題数", systemImage: "number")

                HStack(spacing: 8) {
                    ForEach([5, 10, 20], id: \.self) { count in
                        CategoryChip(
                            title: "\(count)問",
                            isSelected: selectedQuestionCount == count
                        ) {
                            selectedQuestionCount = count
                            errorMessage = nil
                        }
                    }

                    CategoryChip(
                        title: "無制限",
                        isSelected: selectedQuestionCount == nil
                    ) {
                        selectedQuestionCount = nil
                        errorMessage = nil
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func startQuiz() {
        do {
            let questions = try QuizService.fetchQuestions(
                mode: selectedQuizMode,
                category: selectedCategory,
                questionCount: selectedQuestionCount,
                modelContext: modelContext
            )

            guard questions.isEmpty == false else {
                errorMessage = "条件に合う問題がありません。条件を変更してください。"
                return
            }

            sessionViewModel = QuizSessionViewModel(questions: questions, mode: selectedQuizMode)
            isSessionPresented = true
        } catch {
            errorMessage = "問題の取得に失敗しました。もう一度お試しください。"
        }
    }

    private func systemImage(for mode: QuizMode) -> String {
        switch mode {
        case .random:
            return "shuffle"
        case .category:
            return "folder"
        case .review:
            return "arrow.counterclockwise"
        }
    }
}

private enum QuizSessionScreen {
    case quiz
    case result
    case complete
    case review
    case home
}

struct QuizSessionRootView: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: QuizSessionViewModel
    @State private var screen: QuizSessionScreen = .quiz

    var body: some View {
        Group {
            switch screen {
            case .quiz:
                QuizView(
                    viewModel: viewModel,
                    onAnswered: {
                        screen = .result
                    },
                    onFinishEarly: {
                        viewModel.finishEarly()
                        screen = .complete
                    }
                )
            case .result:
                AnswerResultView(
                    viewModel: viewModel,
                    onNext: {
                        viewModel.moveToNextQuestion()
                        screen = viewModel.isCompleted ? .complete : .quiz
                    }
                )
            case .complete:
                QuizCompleteView(
                    viewModel: viewModel,
                    onRetry: {
                        dismiss()
                    },
                    onReview: {
                        screen = .review
                    },
                    onHome: {
                        screen = .home
                    }
                )
            case .review:
                ReviewView()
            case .home:
                HomeView()
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

private struct SectionTitle: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
    }
}

private struct SelectionRow: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? Color.appPrimary : Color.appPrimaryLight)
                    .foregroundStyle(isSelected ? Color.white : Color.appPrimary)
                    .clipShape(Circle())

                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.appPrimary : Color.gray.opacity(0.35))
            }
            .padding(12)
            .background(isSelected ? Color.appPrimaryLight : Color.appCardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.appPrimary : Color.gray.opacity(0.18), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
