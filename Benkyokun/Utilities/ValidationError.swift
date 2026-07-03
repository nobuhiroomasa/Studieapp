import Foundation

enum ValidationError: LocalizedError {
    case invalidCategory
    case emptyRequiredField(String)

    var errorDescription: String? {
        switch self {
        case .invalidCategory:
            return "保存できる分野を選択してください。"
        case .emptyRequiredField(let fieldName):
            return "\(fieldName)を入力してください。"
        }
    }
}
