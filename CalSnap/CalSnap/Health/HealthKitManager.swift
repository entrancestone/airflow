import Foundation
#if canImport(HealthKit)
import HealthKit
#endif

protocol HealthKitManaging {
    func prepareIfNeeded() async
    func synchronizeIfNeeded() async
}

#if canImport(HealthKit)
@MainActor
final class HealthKitManager: HealthKitManaging {
    private let healthStore = HKHealthStore()
    private let store: PersistenceStore
    private let summaryUseCase: DailySummaryUseCase

    init(store: PersistenceStore, summaryUseCase: DailySummaryUseCase) {
        self.store = store
        self.summaryUseCase = summaryUseCase
    }

    func prepareIfNeeded() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let energy = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        do {
            try await healthStore.requestAuthorization(toShare: [energy], read: [])
        } catch {
            print("HealthKit authorization failed: \(error)")
        }
    }

    func synchronizeIfNeeded() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let energyType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        let calendar = Calendar.current
        let summary: DailySummaryUseCase.Summary
        do {
            summary = try summaryUseCase.fetchSummary(for: Date())
        } catch {
            print("Failed to fetch summary: \(error)")
            return
        }
        let start = calendar.startOfDay(for: summary.date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: summary.totalCalories)
        let sample = HKQuantitySample(type: energyType, quantity: quantity, start: start, end: end)
        healthStore.deleteObjects(of: energyType, predicate: predicate) { _, _, _ in }
        healthStore.save(sample) { success, error in
            if let error = error {
                print("HealthKit save failed: \(error)")
            } else {
                print("HealthKit save success: \(success)")
            }
        }
    }
}
#else
@MainActor
final class HealthKitManager: HealthKitManaging {
    init(store: PersistenceStore, summaryUseCase: DailySummaryUseCase) {}
    func prepareIfNeeded() async {}
    func synchronizeIfNeeded() async {}
}
#endif
