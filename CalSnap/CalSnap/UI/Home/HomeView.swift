import UIKit
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var container: DIContainer
    @Environment(\.meals) private var meals
    @State private var isPresentingAddMeal = false

    let profile: UserProfile

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    TodaySummaryCard(profile: profile, meals: meals)
                    AdviceBanner(profile: profile, meals: meals)
                    MealBreakdownView(meals: meals)
                }
                .padding()
            }
            .navigationTitle("CalSnap")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddMeal = true
                    } label: {
                        Label("Add Meal", systemImage: "plus")
                    }
                    .accessibilityLabel("Add meal")
                }
            }
            .sheet(isPresented: $isPresentingAddMeal) {
                AddMealFlow()
            }
        }
    }
}

private struct TodaySummaryCard: View {
    let profile: UserProfile
    let meals: [MealEntry]

    var body: some View {
        let total = meals.filter { Calendar.current.isDateInToday($0.date) }.reduce(0) { $0 + $1.calories }
        VStack(alignment: .leading, spacing: 16) {
            Text("Today")
                .font(.headline)
            ProgressView(value: total, total: Double(profile.calorieTarget)) {
                Text("\(Int(total)) kcal consumed")
            } currentValueLabel: {
                Text("Target \(profile.calorieTarget) kcal")
            }
            .progressViewStyle(.linear)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}

private struct AdviceBanner: View {
    @EnvironmentObject private var container: DIContainer
    let profile: UserProfile
    let meals: [MealEntry]

    var body: some View {
        let todayTotal = meals.filter { Calendar.current.isDateInToday($0.date) }.reduce(0) { $0 + $1.calories }
        let message = container.adviceProvider.advice(consumed: todayTotal, target: profile.calorieTarget)
        return Text(message)
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor.opacity(0.15)))
    }
}

private struct MealBreakdownView: View {
    let meals: [MealEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meals")
                .font(.headline)
            ForEach(MealSlot.allCases) { slot in
                let slotMeals = meals.filter { Calendar.current.isDateInToday($0.date) && $0.slot == slot }
                if slotMeals.isEmpty {
                    EmptyMealRow(slot: slot)
                } else {
                    ForEach(slotMeals) { meal in
                        MealRow(meal: meal)
                    }
                }
            }
        }
    }
}

private struct EmptyMealRow: View {
    let slot: MealSlot

    var body: some View {
        HStack {
            Text(slot.title)
            Spacer()
            Text("No entry")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6])))
    }
}

private struct MealRow: View {
    let meal: MealEntry

    var body: some View {
        HStack(spacing: 16) {
            if let data = meal.thumbnailData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 56, height: 56)
                    .overlay(Image(systemName: "fork.knife").foregroundStyle(.secondary))
            }
            VStack(alignment: .leading) {
                Text(meal.label)
                    .font(.headline)
                Text("\(Int(meal.calories)) kcal • \(Int(meal.portionGrams)) g")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}
