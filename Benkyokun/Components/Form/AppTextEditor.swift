import SwiftUI

struct AppTextEditor: View {
    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
            .frame(minHeight: 120)
            .padding(8)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
