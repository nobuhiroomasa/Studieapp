import SwiftUI

struct CategoryAccuracyChart: View {
    let stats: [CategoryAccuracyStat]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(stats) { stat in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        CategoryChip(title: stat.category.rawValue, isSelected: true)

                        Text("\(stat.answerCount)問")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appTextSecondary)

                        Spacer(minLength: 0)

                        Text(stat.accuracyPercent.percentText)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appTextPrimary)
                            .monospacedDigit()
                    }

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.appBackground)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(barColor(for: stat.accuracyPercent))
                                .frame(width: proxy.size.width * min(max(stat.accuracyRatio, 0), 1))
                        }
                    }
                    .frame(height: 12)
                }
            }
        }
    }

    private func barColor(for accuracyPercent: Double) -> Color {
        if accuracyPercent >= 80 {
            return Color.appSuccess
        } else if accuracyPercent >= 50 {
            return Color.appWarning
        } else {
            return Color.appError
        }
    }
}
