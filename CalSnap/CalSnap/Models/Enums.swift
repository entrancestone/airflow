import Foundation

enum Sex: String, Codable, CaseIterable, Identifiable {
    case male
    case female
    case other

    var id: String { rawValue }
}

enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary
    case light
    case moderate
    case active

    var id: String { rawValue }

    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        }
    }

    var displayName: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .active: return "Active"
        }
    }
}

enum Goal: String, Codable, CaseIterable, Identifiable {
    case lose
    case maintain
    case gain

    var id: String { rawValue }

    var calorieAdjustment: Double {
        switch self {
        case .lose: return -300
        case .maintain: return 0
        case .gain: return 300
        }
    }

    var displayName: String {
        switch self {
        case .lose: return "Lose Weight"
        case .maintain: return "Maintain"
        case .gain: return "Gain Muscle"
        }
    }
}

enum MealSlot: String, Codable, CaseIterable, Identifiable {
    case breakfast
    case lunch
    case dinner
    case snack

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        }
    }
}
