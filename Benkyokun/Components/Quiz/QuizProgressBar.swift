import SwiftUI

struct QuizProgressBar: View {
    let current: Int
    let total: Int?

    private var progress: Double {
        guard let total, total > 0 else { return 0 }
        return min(max(Double(current) / Double(total), 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(progressText)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                if let total, total > 0 {
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            if total != nil {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.appPrimaryLight)

                        Capsule()
                            .fill(Color.appPrimary)
                            .frame(width: proxy.size.width * progress)
                    }
                }
                .frame(height: 8)
            }
        }
    }

    private var progressText: String {
        if let total {
            return "\(current) / \(total)問"
        } else {
            return "\(current)問回答"
        }
    }
}
