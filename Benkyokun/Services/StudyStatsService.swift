import Foundation
import SwiftData

struct StudyStatsSummary {
    let totalAnswerCount: Int
    let correctCount: Int
    let incorrectCount: Int
    let overallAccuracyPercent: Double
    let todayAnswerCount: Int
    let todayCorrectCount: Int
    let todayAccuracyPercent: Double
    let dailyAnswerCounts: [DailyAnswerCount]
    let categoryStats: [CategoryAccuracyStat]
    let answeredDates: [Date]
    let consecutiveStudyDayCount: Int

    static func empty(referenceDate: Date = Date()) -> StudyStatsSummary {
        StudyStatsSummary(
            totalAnswerCount: 0,
            correctCount: 0,
            incorrectCount: 0,
            overallAccuracyPercent: 0,
            todayAnswerCount: 0,
            todayCorrectCount: 0,
            todayAccuracyPercent: 0,
            dailyAnswerCounts: StudyStatsService.makeRecentDailyCounts(
                histories: [],
                referenceDate: referenceDate
            ),
            categoryStats: [],
            answeredDates: [],
            consecutiveStudyDayCount: 0
        )
    }
}

struct DailyAnswerCount: Identifiable {
    let date: Date
    let answerCount: Int
    let correctCount: Int

    var id: Date { date }
}

struct CategoryAccuracyStat: Identifiable {
    let category: QuestionCategory
    let answerCount: Int
    let correctCount: Int

    var id: String { category.rawValue }

    var accuracyPercent: Double {
        StudyStatsService.accuracyPercent(
            correctCount: correctCount,
            totalCount: answerCount
        )
    }

    var accuracyRatio: Double {
        accuracyPercent / 100
    }
}

struct StudyStatsService {
    static func fetchSummary(
        modelContext: ModelContext,
        referenceDate: Date = Date()
    ) throws -> StudyStatsSummary {
        let histories = try AnswerHistoryRepository.fetchAll(modelContext: modelContext)

        return makeSummary(
            histories: histories,
            referenceDate: referenceDate
        )
    }

    static func makeSummary(
        histories: [AnswerHistory],
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> StudyStatsSummary {
        let totalAnswerCount = histories.count
        let correctCount = histories.filter(\.isCorrect).count
        let incorrectCount = totalAnswerCount - correctCount
        let todayStart = calendar.startOfDay(for: referenceDate)

        let todayHistories = histories.filter {
            calendar.isDate($0.answeredAt, inSameDayAs: todayStart)
        }
        let todayCorrectCount = todayHistories.filter(\.isCorrect).count

        let dailyAnswerCounts = makeRecentDailyCounts(
            histories: histories,
            referenceDate: referenceDate,
            calendar: calendar
        )
        let categoryStats = makeCategoryStats(histories: histories)
        let answeredDates = makeAnsweredDates(
            histories: histories,
            calendar: calendar
        )
        let consecutiveStudyDayCount = makeConsecutiveStudyDayCount(
            answeredDates: answeredDates,
            referenceDate: referenceDate,
            calendar: calendar
        )

        return StudyStatsSummary(
            totalAnswerCount: totalAnswerCount,
            correctCount: correctCount,
            incorrectCount: incorrectCount,
            overallAccuracyPercent: accuracyPercent(
                correctCount: correctCount,
                totalCount: totalAnswerCount
            ),
            todayAnswerCount: todayHistories.count,
            todayCorrectCount: todayCorrectCount,
            todayAccuracyPercent: accuracyPercent(
                correctCount: todayCorrectCount,
                totalCount: todayHistories.count
            ),
            dailyAnswerCounts: dailyAnswerCounts,
            categoryStats: categoryStats,
            answeredDates: answeredDates,
            consecutiveStudyDayCount: consecutiveStudyDayCount
        )
    }

    static func accuracyPercent(
        correctCount: Int,
        totalCount: Int
    ) -> Double {
        guard totalCount > 0 else {
            return 0
        }

        return Double(correctCount) / Double(totalCount) * 100
    }

    static func makeRecentDailyCounts(
        histories: [AnswerHistory],
        referenceDate: Date = Date(),
        days: Int = 7,
        calendar: Calendar = .current
    ) -> [DailyAnswerCount] {
        let referenceStart = calendar.startOfDay(for: referenceDate)
        let dayOffsets = Array(stride(from: -(days - 1), through: 0, by: 1))

        return dayOffsets.compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: referenceStart) else {
                return nil
            }

            let historiesForDay = histories.filter {
                calendar.isDate($0.answeredAt, inSameDayAs: date)
            }

            return DailyAnswerCount(
                date: date,
                answerCount: historiesForDay.count,
                correctCount: historiesForDay.filter(\.isCorrect).count
            )
        }
    }

    static func makeCategoryStats(histories: [AnswerHistory]) -> [CategoryAccuracyStat] {
        QuestionCategory.storableCases.compactMap { category in
            let categoryHistories = histories.filter {
                $0.categoryRaw == category.rawValue
            }

            guard categoryHistories.isEmpty == false else {
                return nil
            }

            return CategoryAccuracyStat(
                category: category,
                answerCount: categoryHistories.count,
                correctCount: categoryHistories.filter(\.isCorrect).count
            )
        }
    }

    static func makeAnsweredDates(
        histories: [AnswerHistory],
        calendar: Calendar = .current
    ) -> [Date] {
        let uniqueDays = Set(histories.map { calendar.startOfDay(for: $0.answeredAt) })

        return uniqueDays.sorted(by: >)
    }

    static func makeConsecutiveStudyDayCount(
        answeredDates: [Date],
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let answeredDaySet = Set(answeredDates.map { calendar.startOfDay(for: $0) })
        var currentDate = calendar.startOfDay(for: referenceDate)
        var count = 0

        while answeredDaySet.contains(currentDate) {
            count += 1

            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }

            currentDate = previousDate
        }

        return count
    }
}
