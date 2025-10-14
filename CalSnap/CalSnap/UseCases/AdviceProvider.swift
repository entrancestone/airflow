import Foundation

protocol AdviceProviding {
    func advice(consumed: Double, target: Int) -> String
}

struct AdviceProvider: AdviceProviding {
    func advice(consumed: Double, target: Int) -> String {
        let delta = consumed - Double(target)
        switch delta {
        case ..<(-150):
            return "You’re under by \(Int(abs(delta))) kcal—add a protein-rich snack."
        case -150...150:
            return "You’re on track today."
        default:
            return "You’re over target by \(Int(delta)) kcal—aim for a lighter next meal."
        }
    }
}
