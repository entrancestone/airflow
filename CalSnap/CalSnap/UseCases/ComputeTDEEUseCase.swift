import Foundation

struct ComputeTDEEUseCase {
    private let bmrUseCase = ComputeBMRUseCase()

    func execute(profile: UserProfileInputs) -> Int {
        let bmr = bmrUseCase.execute(profile: profile)
        let tdee = bmr * profile.activity.multiplier
        let adjusted = tdee + profile.goal.calorieAdjustment
        return Int((adjusted).rounded())
    }
}
