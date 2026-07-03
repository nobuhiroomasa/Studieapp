import SwiftUI

struct CategoryChip: View {
    let title: String
    var isSelected = false
    var action: (() -> Void)? = nil

    var body: some View {
        if let action {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var content: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .overlay {
                Capsule()
                    .stroke(borderColor, lineWidth: 1)
            }
            .clipShape(Capsule())
            .contentShape(Capsule())
    }

    private var backgroundColor: Color {
        isSelected ? Color.appPrimary : Color.appCardBackground
    }

    private var foregroundColor: Color {
        isSelected ? Color.white : Color.appTextSecondary
    }

    private var borderColor: Color {
        isSelected ? Color.appPrimary : Color.gray.opacity(0.28)
    }
}
