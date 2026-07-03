import SwiftUI

struct SettingsRow: View {
    let title: String
    var systemImage: String?
    var showsChevron = true

    var body: some View {
        HStack(spacing: 12) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.headline)
                    .frame(width: 34, height: 34)
                    .background(Color.appPrimaryLight)
                    .foregroundStyle(Color.appPrimary)
                    .clipShape(Circle())
            }

            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(minHeight: 52)
        .padding(.vertical, 6)
    }
}
