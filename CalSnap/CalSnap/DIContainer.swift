import Foundation
import SwiftData
import SwiftUI

@MainActor
final class DIContainer: ObservableObject {
    static let shared = DIContainer()

    let store: PersistenceStore
    let nutritionAPI: NutritionAPI
    let foodRecognitionProvider: FoodRecognitionProvider
    let logMealUseCase: LogMealUseCase
    let dailySummaryUseCase: DailySummaryUseCase
    let adviceProvider: AdviceProviding
    let computeTDEEUseCase: ComputeTDEEUseCase
    let mealSlotResolver: MealSlotResolving
    let healthKitManager: HealthKitManaging?

    private init() {
        self.store = PersistenceStore()

        #if DEBUG
        let nutritionAPI: NutritionAPI = MockNutritionAPI()
        let foodRecognition: FoodRecognitionProvider = MockFoodRecognitionProvider()
        #else
        let nutritionAPI: NutritionAPI = RemoteNutritionAPI()
        let foodRecognition: FoodRecognitionProvider = VisionFoodRecognitionProvider()
        #endif

        self.nutritionAPI = nutritionAPI
        self.foodRecognitionProvider = foodRecognition
        self.mealSlotResolver = MealSlotResolver()
        self.computeTDEEUseCase = ComputeTDEEUseCase()
        self.logMealUseCase = LogMealUseCase(modelContext: store.container.mainContext, mealSlotResolver: mealSlotResolver)
        self.dailySummaryUseCase = DailySummaryUseCase(modelContext: store.container.mainContext)
        self.adviceProvider = AdviceProvider()

        #if HEALTHKITINTEGRATION
        self.healthKitManager = HealthKitManager(store: store, summaryUseCase: dailySummaryUseCase)
        #else
        self.healthKitManager = nil
        #endif
    }
}
