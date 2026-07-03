import SwiftData
import SwiftUI

struct QuestionListView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = QuestionListViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: QuestionCategory = .all
    @State private var selectedSourceFilter: QuestionSourceFilter = .all

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                searchSection
                categoryFilterSection
                sourceFilterSection

                if let errorMessage = viewModel.errorMessage {
                    ErrorMessageView(message: errorMessage)
                }

                if viewModel.questions.isEmpty {
                    EmptyStateView(
                        title: "問題がありません",
                        message: "検索条件を変更するか、問題を追加してください。",
                        systemImage: "doc.text"
                    )
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.questions, id: \.id) { question in
                            NavigationLink {
                                QuestionEditView(question: question)
                            } label: {
                                QuestionListRow(question: question)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("問題一覧")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    QuestionCreateView()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear(perform: loadQuestions)
        .onChange(of: searchText) { _, _ in
            loadQuestions()
        }
        .onChange(of: selectedCategory) { _, _ in
            loadQuestions()
        }
        .onChange(of: selectedSourceFilter) { _, _ in
            loadQuestions()
        }
    }

    private var header: some View {
        AppCard {
            HStack(spacing: 12) {
                Image(systemName: "list.bullet.rectangle")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(Color.appPrimaryLight)
                    .foregroundStyle(Color.appPrimary)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("登録済み問題")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    Text("\(viewModel.questionCount)問")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var searchSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("検索", systemImage: "magnifyingglass")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                TextField("問題文・選択肢・解説を検索", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .padding(12)
                    .background(Color.appBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    }
            }
        }
    }

    private var categoryFilterSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("分野", systemImage: "square.grid.2x2")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], alignment: .leading, spacing: 8) {
                    ForEach(QuestionCategory.allCases) { category in
                        CategoryChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }

    private var sourceFilterSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("問題種別", systemImage: "tag")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: 8) {
                    ForEach(QuestionSourceFilter.allCases) { sourceFilter in
                        CategoryChip(
                            title: sourceFilter.rawValue,
                            isSelected: selectedSourceFilter == sourceFilter
                        ) {
                            selectedSourceFilter = sourceFilter
                        }
                    }
                }
            }
        }
    }

    private func loadQuestions() {
        viewModel.load(
            searchText: searchText,
            category: selectedCategory,
            sourceFilter: selectedSourceFilter,
            modelContext: modelContext
        )
    }
}

private struct QuestionListRow: View {
    let question: Question

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 8) {
                    CategoryChip(title: question.category.rawValue, isSelected: true)

                    Text(question.sourceType.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(sourceBackgroundColor)
                        .foregroundStyle(sourceForegroundColor)
                        .clipShape(Capsule())

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextSecondary)
                }

                Text(question.questionText)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 8) {
                    Text("正解 \(question.correctOption.rawValue)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appSuccess)

                    Text("更新 \(question.updatedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var sourceBackgroundColor: Color {
        question.sourceType == .initial ? Color.appPrimaryLight : Color.appSuccessLight
    }

    private var sourceForegroundColor: Color {
        question.sourceType == .initial ? Color.appPrimary : Color.appSuccess
    }
}
