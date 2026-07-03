import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedCategory: QuestionCategory

    var body: some View {
        Picker("分野", selection: $selectedCategory) {
            ForEach(QuestionCategory.storableCases) { category in
                Text(category.rawValue)
                    .tag(category)
            }
        }
    }
}
