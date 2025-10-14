import CoreGraphics

struct MockFoodRecognitionProvider: FoodRecognitionProvider {
    func classify(image: CGImage) async throws -> [FoodPrediction] {
        [
            FoodPrediction(label: "Chicken Salad", confidence: 0.85),
            FoodPrediction(label: "Margherita Pizza", confidence: 0.65),
            FoodPrediction(label: "Protein Shake", confidence: 0.5)
        ]
    }
}
