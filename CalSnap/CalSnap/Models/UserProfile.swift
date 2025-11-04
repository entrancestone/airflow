import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var sex: Sex
    var age: Int
    var heightCM: Double
    var weightKG: Double
    var activity: ActivityLevel
    var goal: Goal
    var calorieTarget: Int
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        sex: Sex,
        age: Int,
        heightCM: Double,
        weightKG: Double,
        activity: ActivityLevel,
        goal: Goal,
        calorieTarget: Int,
        lastUpdated: Date = .now
    ) {
        self.id = id
        self.sex = sex
        self.age = age
        self.heightCM = heightCM
        self.weightKG = weightKG
        self.activity = activity
        self.goal = goal
        self.calorieTarget = calorieTarget
        self.lastUpdated = lastUpdated
    }
}
