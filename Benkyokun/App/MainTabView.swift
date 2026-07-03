import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("ホーム", systemImage: "house")
            }

            NavigationStack {
                QuizSettingView()
            }
            .tabItem {
                Label("問題演習", systemImage: "checkmark.circle")
            }

            NavigationStack {
                ReviewView()
            }
            .tabItem {
                Label("復習", systemImage: "arrow.counterclockwise")
            }

            NavigationStack {
                StudyRecordView()
            }
            .tabItem {
                Label("記録", systemImage: "chart.bar")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("設定", systemImage: "gearshape")
            }
        }
    }
}
