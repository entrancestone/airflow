import UIKit
import SwiftUI
import PhotosUI

struct AddMealFlow: View {
    @EnvironmentObject private var container: DIContainer
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var predictions: [FoodPrediction] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedFood: FoodItem?
    @State private var portion: Double = 150
    @State private var nutrition: NutritionEstimate?
    @State private var manualQuery = ""
    @State private var searchResults: [FoodItem] = []
    @State private var slot: MealSlot?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Add Meal")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", action: dismiss.callAsFunction)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Log") {
                            Task { await logMeal() }
                        }
                        .disabled(nutrition == nil || selectedFood == nil)
                    }
                }
        }
        .task(id: selectedItem) { await loadImage() }
        .task(id: selectedImage) { await classify() }
        .alert("Error", isPresented: Binding(value: $errorMessage)) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            if let message = errorMessage { Text(message) }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 24) {
            PhotosPicker(selection: $selectedItem, matching: .images, preferredItemEncoding: .automatic) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.accentColor, lineWidth: 2))
                        .accessibilityLabel("Selected meal image")
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 180)
                        .overlay(
                            VStack {
                                Image(systemName: "camera.fill").font(.system(size: 36))
                                Text("Snap or Pick a Photo")
                            }
                                .foregroundStyle(.secondary)
                        )
                }
            }
            .buttonStyle(.plain)

            if isLoading {
                ProgressView("Recognizing food…")
            } else {
                predictionsView
            }

            if let food = selectedFood {
                PortionEditor(food: food, portion: $portion)
                    .onChange(of: portion) { _, newValue in
                        Task { await estimateNutrition(for: food, portion: newValue) }
                    }
            }

            if let nutrition {
                NutritionSummaryView(nutrition: nutrition)
            }

            MealSlotPicker(selection: $slot)
        }
        .padding()
    }

    @ViewBuilder
    private var predictionsView: some View {
        if !predictions.isEmpty {
            VStack(alignment: .leading) {
                Text("Suggestions").font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(predictions) { prediction in
                            Button {
                                Task { await selectPrediction(prediction) }
                            } label: {
                                VStack {
                                    Text(prediction.label)
                                    Text(String(format: "%.0f%%", prediction.confidence * 100))
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                            }
                        }
                    }
                }
            }
        }

        VStack(alignment: .leading, spacing: 12) {
            Text("Manual Search").font(.headline)
            TextField("Search foods", text: $manualQuery)
                .textFieldStyle(.roundedBorder)
                .onSubmit { Task { await searchFoods() } }
            if !searchResults.isEmpty {
                List(searchResults, id: \.id) { item in
                    Button {
                        Task { await selectManualFood(item) }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text("\(Int(item.caloriesPer100g)) kcal / 100g")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxHeight: 160)
                .listStyle(.plain)
            }
        }
    }

    private func loadImage() async {
        guard let item = selectedItem else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                await MainActor.run { selectedImage = image }
            }
        } catch {
            await presentError("Failed to load image: \(error.localizedDescription)")
        }
    }

    private func classify() async {
        guard let uiImage = selectedImage, let cgImage = uiImage.cgImage else { return }
        await MainActor.run { isLoading = true }
        do {
            let predictions = try await container.foodRecognitionProvider.classify(image: cgImage)
            await MainActor.run {
                self.predictions = predictions
                self.isLoading = false
            }
        } catch {
            await presentError("Food recognition failed. Try manual search.")
            await MainActor.run { self.isLoading = false }
        }
    }

    private func selectPrediction(_ prediction: FoodPrediction) async {
        do {
            let estimate = try await container.nutritionAPI.estimate(label: prediction.label, portionGrams: portion)
            await MainActor.run {
                self.selectedFood = FoodItem(
                    id: prediction.id,
                    name: prediction.label,
                    caloriesPer100g: (estimate.calories / max(portion, 1)) * 100,
                    proteinPer100g: (estimate.protein / max(portion, 1)) * 100,
                    carbsPer100g: (estimate.carbs / max(portion, 1)) * 100,
                    fatPer100g: (estimate.fat / max(portion, 1)) * 100
                )
                self.nutrition = estimate
            }
        } catch {
            await presentError("Failed to estimate nutrition: \(error.localizedDescription)")
        }
    }

    private func selectManualFood(_ item: FoodItem) async {
        await MainActor.run {
            selectedFood = item
        }
        await estimateNutrition(for: item, portion: portion)
    }

    private func estimateNutrition(for item: FoodItem, portion: Double) async {
        do {
            let estimate = try await container.nutritionAPI.estimate(label: item.name, portionGrams: portion)
            await MainActor.run { self.nutrition = estimate }
        } catch {
            await presentError("Failed to estimate nutrition: \(error.localizedDescription)")
        }
    }

    private func searchFoods() async {
        guard !manualQuery.isEmpty else { return }
        do {
            let items = try await container.nutritionAPI.search(query: manualQuery)
            await MainActor.run { self.searchResults = items }
        } catch {
            await presentError("Search failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func logMeal() async {
        guard let food = selectedFood, let nutrition else { return }
        let request = LogMealRequest(
            date: Date(),
            slot: slot,
            label: food.name,
            portionGrams: portion,
            nutrition: nutrition,
            thumbnailData: selectedImage.flatMap { image in
                if let thumb = ImageThumb.thumbnail(from: image) { return ImageThumb.jpegData(from: thumb) }
                return ImageThumb.jpegData(from: image)
            }
        )
        do {
            try container.logMealUseCase.execute(request: request)
            dismiss()
        } catch {
            await presentError("Failed to save meal: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func presentError(_ message: String) async {
        errorMessage = message
    }
}

private struct PortionEditor: View {
    let food: FoodItem
    @Binding var portion: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(food.name)
                .font(.title3)
                .bold()
            HStack {
                Text("Portion: \(Int(portion)) g")
                Spacer()
                Stepper(value: $portion, in: 50...1000, step: 10) { EmptyView() }
                    .labelsHidden()
            }
            Slider(value: $portion, in: 50...1000, step: 10)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
    }
}

private struct NutritionSummaryView: View {
    let nutrition: NutritionEstimate

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Estimated Nutrition").font(.headline)
            HStack {
                nutrient("Calories", value: nutrition.calories, suffix: "kcal")
                Spacer()
                nutrient("Protein", value: nutrition.protein, suffix: "g")
                Spacer()
                nutrient("Carbs", value: nutrition.carbs, suffix: "g")
                Spacer()
                nutrient("Fat", value: nutrition.fat, suffix: "g")
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    private func nutrient(_ title: String, value: Double, suffix: String) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.subheadline).foregroundStyle(.secondary)
            Text("\(Int(value.rounded())) \(suffix)").font(.headline)
        }
    }
}

private struct MealSlotPicker: View {
    @Binding var selection: MealSlot?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Meal Slot").font(.headline)
            Picker("Meal Slot", selection: Binding(get: {
                selection ?? MealSlotResolver().slot(for: Date(), calendar: .current)
            }, set: { newValue in
                selection = newValue
            })) {
                ForEach(MealSlot.allCases) { slot in
                    Text(slot.title).tag(slot)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
