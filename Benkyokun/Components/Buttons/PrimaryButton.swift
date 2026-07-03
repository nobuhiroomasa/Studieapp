import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline)
                }

                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
            .padding(.horizontal, 16)
            .background(backgroundColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isDisabled)
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        isDisabled ? Color.gray.opacity(0.35) : Color.appPrimary
    }

    private var shadowColor: Color {
        isDisabled ? Color.clear : Color.appPrimary.opacity(0.22)
    }
}
