import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var container: DIContainer
    let profile: UserProfile
    @State private var showingProfile = false
    #if HEALTHKITINTEGRATION
    @State private var healthKitEnabled = true
    #endif

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    Button("Edit Profile") { showingProfile = true }
                }
                Section("Targets") {
                    Text("Calorie Target: \(profile.calorieTarget) kcal")
                }
                #if HEALTHKITINTEGRATION
                Section("HealthKit") {
                    Toggle("Sync to Health", isOn: $healthKitEnabled)
                        .onChange(of: healthKitEnabled) { _, isOn in
                            if isOn {
                                Task { await container.healthKitManager?.prepareIfNeeded() }
                            }
                        }
                }
                #endif
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingProfile) {
                ProfileView(mode: .edit(existing: profile))
            }
        }
    }
}
