import Foundation

enum QuestionCategory: String, CaseIterable, Codable, Identifiable {
    case all = "すべて"
    case electricalTheory = "電気理論"
    case distributionTheory = "配電理論"
    case wiringDesign = "配線設計"
    case electricalEquipment = "電気機器"
    case wiringDevices = "配線器具"
    case tools = "工具"
    case materials = "材料"
    case constructionMethod = "施工方法"
    case inspectionMethod = "検査方法"
    case law = "法令"
    case wiringDiagram = "配線図"
    case identification = "鑑別"

    var id: String { rawValue }

    static var storableCases: [QuestionCategory] {
        allCases.filter { $0 != .all }
    }

    var canBeStoredInQuestion: Bool {
        self != .all
    }
}
