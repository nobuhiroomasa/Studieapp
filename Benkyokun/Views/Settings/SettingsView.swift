import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = SettingsViewModel()
    @State private var showsResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let errorMessage = viewModel.errorMessage {
                    ErrorMessageView(message: errorMessage)
                }

                if let successMessage = viewModel.successMessage {
                    SettingsSuccessMessage(message: successMessage)
                }

                menuSection
                appInfoSection
            }
            .padding(16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("設定")
        .confirmationDialog(
            "すべての学習データを削除しますか？",
            isPresented: $showsResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("削除する", role: .destructive) {
                viewModel.resetLearningData(modelContext: modelContext)
            }

            Button("キャンセル", role: .cancel) {
            }
        } message: {
            Text("初期問題は削除されません。回答履歴、復習状態、目標設定、追加問題をリセットします。")
        }
    }

    private var menuSection: some View {
        AppCard {
            VStack(spacing: 0) {
                NavigationLink {
                    GoalSettingView()
                } label: {
                    SettingsRow(title: "目標設定", systemImage: "target")
                }
                .buttonStyle(.plain)

                Divider()

                NavigationLink {
                    QuestionListView()
                } label: {
                    SettingsRow(title: "問題一覧", systemImage: "list.bullet.rectangle")
                }
                .buttonStyle(.plain)

                Divider()

                DestructiveButton(
                    title: "データリセット",
                    systemImage: "trash"
                ) {
                    showsResetConfirmation = true
                }
            }
        }
    }

    private var appInfoSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("アプリ情報", systemImage: "info.circle")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                VStack(spacing: 10) {
                    ForEach(viewModel.appInfoItems) { item in
                        SettingsInfoRow(item: item)
                    }
                }
            }
        }
    }
}

private struct SettingsInfoRow: View {
    let item: AppInfoItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(item.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 88, alignment: .leading)

            Text(item.value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct SettingsSuccessMessage: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundStyle(Color.appSuccess)

            Text(message)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appSuccess)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSuccessLight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appSuccess.opacity(0.18), lineWidth: 1)
        }
    }
}
