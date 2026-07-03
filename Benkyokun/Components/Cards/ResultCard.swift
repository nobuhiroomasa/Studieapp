import SwiftUI

struct ResultCard: View {
    let isCorrect: Bool
    let title: String
    let message: String

    var body: some View {
        AppCard {
            VStack(spacing: 8) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(isCorrect ? Color.appSuccess : Color.appError)

                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)

                Text(message)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .background(isCorrect ? Color.appSuccessLight : Color.appErrorLight)
    }
}
