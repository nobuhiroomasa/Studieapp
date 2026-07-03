import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = HomeViewModel()
    @State private var showsQuizSetting = false
    @State private var showsReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerSection

                if let errorMessage = viewModel.errorMessage {
                    ErrorMessageView(message: errorMessage)
                }

                todayProgressSection
                summarySection
                mainActionSection
                shortcutSection

                if viewModel.hasNoAnswerHistory {
                    EmptyStateView(
                        title: "まずは1問解いてみましょう",
                        message: "問題を解くと、ホームに学習状況が反映されます。",
                        systemImage: "lightbulb",
                        buttonTitle: "問題を解く"
                    ) {
                        showsQuizSetting = true
                    }
                }
            }
            .padding(16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("ホーム")
        .navigationDestination(isPresented: $showsQuizSetting) {
            QuizSettingView()
        }
        .navigationDestination(isPresented: $showsReview) {
            ReviewView()
        }
        .onAppear {
            viewModel.load(modelContext: modelContext)
        }
    }

    private var headerSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("勉強くん")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)

                Text("第二種電気工事士の筆記試験対策")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)

                Text(Date().formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var todayProgressSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("今日の学習状況")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)

                        Text("\(viewModel.todayAnswerCountText) / \(viewModel.dailyQuestionTargetText)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }

                    Spacer(minLength: 0)

                    Text(viewModel.todayProgressPercentText)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.appPrimaryLight)
                        .clipShape(Capsule())
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.appPrimaryLight)

                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.appPrimary)
                            .frame(width: proxy.size.width * min(max(viewModel.todayProgress, 0), 1))
                    }
                }
                .frame(height: 14)
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionTitle(title: "サマリー", systemImage: "chart.bar")

            LazyVGrid(columns: summaryColumns, spacing: 12) {
                StatCard(
                    title: "試験日まで",
                    value: viewModel.examDaysText,
                    subtitle: viewModel.examDateSubtitleText,
                    systemImage: "calendar"
                )

                StatCard(
                    title: "総合正答率",
                    value: viewModel.overallAccuracyText,
                    subtitle: viewModel.overallAccuracySubtitleText,
                    systemImage: "percent"
                )

                StatCard(
                    title: "連続学習日数",
                    value: viewModel.consecutiveStudyDayCountText,
                    systemImage: "flame"
                )

                StatCard(
                    title: "累計回答数",
                    value: viewModel.totalAnswerCountText,
                    systemImage: "number"
                )

                StatCard(
                    title: "復習対象",
                    value: viewModel.reviewTargetCountText,
                    systemImage: "arrow.counterclockwise"
                )
            }
        }
    }

    private var mainActionSection: some View {
        VStack(spacing: 12) {
            PrimaryButton(
                title: "問題を解く",
                systemImage: "checkmark.circle"
            ) {
                showsQuizSetting = true
            }

            SecondaryButton(
                title: "復習する",
                systemImage: "arrow.counterclockwise"
            ) {
                showsReview = true
            }
        }
    }

    private var shortcutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionTitle(title: "ショートカット", systemImage: "square.grid.2x2")

            LazyVGrid(columns: summaryColumns, spacing: 12) {
                NavigationLink {
                    QuestionCreateView()
                } label: {
                    HomeShortcutCard(
                        title: "問題を追加",
                        systemImage: "plus.circle"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    StudyRecordView()
                } label: {
                    HomeShortcutCard(
                        title: "学習記録",
                        systemImage: "chart.bar"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    GoalSettingView()
                } label: {
                    HomeShortcutCard(
                        title: "目標を設定",
                        systemImage: "target"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var summaryColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }
}

private struct HomeShortcutCard: View {
    let title: String
    let systemImage: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(Color.appPrimaryLight)
                    .foregroundStyle(Color.appPrimary)
                    .clipShape(Circle())

                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        }
    }
}

private struct HomeSectionTitle: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
    }
}
