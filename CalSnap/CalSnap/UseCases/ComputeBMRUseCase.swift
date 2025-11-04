import Foundation

struct ComputeBMRUseCase {
    func execute(profile: UserProfileInputs) -> Double {
        let weightFactor = 10.0 * profile.weightKG
        let heightFactor = 6.25 * profile.heightCM
        let ageFactor = 5.0 * Double(profile.age)
        let sexOffset: Double
        switch profile.sex {
        case .male:
            sexOffset = 5
        case .female:
            sexOffset = -161
        case .other:
            sexOffset = -78
        }
        return weightFactor + heightFactor - ageFactor + sexOffset
    }
}

struct UserProfileInputs {
    let sex: Sex
    let age: Int
    let heightCM: Double
    let weightKG: Double
    let activity: ActivityLevel
    let goal: Goal
}
