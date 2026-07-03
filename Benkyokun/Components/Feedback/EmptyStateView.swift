import SwiftUI

struct EmptyStateView: View {
    let title: String
    var message: String? = nil
    var systemImage = "tray"
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .frame(width: 64, height: 64)
                .background(Color.appPrimaryLight)
                .foregroundStyle(Color.appPrimary)
                .clipShape(Circle())

            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)

            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let buttonTitle, let action {
                PrimaryButton(title: buttonTitle, action: action)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
