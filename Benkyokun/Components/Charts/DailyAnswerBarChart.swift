import SwiftUI

struct DailyAnswerBarChart: View {
    let data: [DailyAnswerCount]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(data) { item in
                VStack(spacing: 7) {
                    Text("\(item.answerCount)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(height: 14)

                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.appPrimaryLight)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.appPrimary)
                            .frame(height: barHeight(for: item.answerCount))
                    }
                    .frame(height: 104)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.appPrimary.opacity(0.12))
                            .frame(height: 1)
                    }

                    Text(weekdayText(for: item.date))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var maxAnswerCount: Int {
        max(data.map(\.answerCount).max() ?? 0, 1)
    }

    private func barHeight(for answerCount: Int) -> CGFloat {
        guard answerCount > 0 else {
            return 0
        }

        return max(
            8,
            CGFloat(answerCount) / CGFloat(maxAnswerCount) * 104
        )
    }

    private func weekdayText(for date: Date) -> String {
        date.formatted(.dateTime.weekday(.narrow))
    }
}
