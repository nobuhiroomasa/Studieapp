import SwiftUI

struct GoalProgressItem: Identifiable {
    let title: String
    let currentText: String
    let targetText: String
    let progress: Double

    var id: String { title }

    var progressPercentText: String {
        (min(max(progress, 0), 1) * 100).percentText
    }
}

struct GoalProgressChart: View {
    let items: [GoalProgressItem]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(item.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appTextPrimary)

                        Spacer(minLength: 0)

                        Text(item.progressPercentText)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appPrimary)
                    }

                    HStack(spacing: 4) {
                        Text(item.currentText)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appTextPrimary)

                        Text("/ \(item.targetText)")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.appPrimaryLight)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.appPrimary)
                                .frame(width: proxy.size.width * min(max(item.progress, 0), 1))
                        }
                    }
                    .frame(height: 12)
                }
            }
        }
    }
}
