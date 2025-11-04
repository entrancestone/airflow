import Foundation
import SwiftData

@MainActor
struct DailySummaryUseCase {
    struct Summary {
        let date: Date
        let totalCalories: Double
        let meals: [MealSlot: [MealEntry]]
    }

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchSummary(for date: Date, calendar: Calendar = .current) throws -> Summary {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let descriptor = FetchDescriptor<MealEntry>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay },
            sortBy: [SortDescriptor(\.date)]
        )
        let entries = try modelContext.fetch(descriptor)
        let grouped = Dictionary(grouping: entries, by: { $0.slot })
        let total = entries.reduce(0) { $0 + $1.calories }
        return Summary(date: startOfDay, totalCalories: total, meals: grouped)
    }

    func fetchWeeklySummaries(endingAt date: Date, calendar: Calendar = .current) throws -> [Summary] {
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: date))!
        var summaries: [Summary] = []
        for offset in 0..<7 {
            let current = calendar.date(byAdding: .day, value: offset, to: start)!
            let summary = try fetchSummary(for: current, calendar: calendar)
            summaries.append(summary)
        }
        return summaries
    }
}
