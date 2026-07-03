import SwiftUI

struct DestructiveButton: View {
    let title: String
    var systemImage: String? = nil
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
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

    private var backgroundColor: Color {
        isDisabled ? Color.gray.opacity(0.08) : Color.appErrorLight
    }

    private var foregroundColor: Color {
        isDisabled ? Color.appTextSecondary : Color.appError
    }

    private var borderColor: Color {
        isDisabled ? Color.gray.opacity(0.2) : Color.appError.opacity(0.35)
    }
}
