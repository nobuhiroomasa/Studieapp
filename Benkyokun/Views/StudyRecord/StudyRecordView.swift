import SwiftData
import SwiftUI

struct StudyRecordView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = StudyRecordViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let errorMessage = viewModel.errorMessage {
                    ErrorMessageView(message: errorMessage)
                }

                if viewModel.isEmpty {
                    EmptyStateView(
                        title: "学習記録はまだありません",
                        message: "問題を解くと、ここに学習記録が表示されます。",
                        systemImage: "chart.bar"
                    )
                } else {
                    summarySection
                    todaySection
                    goalSection
                    dailyAnswerSection
                    categoryAccuracySection
                }
            }
            .padding(16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("記録")
        .onAppear {
            viewModel.load(modelContext: modelContext)
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            StudyRecordSectionTitle(title: "全体", systemImage: "sum")

            LazyVGrid(columns: gridColumns, spacing: 12) {
                StatCard(
                    title: "累計回答数",
                    value: viewModel.totalAnswerCountText,
                    systemImage: "number"
                )

                StatCard(
                    title: "総合正答率",
                    value: viewModel.overallAccuracyText,
                    subtitle: "目標 \(viewModel.targetAccuracyPercent.percentText)",
                    systemImage: "percent"
                )

                StatCard(
                    title: "正解数",
                    value: viewModel.correctCountText,
                    systemImage: "checkmark.circle"
                )

                StatCard(
                    title: "不正解数",
                    value: viewModel.incorrectCountText,
                    systemImage: "xmark.circle"
                )
            }
        }
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            StudyRecordSectionTitle(title: "今日", systemImage: "calendar")

            LazyVGrid(columns: gridColumns, spacing: 12) {
                StatCard(
                    title: "今日の回答数",
                    value: viewModel.todayAnswerCountText,
                    subtitle: "目標 \(viewModel.dailyQuestionTarget)問",
                    systemImage: "pencil"
                )

                StatCard(
                    title: "今日の正答率",
                    value: viewModel.todayAccuracyText,
                    subtitle: "今日の正解 \(viewModel.summary.todayCorrectCount)問",
                    systemImage: "target"
                )
            }
        }
    }

    private var goalSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                StudyRecordSectionTitle(title: "目標達成率", systemImage: "flag.checkered")

                GoalProgressChart(items: viewModel.goalProgressItems)
            }
        }
    }

    private var dailyAnswerSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                StudyRecordSectionTitle(title: "直近7日の日別回答数", systemImage: "chart.bar")

                DailyAnswerBarChart(data: viewModel.summary.dailyAnswerCounts)
            }
        }
    }

    private var categoryAccuracySection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                StudyRecordSectionTitle(title: "分野別正答率", systemImage: "square.grid.2x2")

                CategoryAccuracyChart(stats: viewModel.summary.categoryStats)
            }
        }
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }
}

private struct StudyRecordSectionTitle: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
    }
}
