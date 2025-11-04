import SwiftUI
import SwiftData

@main
struct CalSnapApp: App {
    @StateObject private var container = DIContainer.shared

    var body: some Scene {
        WindowGroup {
            RootContentView()
                .modelContainer(container.store.container)
                .environmentObject(container)
        }
    }
}

private struct RootContentView: View {
    @EnvironmentObject private var container: DIContainer
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \UserProfile.lastUpdated, order: .reverse, animation: .snappy) private var profiles: [UserProfile]

    var body: some View {
        Group {
            if let profile = profiles.first {
                HomeTabView(profile: profile)
            } else {
                ProfileView(mode: .onboarding)
            }
        }
        .task {
            await container.healthKitManager?.prepareIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task { await container.healthKitManager?.synchronizeIfNeeded() }
        }
    }
}
