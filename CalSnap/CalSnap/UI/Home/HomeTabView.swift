import SwiftUI
import SwiftData

struct HomeTabView: View {
    @EnvironmentObject private var container: DIContainer
    @Query(sort: \MealEntry.date, order: .reverse, animation: .snappy) private var meals: [MealEntry]

    let profile: UserProfile

    var body: some View {
        TabView {
            HomeView(profile: profile)
                .tabItem { Label("Today", systemImage: "chart.pie.fill") }

            HistoryView()
                .tabItem { Label("History", systemImage: "list.bullet") }

            TrendsView()
                .tabItem { Label("Trends", systemImage: "chart.bar.fill") }

            SettingsView(profile: profile)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .environment(\.meals, meals)
    }
}

private struct MealsKey: EnvironmentKey {
    static var defaultValue: [MealEntry] = []
}

extension EnvironmentValues {
    var meals: [MealEntry] {
        get { self[MealsKey.self] }
        set { self[MealsKey.self] = newValue }
    }
}
