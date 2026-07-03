import Foundation

enum DateCalculator {
    static func days(from startDate: Date, to endDate: Date) -> Int {
        Calendar.current.dateComponents([.day], from: startDate.startOfDay, to: endDate.startOfDay).day ?? 0
    }
}
