import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        MainTabView()
            .task {
                do {
                    try SampleDataSeeder.seedIfNeeded(modelContext: modelContext)
                } catch {
                    assertionFailure("Failed to seed sample questions: \(error)")
                }
            }
    }
}
