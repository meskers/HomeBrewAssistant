import SwiftUI
import CoreData
import Foundation

struct RecipeBuilderView: View {
    var recipeToEdit: DetailedRecipeModel?

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RecipeViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showingIngredientPicker = false
    @State private var showingTimingPicker = false
    @State private var selectedIngredientIndex: Int?
    
    init(recipeToEdit: DetailedRecipeModel? = nil) {
        self.recipeToEdit = recipeToEdit
        self._viewModel = StateObject(wrappedValue: RecipeViewModel(recipeToEdit: recipeToEdit))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    recipeTypeSection
                    ingredientsSection
                    instructionsSection
                    saveButtonSection
                }
                .padding()
            }
            .navigationTitle(recipeToEdit == nil ? "Nieuw Recept" : "Bewerk Recept")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuleren") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Opslaan") {
                        saveRecipe()
                    }
                    .disabled(viewModel.recipeName.isEmpty)
                }
            }
            .alert("Status", isPresented: $showAlert) {
                Button("OK") {
                    if !viewModel.recipeName.isEmpty && alertMessage.contains("opgeslagen") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingIngredientPicker) {
                IngredientPickerView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Recipe Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📝 Receptdetails")
                .font(.headline)
                .foregroundColor(.brewTheme)
            
            VStack(spacing: 12) {
                TextField("Receptnaam", text: $viewModel.recipeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                
                HStack {
                    Text("Type:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(viewModel.selectedType.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.brewTheme)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Recipe Type Section
    private var recipeTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🍺 Brouwtype")
                .font(.headline)
                .foregroundColor(.brewTheme)
            
            Picker("Type", selection: $viewModel.selectedType) {
                ForEach(RecipeType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    // MARK: - Ingredients Section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🌾 Ingrediënten")
                    .font(.headline)
                    .foregroundColor(.brewTheme)
                
                Spacer()
                
                Button(action: { showingIngredientPicker = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.brewTheme)
                }
            }
            
            if viewModel.ingredients.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "leaf")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("Geen ingrediënten toegevoegd")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Tik op + om ingrediënten toe te voegen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(viewModel.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                        ingredientRow(ingredient, index: index)
                    }
                }
            }
        }
    }
    
    private func ingredientRow(_ ingredient: IngredientModel, index: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack {
                    Text("\(ingredient.type)")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.brewTheme.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(ingredient.timing)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(ingredient.amount)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.brewTheme)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .swipeActions(edge: .trailing) {
            Button("Verwijder") {
                withAnimation {
                    viewModel.ingredients.removeAll { $0.id == ingredient.id }
                }
            }
            .tint(.red)
        }
    }
    
    // MARK: - Instructions Section
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📋 Instructies")
                .font(.headline)
                .foregroundColor(.brewTheme)
            
            TextEditor(text: $viewModel.instructions)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if viewModel.instructions.isEmpty {
                        Text("Voeg brouwinstructies toe...")
                            .foregroundColor(.secondary)
                            .padding(.top, 16)
                            .padding(.leading, 12)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
    
    // MARK: - Save Button Section
    private var saveButtonSection: some View {
        VStack(spacing: 12) {
            Button("💾 Recept Opslaan") {
                saveRecipe()
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(viewModel.recipeName.isEmpty ? Color.gray : Color.brewTheme)
            .foregroundColor(.white)
            .font(.headline)
            .cornerRadius(12)
            .disabled(viewModel.recipeName.isEmpty)
            
            if viewModel.recipeName.isEmpty {
                Text("⚠️ Voer een receptnaam in")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func saveRecipe() {
        do {
            try viewModel.saveRecipe(context: viewContext)
            showAlert = true
            alertMessage = "✅ Recept succesvol opgeslagen!"
        } catch {
            showAlert = true
            alertMessage = "❌ Fout bij opslaan: \(error.localizedDescription)"
        }
    }
}

// MARK: - Ingredient Picker View
struct IngredientPickerView: View {
    @ObservedObject var viewModel: RecipeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var ingredientName = ""
    @State private var ingredientAmount = ""
    @State private var selectedType = "Mout"
    @State private var selectedTiming = "Mashing"
    
    private let ingredientTypes = ["Mout", "Hop", "Gist", "Suiker", "Fruit", "Kruiden", "Overig"]
    private let timingOptions = ["Mashing", "Voor kook", "60 min", "30 min", "15 min", "5 min", "Flame out", "Dry hop", "Fermentatie"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ingrediënt Details") {
                    TextField("Naam", text: $ingredientName)
                    TextField("Hoeveelheid (bijv. 2.5 kg)", text: $ingredientAmount)
                }
                
                Section("Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(ingredientTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section("Timing") {
                    Picker("Wanneer toevoegen", selection: $selectedTiming) {
                        ForEach(timingOptions, id: \.self) { timing in
                            Text(timing).tag(timing)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
            }
            .navigationTitle("Ingrediënt Toevoegen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuleer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Toevoegen") {
                        addIngredient()
                    }
                    .disabled(ingredientName.isEmpty || ingredientAmount.isEmpty)
                }
            }
        }
    }
    
    private func addIngredient() {
        let ingredient = IngredientModel(
            name: ingredientName,
            type: selectedType,
            amount: ingredientAmount,
            timing: selectedTiming
        )
        viewModel.ingredients.append(ingredient)
        dismiss()
    }
}

// MARK: - Recipe Type Extension
extension RecipeType {
    var displayName: String {
        switch self {
        case .beer: return "🍺 Bier"
        case .cider: return "🍏 Cider"
        case .wine: return "🍷 Wijn"
        case .kombucha: return "🫖 Kombucha"
        case .mead: return "🍯 Mede"
        case .other: return "🔄 Anders"
        }
    }
}

#Preview {
    RecipeBuilderView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

   
