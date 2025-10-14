import Foundation
import SwiftData

@Model
final class MealEntry {
    var id: UUID
    var date: Date
    var slot: MealSlot
    var label: String
    var portionGrams: Double
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var thumbnailData: Data?

    init(
        id: UUID = UUID(),
        date: Date,
        slot: MealSlot,
        label: String,
        portionGrams: Double,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        thumbnailData: Data? = nil
    ) {
        self.id = id
        self.date = date
        self.slot = slot
        self.label = label
        self.portionGrams = portionGrams
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.thumbnailData = thumbnailData
    }
}
