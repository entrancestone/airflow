import Foundation

protocol NutritionAPI {
    func search(query: String) async throws -> [FoodItem]
    func estimate(label: String, portionGrams: Double) async throws -> NutritionEstimate
}

struct FoodItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
}

struct NutritionEstimate {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
}
