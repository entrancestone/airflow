import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealEntry.date, order: .reverse, animation: .snappy) private var meals: [MealEntry]
    @State private var showingEdit: MealEntry?

    var body: some View {
        List {
            ForEach(groupedByDay, id: \.key) { day, entries in
                Section(header: Text(day)) {
                    ForEach(entries) { entry in
                        Button {
                            showingEdit = entry
                        } label: {
                            MealRow(meal: entry)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        delete(at: indexSet, entries: entries)
                    }
                }
            }
        }
        .sheet(item: $showingEdit) { meal in
            EditMealView(meal: meal)
        }
    }

    private var groupedByDay: [(key: String, value: [MealEntry])] {
        Dictionary(grouping: meals) { meal in
            DateFormatter.mediumDate.string(from: meal.date)
        }
        .sorted { $0.key > $1.key }
    }

    private func delete(at offsets: IndexSet, entries: [MealEntry]) {
        offsets.map { entries[$0] }.forEach(modelContext.delete)
        try? modelContext.save()
    }
}

private struct EditMealView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var meal: MealEntry

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $meal.label)
                    Picker("Slot", selection: $meal.slot) {
                        ForEach(MealSlot.allCases) { slot in
                            Text(slot.title).tag(slot)
                        }
                    }
                    Stepper(value: $meal.portionGrams, in: 50...1000, step: 10) {
                        Text("Portion: \(Int(meal.portionGrams)) g")
                    }
                }
            }
            .navigationTitle("Edit Meal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                }
            }
        }
    }
}

private struct MealRow: View {
    let meal: MealEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(meal.label)
                    .font(.headline)
                Text("\(Int(meal.calories)) kcal • \(meal.slot.title)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
