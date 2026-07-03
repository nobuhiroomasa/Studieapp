import SwiftUI

struct SecondaryButton: View {
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
            .background(Color.appCardBackground)
            .foregroundStyle(foregroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1.2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isDisabled)
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        isDisabled ? Color.appTextSecondary : Color.appPrimary
    }

    private var borderColor: Color {
        isDisabled ? Color.gray.opacity(0.25) : Color.appPrimary.opacity(0.75)
    }
}
