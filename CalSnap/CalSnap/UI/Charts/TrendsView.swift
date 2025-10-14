import SwiftUI
import Charts
import SwiftData

struct TrendsView: View {
    @EnvironmentObject private var container: DIContainer
    @Query(sort: \UserProfile.lastUpdated, order: .reverse) private var profiles: [UserProfile]
    @State private var summaries: [DailySummaryUseCase.Summary] = []
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let profile = profiles.first {
                    Text("Weekly Calories")
                        .font(.title2)
                        .bold()
                    Chart {
                        ForEach(summaries, id: \.date) { summary in
                            BarMark(
                                x: .value("Day", summary.date, unit: .day),
                                y: .value("Calories", summary.totalCalories)
                            )
                        }
                        RuleMark(y: .value("Target", Double(profile.calorieTarget)))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 240)
                    if let weeklyAverage = summaries.map(\.totalCalories).average {
                        Text("Average: \(Int(weeklyAverage)) kcal • Target: \(profile.calorieTarget) kcal")
                            .font(.subheadline)
                    }
                } else {
                    Text("Set up your profile to see trends.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Trends")
        .task { await loadSummaries() }
        .alert("Error", isPresented: Binding(value: $errorMessage)) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            if let errorMessage { Text(errorMessage) }
        }
    }

    private func loadSummaries() async {
        do {
            let summaries = try await MainActor.run {
                try container.dailySummaryUseCase.fetchWeeklySummaries(endingAt: Date())
            }
            await MainActor.run { self.summaries = summaries }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
    }
}

private extension Sequence where Element == Double {
    var average: Double? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / Double(count)
    }
}
