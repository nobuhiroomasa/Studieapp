import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var systemImage: String? = nil

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appTextSecondary)

                        Text(value)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.6)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.headline)
                            .frame(width: 34, height: 34)
                            .background(Color.appPrimaryLight)
                            .foregroundStyle(Color.appPrimary)
                            .clipShape(Circle())
                    }
                }

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                }
            }
            .frame(minHeight: 86, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
