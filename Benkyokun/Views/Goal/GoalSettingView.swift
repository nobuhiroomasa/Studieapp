import SwiftData
import SwiftUI

struct GoalSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = GoalSettingViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let errorMessage = viewModel.errorMessage {
                    ErrorMessageView(message: errorMessage)
                }

                examDateSection
                targetSection

                PrimaryButton(
                    title: "目標を保存",
                    systemImage: "checkmark"
                ) {
                    save()
                }

                SecondaryButton(
                    title: "キャンセル",
                    systemImage: "xmark"
                ) {
                    dismiss()
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("目標設定")
        .onAppear {
            viewModel.load(modelContext: modelContext)
        }
    }

    private var examDateSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("試験日", systemImage: "calendar")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                Toggle("試験日を設定する", isOn: $viewModel.isExamDateEnabled)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .tint(Color.appPrimary)

                if viewModel.isExamDateEnabled {
                    DatePicker(
                        "試験日",
                        selection: $viewModel.examDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)

                    if let days = GoalProgressService.daysUntilExam(examDate: viewModel.examDate) {
                        Text("試験日まであと\(days)日")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                } else {
                    Text("試験日は未設定です。")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }

    private var targetSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 18) {
                Label("目標", systemImage: "target")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                GoalStepperRow(
                    title: "1日の目標回答数",
                    valueText: "\(viewModel.dailyQuestionTarget)問"
                ) {
                    Stepper(
                        "",
                        value: $viewModel.dailyQuestionTarget,
                        in: 1...999
                    )
                    .labelsHidden()
                }

                Divider()

                GoalStepperRow(
                    title: "目標総回答数",
                    valueText: "\(viewModel.totalQuestionTarget)問"
                ) {
                    Stepper(
                        "",
                        value: $viewModel.totalQuestionTarget,
                        in: 1...9999
                    )
                    .labelsHidden()
                }

                Divider()

                GoalStepperRow(
                    title: "目標正答率",
                    valueText: "\(Int(viewModel.targetAccuracyPercent))%"
                ) {
                    Stepper(
                        "",
                        value: $viewModel.targetAccuracyPercent,
                        in: 1...100,
                        step: 1
                    )
                    .labelsHidden()
                }
            }
        }
    }

    private func save() {
        if viewModel.save(modelContext: modelContext) {
            dismiss()
        }
    }
}

private struct GoalStepperRow<Control: View>: View {
    let title: String
    let valueText: String
    let control: Control

    init(
        title: String,
        valueText: String,
        @ViewBuilder control: () -> Control
    ) {
        self.title = title
        self.valueText = valueText
        self.control = control()
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appTextPrimary)

                Text(valueText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPrimary)
            }

            Spacer(minLength: 0)

            control
        }
    }
}
