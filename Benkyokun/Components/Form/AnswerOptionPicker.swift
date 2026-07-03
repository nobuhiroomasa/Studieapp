import SwiftUI

struct AnswerOptionPicker: View {
    @Binding var selectedOption: AnswerOption

    var body: some View {
        Picker("正解", selection: $selectedOption) {
            ForEach(AnswerOption.allCases) { option in
                Text(option.rawValue)
                    .tag(option)
            }
        }
    }
}
