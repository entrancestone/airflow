import CoreGraphics

struct FoodPrediction: Identifiable, Hashable {
    let id: UUID
    let label: String
    let confidence: Double

    init(id: UUID = UUID(), label: String, confidence: Double) {
        self.id = id
        self.label = label
        self.confidence = confidence
    }
}

protocol FoodRecognitionProvider {
    func classify(image: CGImage) async throws -> [FoodPrediction]
}
