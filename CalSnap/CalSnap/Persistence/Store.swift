import Foundation
import SwiftData

@MainActor
final class PersistenceStore {
    let container: ModelContainer

    init(inMemory: Bool = false) {
        let schema = Schema([UserProfile.self, MealEntry.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
