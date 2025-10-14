import SwiftUI
import SwiftData

struct ProfileView: View {
    enum Mode {
        case onboarding
        case edit(existing: UserProfile)
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: DIContainer

    @State private var sex: Sex = .male
    @State private var age: Int = 30
    @State private var heightCM: Double = 175
    @State private var weightKG: Double = 75
    @State private var activity: ActivityLevel = .moderate
    @State private var goal: Goal = .maintain

    let mode: Mode

    init(mode: Mode) {
        self.mode = mode
        if case let .edit(existing) = mode {
            _sex = State(initialValue: existing.sex)
            _age = State(initialValue: existing.age)
            _heightCM = State(initialValue: existing.heightCM)
            _weightKG = State(initialValue: existing.weightKG)
            _activity = State(initialValue: existing.activity)
            _goal = State(initialValue: existing.goal)
        }
    }

    var body: some View {
        Form {
            Section("Profile") {
                Picker("Sex", selection: $sex) {
                    ForEach(Sex.allCases) { sex in
                        Text(sex.rawValue.capitalized).tag(sex)
                    }
                }
                Stepper(value: $age, in: 14...100) {
                    Text("Age: \(age)")
                }
                Stepper(value: $heightCM, in: 120...220, step: 1) {
                    Text("Height: \(Int(heightCM)) cm")
                }
                Stepper(value: $weightKG, in: 40...200, step: 0.5) {
                    Text("Weight: \(String(format: "%.1f", weightKG)) kg")
                }
            }

            Section("Lifestyle") {
                Picker("Activity", selection: $activity) {
                    ForEach(ActivityLevel.allCases) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                Picker("Goal", selection: $goal) {
                    ForEach(Goal.allCases) { goal in
                        Text(goal.displayName).tag(goal)
                    }
                }
            }

            Section {
                Button(action: saveProfile) {
                    Text(modeButtonTitle)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle(modeTitle)
    }

    private var inputs: UserProfileInputs {
        UserProfileInputs(sex: sex, age: age, heightCM: heightCM, weightKG: weightKG, activity: activity, goal: goal)
    }

    private var modeTitle: String {
        switch mode {
        case .onboarding: return "Set Up Profile"
        case .edit: return "Edit Profile"
        }
    }

    private var modeButtonTitle: String {
        switch mode {
        case .onboarding: return "Continue"
        case .edit: return "Save Changes"
        }
    }

    private func saveProfile() {
        let target = container.computeTDEEUseCase.execute(profile: inputs)
        switch mode {
        case .onboarding:
            let profile = UserProfile(
                sex: sex,
                age: age,
                heightCM: heightCM,
                weightKG: weightKG,
                activity: activity,
                goal: goal,
                calorieTarget: target,
                lastUpdated: .now
            )
            modelContext.insert(profile)
        case let .edit(existing):
            existing.sex = sex
            existing.age = age
            existing.heightCM = heightCM
            existing.weightKG = weightKG
            existing.activity = activity
            existing.goal = goal
            existing.calorieTarget = target
            existing.lastUpdated = .now
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
}
