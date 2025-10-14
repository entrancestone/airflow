import Foundation

struct MockNutritionAPI: NutritionAPI {
    private let catalog: [FoodItem] = [
        FoodItem(id: UUID(), name: "Chicken Salad", caloriesPer100g: 120, proteinPer100g: 16, carbsPer100g: 5, fatPer100g: 4),
        FoodItem(id: UUID(), name: "Margherita Pizza", caloriesPer100g: 240, proteinPer100g: 10, carbsPer100g: 30, fatPer100g: 8),
        FoodItem(id: UUID(), name: "Protein Shake", caloriesPer100g: 150, proteinPer100g: 25, carbsPer100g: 10, fatPer100g: 3),
        FoodItem(id: UUID(), name: "Greek Yogurt", caloriesPer100g: 90, proteinPer100g: 9, carbsPer100g: 4, fatPer100g: 3)
    ]

    func search(query: String) async throws -> [FoodItem] {
        if query.isEmpty { return catalog }
        return catalog.filter { $0.name.lowercased().contains(query.lowercased()) }
    }

    func estimate(label: String, portionGrams: Double) async throws -> NutritionEstimate {
        guard let item = catalog.first(where: { $0.name.caseInsensitiveCompare(label) == .orderedSame }) ??
                catalog.first(where: { $0.name.lowercased().contains(label.lowercased()) }) else {
            return NutritionEstimate(calories: portionGrams, protein: portionGrams * 0.1, carbs: portionGrams * 0.12, fat: portionGrams * 0.03)
        }
        return NutritionEstimate(
            calories: item.caloriesPer100g * portionGrams / 100,
            protein: item.proteinPer100g * portionGrams / 100,
            carbs: item.carbsPer100g * portionGrams / 100,
            fat: item.fatPer100g * portionGrams / 100
        )
    }
}
