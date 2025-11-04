import CoreGraphics
import Foundation
#if canImport(Vision)
import Vision
#endif

struct VisionFoodRecognitionProvider: FoodRecognitionProvider {
    func classify(image: CGImage) async throws -> [FoodPrediction] {
        #if canImport(Vision)
        // TODO: Replace with actual VNCoreMLModel classification pipeline when bundled model is available.
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: image)
        try handler.perform([request])
        let observations = request.results ?? []
        return observations.prefix(5).map { observation in
            FoodPrediction(label: observation.identifier, confidence: Double(observation.confidence))
        }
        #else
        throw NSError(domain: "VisionFoodRecognitionProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Vision/CoreML not available in this build."])
        #endif
    }
}
