import Foundation

struct RemoteNutritionAPI: NutritionAPI {
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func search(query: String) async throws -> [FoodItem] {
        // TODO: Implement real networking call using provider such as USDA FDC or Edamam.
        throw NSError(domain: "RemoteNutritionAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Remote API not configured. Provide Secrets.plist with API keys."])
    }

    func estimate(label: String, portionGrams: Double) async throws -> NutritionEstimate {
        // TODO: Implement real estimation by calling remote API.
        throw NSError(domain: "RemoteNutritionAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Remote API not configured. Provide Secrets.plist with API keys."])
    }
}
