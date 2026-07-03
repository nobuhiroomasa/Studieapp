import Foundation

enum AnswerOption: String, CaseIterable, Codable, Identifiable {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"

    var id: String { rawValue }
}
