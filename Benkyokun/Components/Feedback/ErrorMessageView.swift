import SwiftUI

struct ErrorMessageView: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.subheadline)
                .foregroundStyle(Color.appError)

            Text(message)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appError)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appErrorLight)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appError.opacity(0.18), lineWidth: 1)
            }
    }
}
