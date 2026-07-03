import SwiftData
import SwiftUI

@main
struct BenkyokunApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Question.self,
            AnswerHistory.self,
            ReviewStatus.self,
            StudyGoal.self,
            AppSetting.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
