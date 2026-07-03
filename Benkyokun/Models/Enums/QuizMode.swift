import Foundation

enum QuizMode: String, CaseIterable, Codable, Identifiable {
    case random = "ランダム出題"
    case category = "分野を選んで出題"
    case review = "間違えた問題から出題"

    var id: String { rawValue }
}
