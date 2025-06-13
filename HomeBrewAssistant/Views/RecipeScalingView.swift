import SwiftUI

struct RecipeScalingView: View {
    let recipe: DetailedRecipe
    let originalBatchSize: Double
    @State private var targetBatchSize: Double
    @State private var customBatchSize: String = ""
    @State private var scaledRecipe: DetailedRecipe?
    @State private var showingScaledRecipe = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedPresetIndex: Int? = nil
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var localizationManager: LocalizationManager
    
    init(recipe: DetailedRecipe, originalBatchSize: Double = 23.0) {
        self.recipe = recipe
        self.originalBatchSize = originalBatchSize
        self._targetBatchSize = State(initialValue: originalBatchSize)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    recipeHeaderView
                    
                    // Batch Size Selection
                    batchSizeSelectionView
                    
                    // Scale Factor Display
                    scaleFactorView
                    
                    // Preset Sizes
                    presetSizesView
                    
                    // Scale Button
                    scaleButtonView
                    
                    // Scaled Recipe Preview
                    if let scaledRecipe = scaledRecipe {
                        scaledRecipePreview(scaledRecipe)
                    }
                }
                .padding()
            }
            .navigationTitle(localizationManager.localized("recipe.scaling.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizationManager.localized("action.cancel")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.brewTheme)
                }
                
                if scaledRecipe != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(localizationManager.localized("recipe.scaling.save_scaled")) {
                            saveScaledRecipe()
                        }
                        .fontWeight(.bold)
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(localizationManager.localized("scaling.success.title")),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - View Components
    
    private var recipeHeaderView: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.title)
                    .foregroundColor(.brewTheme)
                
                VStack(alignment: .leading) {
                    Text(recipe.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(recipe.style)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(RecipeScaler.formatBatchSize(originalBatchSize))L")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.brewTheme)
                    
                    Text(localizationManager.localized("recipe.scaling.original_batch"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var batchSizeSelectionView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(localizationManager.localized("recipe.scaling.target_batch"))
                .font(.headline)
            
            HStack {
                TextField(localizationManager.localized("recipe.scaling.custom_size"), text: $customBatchSize)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .onChange(of: customBatchSize) { _, newValue in
                        if let value = Double(newValue.replacingOccurrences(of: ",", with: ".")),
                           value > 0 {
                            targetBatchSize = value
                            selectedPresetIndex = nil
                        }
                    }
                
                Text(localizationManager.localized("recipe.scaling.liters"))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var scaleFactorView: some View {
        VStack(spacing: 10) {
            Text(localizationManager.localized("recipe.scaling.scale_factor"))
                .font(.headline)
            
            HStack {
                Text("\(RecipeScaler.formatBatchSize(originalBatchSize))L")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.brewTheme)
                
                Text("\(RecipeScaler.formatBatchSize(targetBatchSize))L")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.brewTheme)
                
                Spacer()
                
                Text("×\(String(format: "%.2f", targetBatchSize / originalBatchSize))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var presetSizesView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(localizationManager.localized("recipe.scaling.preset_sizes"))
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                ForEach(Array(BatchSizePreset.presets.enumerated()), id: \.element.size) { index, preset in
                    presetSizeButton(preset, index: index)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func presetSizeButton(_ preset: BatchSizePreset, index: Int) -> some View {
        Button(action: {
            targetBatchSize = preset.size
            customBatchSize = String(format: "%.0f", preset.size)
            selectedPresetIndex = index
        }) {
            VStack(spacing: 8) {
                HStack {
                    Text("\(Int(preset.size))L")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    if selectedPresetIndex == index {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(preset.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(selectedPresetIndex == index ? Color.brewTheme.opacity(0.1) : Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedPresetIndex == index ? Color.brewTheme : Color(.systemGray4), lineWidth: selectedPresetIndex == index ? 2 : 1)
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var scaleButtonView: some View {
        VStack(spacing: 12) {
            // Scale Factor Summary
            if targetBatchSize != originalBatchSize {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Schaalfactor")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("×\(String(format: "%.2f", targetBatchSize / originalBatchSize))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.brewTheme)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Nieuwe batch")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(RecipeScaler.formatBatchSize(targetBatchSize))L")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.brewTheme)
                    }
                }
                .padding()
                .background(Color.brewTheme.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Scale Button
            Button(action: scaleRecipe) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title3)
                    
                    Text(scaledRecipe == nil ? "Schaal Recept" : "Herbereken")
                        .fontWeight(.semibold)
                    
                    if targetBatchSize != originalBatchSize {
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(targetBatchSize != originalBatchSize ? Color.brewTheme : Color.gray)
                .cornerRadius(12)
            }
            .disabled(targetBatchSize == originalBatchSize || targetBatchSize <= 0)
        }
    }
    
    private func scaledRecipePreview(_ scaledRecipe: DetailedRecipe) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(localizationManager.localized("recipe.scaling.preview"))
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(localizationManager.localized("recipe.scaling.save_scaled")) {
                    saveScaledRecipe()
                }
                .buttonStyle(.borderedProminent)
            }
            
            // Scaled Ingredients
            VStack(alignment: .leading, spacing: 10) {
                Text(localizationManager.localized("recipe.scaling.scaled_ingredients"))
                    .font(.headline)
                
                ForEach(scaledRecipe.ingredients) { ingredient in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(ingredient.name)
                                .font(.body)
                            Text(ingredient.timing)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(ingredient.amount)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.brewTheme)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Scaled Instructions (first few)
            VStack(alignment: .leading, spacing: 10) {
                Text(localizationManager.localized("recipe.scaling.scaled_instructions"))
                    .font(.headline)
                
                ForEach(Array(scaledRecipe.instructions.prefix(3).enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top) {
                        Text("\(index + 1).")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.brewTheme)
                            .frame(width: 20)
                        
                        Text(instruction)
                            .font(.body)
                    }
                    .padding(.vertical, 2)
                }
                
                if scaledRecipe.instructions.count > 3 {
                    Text("... en \(scaledRecipe.instructions.count - 3) meer stappen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Actions
    
    private func scaleRecipe() {
        guard targetBatchSize > 0, targetBatchSize != originalBatchSize else { return }
        
        if targetBatchSize < 1 {
            alertMessage = localizationManager.localized("scaling.error.too_small")
            showingAlert = true
            return
        }
        
        if targetBatchSize > 100 {
            alertMessage = localizationManager.localized("scaling.error.too_large")
            showingAlert = true
            return
        }
        
        scaledRecipe = RecipeScaler.scaleRecipe(recipe, from: originalBatchSize, to: targetBatchSize)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showingScaledRecipe = true
        }
    }
    
    private func saveScaledRecipe() {
        // Hier zou je het geschaalde recept opslaan in de app
        // Voor nu tonen we alleen een success message
        let message = String(format: localizationManager.localized("scaling.success.message"), RecipeScaler.formatBatchSize(targetBatchSize))
        alertMessage = message
        showingAlert = true
    }
}

#Preview {
    RecipeScalingView(
        recipe: DetailedRecipe(
            name: "Test IPA",
            style: "American IPA",
            abv: 6.2,
            ibu: 65,
            difficulty: .intermediate,
            brewTime: 300,
            ingredients: [
                RecipeIngredient(name: "Pale Ale Mout", amount: "4.5 kg", type: .grain, timing: "Maischen"),
                RecipeIngredient(name: "Crystal 60L", amount: "0.5 kg", type: .grain, timing: "Maischen"),
                RecipeIngredient(name: "Centennial Hop", amount: "25 g", type: .hop, timing: "60 min")
            ],
            instructions: [
                "Verwarm 18L water naar 66°C",
                "Maisch alle granen 60 minuten",
                "Spoel tot 23L wort"
            ],
            notes: "Test recept voor scaling"
        ),
        originalBatchSize: 23.0
    )
    .environmentObject(LocalizationManager.shared)
} 