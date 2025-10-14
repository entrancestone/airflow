import Foundation

protocol MealSlotResolving {
    func slot(for date: Date, calendar: Calendar) -> MealSlot
}

struct MealSlotResolver: MealSlotResolving {
    func slot(for date: Date, calendar: Calendar = .current) -> MealSlot {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour else { return .snack }
        switch hour {
        case 5...10:
            return .breakfast
        case 11...15:
            return .lunch
        case 16...21:
            return .dinner
        default:
            return .snack
        }
    }
}
