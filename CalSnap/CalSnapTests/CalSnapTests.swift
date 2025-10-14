import XCTest
@testable import CalSnap

final class CalSnapTests: XCTestCase {
    func testBMRMale() {
        let profile = UserProfileInputs(sex: .male, age: 30, heightCM: 180, weightKG: 80, activity: .moderate, goal: .maintain)
        let bmr = ComputeBMRUseCase().execute(profile: profile)
        XCTAssertEqual(Int(bmr.rounded()), 1780)
    }

    func testTDEEWithActivityAndGoal() {
        let profile = UserProfileInputs(sex: .female, age: 28, heightCM: 165, weightKG: 60, activity: .active, goal: .lose)
        let tdee = ComputeTDEEUseCase().execute(profile: profile)
        XCTAssertEqual(tdee, 2077)
    }

    func testMealSlotResolver() {
        let resolver = MealSlotResolver()
        let calendar = Calendar(identifier: .gregorian)
        let breakfast = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 6))!
        XCTAssertEqual(resolver.slot(for: breakfast, calendar: calendar), .breakfast)
        let lunch = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 13))!
        XCTAssertEqual(resolver.slot(for: lunch, calendar: calendar), .lunch)
        let dinner = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 18))!
        XCTAssertEqual(resolver.slot(for: dinner, calendar: calendar), .dinner)
        let snack = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 23))!
        XCTAssertEqual(resolver.slot(for: snack, calendar: calendar), .snack)
    }

    func testAdviceProvider() {
        let provider = AdviceProvider()
        XCTAssertTrue(provider.advice(consumed: 1200, target: 1800).contains("under"))
        XCTAssertTrue(provider.advice(consumed: 1825, target: 1800).contains("on track"))
        XCTAssertTrue(provider.advice(consumed: 2200, target: 1800).contains("over"))
    }

    @MainActor
    func testDailySummaryRollup() throws {
        let store = PersistenceStore(inMemory: true)
        let resolver = MealSlotResolver()
        let context = store.container.mainContext
        let useCase = LogMealUseCase(modelContext: context, mealSlotResolver: resolver)
        let nutrition = NutritionEstimate(calories: 500, protein: 30, carbs: 40, fat: 20)
        try useCase.execute(request: LogMealRequest(date: Date(), slot: .lunch, label: "Test", portionGrams: 200, nutrition: nutrition, thumbnailData: nil))

        let summaryUseCase = DailySummaryUseCase(modelContext: context)
        let summary = try summaryUseCase.fetchSummary(for: Date())
        XCTAssertEqual(summary.totalCalories, 500, accuracy: 0.1)
        XCTAssertEqual(summary.meals[.lunch]?.count, 1)
    }

    func testMockNutritionAPI() async throws {
        let api = MockNutritionAPI()
        let results = try await api.search(query: "pizza")
        XCTAssertFalse(results.isEmpty)
        let estimate = try await api.estimate(label: "Margherita Pizza", portionGrams: 200)
        XCTAssertGreaterThan(estimate.calories, 0)
    }
}
