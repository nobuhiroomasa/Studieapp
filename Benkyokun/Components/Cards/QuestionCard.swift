import SwiftUI

struct QuestionCard: View {
    let category: QuestionCategory
    let questionText: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                CategoryChip(title: category.rawValue)
                Text(questionText)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
