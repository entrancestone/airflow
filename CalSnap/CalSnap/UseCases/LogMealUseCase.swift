import Foundation
import SwiftData

struct LogMealUseCase {
    private let modelContext: ModelContext
    private let mealSlotResolver: MealSlotResolving

    init(modelContext: ModelContext, mealSlotResolver: MealSlotResolving) {
        self.modelContext = modelContext
        self.mealSlotResolver = mealSlotResolver
    }

    @MainActor
    func execute(request: LogMealRequest) throws {
        let slot = request.slot ?? mealSlotResolver.slot(for: request.date, calendar: request.calendar)
        let entry = MealEntry(
            date: request.date,
            slot: slot,
            label: request.label,
            portionGrams: request.portionGrams,
            calories: request.nutrition.calories,
            protein: request.nutrition.protein,
            carbs: request.nutrition.carbs,
            fat: request.nutrition.fat,
            thumbnailData: request.thumbnailData
        )
        modelContext.insert(entry)
        try modelContext.save()
    }
}

struct LogMealRequest {
    let date: Date
    let slot: MealSlot?
    let label: String
    let portionGrams: Double
    let nutrition: NutritionEstimate
    let thumbnailData: Data?
    var calendar: Calendar = .current
}
