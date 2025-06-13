//
//  MainTabView.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 09/06/2025.
//


import SwiftUI
import UniformTypeIdentifiers

// MARK: - Color Extensions for Dark Mode Support
extension Color {
    // Semantic colors for brewing app
    static let primaryCard = Color(UIColor.secondarySystemBackground)
    static let secondaryCard = Color(UIColor.tertiarySystemBackground)
    static let labelPrimary = Color(UIColor.label)
    static let labelSecondary = Color(UIColor.secondaryLabel)
    static let separatorColor = Color(UIColor.separator)
}

struct MainTabView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedRecipeForBrewing: DetailedRecipe?
    @State private var showingLanguageSettings = false
    @State private var recipes = DefaultRecipesDatabase.getAllDefaultRecipes()
    
    var body: some View {
        TabView {
            // 1. RECEPTEN - Main recipe management
            SimpleRecipeListView(selectedRecipeForBrewing: $selectedRecipeForBrewing, recipes: $recipes)
                .tabItem {
                    Label("tab.recipes".localized, systemImage: "book.closed.fill")
                }
            
            // 2. BROUWEN - Brewing process with timers
            SimpleBrewTrackerView(selectedRecipe: selectedRecipeForBrewing)
                .tabItem {
                    Label("tab.brewing".localized, systemImage: "timer.circle.fill")
                }
            
            // 3. CALCULATORS - All brewing calculators combined
            CalculatorsView()
                .tabItem {
                    Label("tab.calculators".localized, systemImage: "function")
                }
            
            // 4. INGREDIËNTEN - Inventory management  
            SmartIngredientsView(selectedRecipe: selectedRecipeForBrewing, allRecipes: $recipes)
                .tabItem {
                    Label("tab.inventory".localized, systemImage: "list.clipboard.fill")
                }
            
            // 5. MEER - Analytics, Photos, Settings, More tools
            MoreView(selectedRecipeForBrewing: $selectedRecipeForBrewing, recipes: $recipes)
                .tabItem {
                    Label("tab.more".localized, systemImage: "ellipsis.circle.fill")
                }
        }
        .sheet(isPresented: $showingLanguageSettings) {
            LanguageSettingsView()
        }
        .overlay(alignment: .topTrailing) {
            // Quick language switcher (floating)
            Button(action: {
                // Toggle between Dutch and English
                if localizationManager.currentLanguage == .dutch {
                    localizationManager.changeLanguage(to: .english)
                } else {
                    localizationManager.changeLanguage(to: .dutch)
                }
            }) {
                HStack(spacing: 4) {
                    Text(localizationManager.currentLanguage.flag)
                        .font(.system(size: 14))
                    Text(localizationManager.currentLanguage.rawValue.uppercased())
                        .font(.caption2.bold())
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption2)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.brewTheme.opacity(0.95))
                .foregroundColor(.white)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .padding(.trailing, 16)
            .padding(.top, 32) // Moved even higher, closer to status bar
        }
    }
}

struct SimpleRecipeListView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Binding var selectedRecipeForBrewing: DetailedRecipe?
    @Binding var recipes: [DetailedRecipe]
    @State private var showingAddRecipe = false
    @State private var selectedRecipe: DetailedRecipe?
    @State private var selectedRecipeForScaling: DetailedRecipe?
    @State private var searchText = ""
    @State private var showingXMLImport = false
    @State private var showingAbout = false
    @State private var showingBeerXMLImportExport = false
    @State private var showingAIGenerator = false
    
    var filteredRecipes: [DetailedRecipe] {
        if searchText.isEmpty {
            return recipes
        } else {
            return recipes.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(searchText) ||
                recipe.style.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header in brouwtracker style
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.brewTheme)
                                            VStack(alignment: .leading) {
                        Text("recipes.title".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                        if let recipe = selectedRecipeForBrewing {
                            Text("🍺 \("recipes.selected".localized): \(recipe.name)")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("recipes.select.instruction".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                        Spacer()
                                            Text("recipes.count".localized(with: filteredRecipes.count))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.primaryCard)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("recipes.search.placeholder".localized, text: $searchText)
                }
                .padding()
                .background(Color.primaryCard)
                .cornerRadius(10)
                .padding()
                
                List {
                    ForEach(filteredRecipes) { recipe in
                        VStack(alignment: .leading, spacing: 8) {
                            SimpleRecipeRowView(recipe: recipe)
                                .onTapGesture {
                                    selectedRecipe = recipe
                                }
                            
                            HStack {
                                Button("📖 \("recipes.details".localized)") {
                                    selectedRecipe = recipe
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                
                                Button("📏 Schaal") {
                                    selectedRecipeForScaling = recipe
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                
                                Spacer()
                                
                                Button("🍺 \("recipes.use.for.brewing".localized)") {
                                    selectedRecipeForBrewing = recipe
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteRecipe)
                }
                
                VStack(spacing: 12) {
                    HStack(spacing: 15) {
                        Button("🤖 AI Generator") {
                            showingAIGenerator = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                        .tint(.purple)
                        
                        Button("recipes.add".localized) {
                            showingAddRecipe = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button("📥 \("recipes.import".localized)") {
                        showingXMLImport = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .navigationBarHidden(false)
            .navigationTitle("HomeBrewAssistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingBeerXMLImportExport = true
                    } label: {
                        Image(systemName: "square.and.arrow.up.on.square")
                            .foregroundColor(.brewTheme)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // AI Recipe Generator Button
                        Button(action: {
                            showingAIGenerator = true
                        }) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.purple)
                        }
                        
                        Button {
                            showingAbout = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.brewTheme)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
                    .environmentObject(localizationManager)
            }
            .sheet(isPresented: $showingBeerXMLImportExport) {
                BeerXMLImportExportView(recipes: $recipes)
                    .environmentObject(localizationManager)
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView { newRecipe in
                    recipes.append(newRecipe)
                }
            }
            .sheet(isPresented: $showingXMLImport) {
                XMLImportView { importedRecipes in
                    recipes.append(contentsOf: importedRecipes)
                }
            }
            .sheet(item: $selectedRecipe) { recipe in
                SimpleRecipeDetailView(recipe: recipe)
            }
            .sheet(item: $selectedRecipeForScaling) { recipe in
                RecipeScalingView(recipe: recipe, originalBatchSize: 23.0)
                    .environmentObject(localizationManager)
            }
            .sheet(isPresented: $showingAIGenerator) {
                AIRecipeGeneratorView(recipes: $recipes)
            }
        }
    }
    
    private func deleteRecipe(at offsets: IndexSet) {
        recipes.remove(atOffsets: offsets)
    }
}

struct InfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🍺 Gravity Uitleg")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("**Original Gravity (OG)** is het soortelijk gewicht van je wort vóór fermentatie. Dit meet hoeveel suikers er in je wort zitten.")
                        
                        Text("**Final Gravity (FG)** is het soortelijk gewicht ná fermentatie. Dit toont hoeveel suikers er overgebleven zijn.")
                        
                        Text("Het verschil tussen OG en FG bepaalt hoeveel alcohol er geproduceerd is.")
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("📊 Typische Waarden")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("• **Light bieren**: OG 1.030-1.040")
                        Text("• **Standaard bieren**: OG 1.040-1.060")
                        Text("• **Sterke bieren**: OG 1.060-1.080")
                        Text("• **Zeer sterke bieren**: OG 1.080+")
                        
                        Divider()
                        
                        Text("• **Droge bieren**: FG 1.008-1.012")
                        Text("• **Medium bieren**: FG 1.012-1.016")
                        Text("• **Zoete bieren**: FG 1.016-1.020")
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🧮 Berekeningen")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("**ABV**: (OG - FG) × 131.25")
                        Text("**Attenuation**: ((OG - FG) / (OG - 1.000)) × 100%")
                        Text("**Calorieën**: Gebaseerd op alcohol en restsuikers")
                        Text("**Alcohol opbrengst**: ABV × 7.94 gram/liter")
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 Voorbeeld")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Voor een **standaard pilsener**:")
                        Text("• OG: 1.050 (5% suikers)")
                        Text("• FG: 1.010 (1% restsuikers)")
                        Text("• ABV: (1.050 - 1.010) × 131.25 = **5.25%**")
                        Text("• Attenuation: 80% (goede vergisting)")
                    }
                }
                .padding()
            }
            .navigationTitle("Uitleg")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SimpleRecipeRowView: View {
    let recipe: DetailedRecipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(recipe.name)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                DifficultyBadge(difficulty: recipe.difficulty)
            }
            
            Text(recipe.style)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(String(format: "%.1f%%", recipe.abv), systemImage: "drop.fill")
                Label("\(recipe.ibu)", systemImage: "leaf.fill")
                Label("\(recipe.brewTime) min", systemImage: "clock.fill")
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.brewTheme)
        }
        .padding(.vertical, 4)
    }
}

struct DifficultyBadge: View {
    let difficulty: RecipeDifficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(difficulty.color.opacity(0.2))
            .foregroundColor(difficulty.color)
            .cornerRadius(8)
    }
}

struct SimpleRecipeDetailView: View {
    let recipe: DetailedRecipe
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(recipe.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(recipe.style)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        DifficultyBadge(difficulty: recipe.difficulty)
                    }
                    
                    HStack(spacing: 20) {
                        StatView(title: "ABV", value: String(format: "%.1f%%", recipe.abv), color: .green)
                        StatView(title: "IBU", value: "\(recipe.ibu)", color: .orange)
                        StatView(title: "Tijd", value: "\(recipe.brewTime) min", color: .blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Tab selector
                Picker("", selection: $selectedTab) {
                    Text("Ingrediënten").tag(0)
                    Text("Instructies").tag(1)
                    Text("Notities").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                ScrollView {
                    Group {
                        switch selectedTab {
                        case 0:
                            IngredientsTabView(ingredients: recipe.ingredients)
                        case 1:
                            InstructionsTabView(instructions: recipe.instructions)
                        case 2:
                            NotesTabView(notes: recipe.notes)
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Recept Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct IngredientsTabView: View {
    let ingredients: [RecipeIngredient]
    
    var grainIngredients: [RecipeIngredient] {
        ingredients.filter { $0.type == .grain }
    }
    
    var hopIngredients: [RecipeIngredient] {
        ingredients.filter { $0.type == .hop }
    }
    
    var yeastIngredients: [RecipeIngredient] {
        ingredients.filter { $0.type == .yeast }
    }
    
    var otherIngredients: [RecipeIngredient] {
        ingredients.filter { $0.type == .other }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if !grainIngredients.isEmpty {
                IngredientSection(title: "Granen", ingredients: grainIngredients, icon: "leaf.fill", color: .brown)
            }
            
            if !hopIngredients.isEmpty {
                IngredientSection(title: "Hoppen", ingredients: hopIngredients, icon: "leaf.fill", color: .green)
            }
            
            if !yeastIngredients.isEmpty {
                IngredientSection(title: "Gist", ingredients: yeastIngredients, icon: "drop.circle.fill", color: .yellow)
            }
            
            if !otherIngredients.isEmpty {
                IngredientSection(title: "Overig", ingredients: otherIngredients, icon: "plus.circle.fill", color: .gray)
            }
        }
    }
}

struct IngredientSection: View {
    let title: String
    let ingredients: [RecipeIngredient]
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            ForEach(ingredients) { ingredient in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
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
                        .foregroundColor(color)
                }
                .padding(.leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InstructionsTabView: View {
    let instructions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Brouwinstructies")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.brewTheme)
                        .frame(width: 25, alignment: .center)
                        .padding(.top, 2)
                    
                    Text(instruction)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
    }
}

struct NotesTabView: View {
    let notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Brouwnotities")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(notes)
                .font(.body)
                .multilineTextAlignment(.leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (DetailedRecipe) -> Void
    
    @State private var name = ""
    @State private var style = ""
    @State private var abv = ""
    @State private var ibu = ""
    @State private var difficulty = RecipeDifficulty.beginner
    @State private var brewTime = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basis Informatie")) {
                    TextField("Recept naam", text: $name)
                    TextField("Bierstijl", text: $style)
                    TextField("ABV %", text: $abv)
                        .keyboardType(.decimalPad)
                    TextField("IBU", text: $ibu)
                        .keyboardType(.numberPad)
                    TextField("Brouwtijd (minuten)", text: $brewTime)
                        .keyboardType(.numberPad)
                    
                    Picker("Moeilijkheidsgraad", selection: $difficulty) {
                        ForEach(RecipeDifficulty.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                
                Section(header: Text("Notities")) {
                    TextField("Brouwnotities en tips", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Nieuw Recept")
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
                    .disabled(name.isEmpty || style.isEmpty)
                }
            }
        }
    }
    
    private func saveRecipe() {
        let newRecipe = DetailedRecipe(
            name: name,
            style: style,
            abv: Double(abv) ?? 0.0,
            ibu: Int(ibu) ?? 0,
            difficulty: difficulty,
            brewTime: Int(brewTime) ?? 0,
            ingredients: [], // Simplified for now
            instructions: [],
            notes: notes
        )
        
        onSave(newRecipe)
        dismiss()
    }
}

struct DetailedRecipe: Identifiable {
    let id = UUID()
    let name: String
    let style: String
    let abv: Double
    let ibu: Int
    let difficulty: RecipeDifficulty
    let brewTime: Int // minutes
    let ingredients: [RecipeIngredient]
    let instructions: [String]
    let notes: String
}

struct RecipeIngredient: Identifiable {
    let id = UUID()
    let name: String
    let amount: String
    let type: IngredientType
    let timing: String
}



enum RecipeDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Gevorderd"
    case advanced = "Expert"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

struct SmartIngredientsView: View {
    let selectedRecipe: DetailedRecipe?
    @Binding var allRecipes: [DetailedRecipe]
    @State private var currentView: IngredientsViewMode = .inventory
    @State private var ingredients = [
        SimpleIngredient(name: "Pilsner Mout", category: "Graan", amount: "5 kg"),
        SimpleIngredient(name: "Saaz Hop", category: "Hop", amount: "30 g"),
        SimpleIngredient(name: "SafLager W-34/70", category: "Gist", amount: "1 pak"),
        SimpleIngredient(name: "Crystal 60L", category: "Graan", amount: "0.5 kg"),
        SimpleIngredient(name: "Cascade Hop", category: "Hop", amount: "25 g"),
    ]
    @State private var newIngredientName = ""
    @State private var newIngredientAmount = ""
    @State private var selectedCategory = "Graan"
    @State private var showingShoppingList = false
    @State private var selectedRecipesForShopping: Set<UUID> = []
    
    private let categories = ["Graan", "Hop", "Gist", "Overig"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: currentView == .inventory ? "list.clipboard.fill" : "cart.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(currentView == .inventory ? "Ingrediënten Voorraad" : "Slimme Boodschappenlijst")
                                .font(.title2)
                                .fontWeight(.bold)
                            if let recipe = selectedRecipe, currentView == .inventory {
                                Text("📖 Voor recept: \(recipe.name)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else if currentView == .inventory {
                                Text("Beheer je brouw ingrediënten")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Automatisch gegenereerd uit recepten")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Text(currentView == .inventory ? "\(ingredients.count) items" : "\(selectedRecipesForShopping.count) recepten")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                
                // View Mode Picker
                Picker("Weergave", selection: $currentView) {
                    Text("Voorraad").tag(IngredientsViewMode.inventory)
                    Text("Boodschappen").tag(IngredientsViewMode.shopping)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if currentView == .inventory {
                    InventoryView(
                        ingredients: $ingredients,
                        newIngredientName: $newIngredientName,
                        newIngredientAmount: $newIngredientAmount,
                        selectedCategory: $selectedCategory,
                        categories: categories
                    )
                } else {
                    SmartShoppingListView(
                        allRecipes: allRecipes,
                        currentInventory: ingredients,
                        selectedRecipes: $selectedRecipesForShopping
                    )
                }
            }
            .navigationBarHidden(true)
        }
    }
}

enum IngredientsViewMode {
    case inventory
    case shopping
}

struct InventoryView: View {
    @Binding var ingredients: [SimpleIngredient]
    @Binding var newIngredientName: String
    @Binding var newIngredientAmount: String
    @Binding var selectedCategory: String
    let categories: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(ingredients.grouped) { group in
                    Section(group.category) {
                        ForEach(group.items) { ingredient in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(ingredient.name)
                                        .font(.headline)
                                    Text(ingredient.amount)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .onDelete { indexSet in
                            let itemsToDelete = indexSet.map { group.items[$0] }
                            ingredients.removeAll { item in
                                itemsToDelete.contains { $0.id == item.id }
                            }
                        }
                    }
                }
            }
            
            VStack(spacing: 10) {
                HStack {
                    TextField("Ingredient naam", text: $newIngredientName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Hoeveelheid", text: $newIngredientAmount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    Picker("Categorie", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Button("Toevoegen") {
                        if !newIngredientName.isEmpty && !newIngredientAmount.isEmpty {
                            ingredients.append(SimpleIngredient(
                                name: newIngredientName,
                                category: selectedCategory,
                                amount: newIngredientAmount
                            ))
                            newIngredientName = ""
                            newIngredientAmount = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}

struct SmartShoppingListView: View {
    let allRecipes: [DetailedRecipe]
    let currentInventory: [SimpleIngredient]
    @Binding var selectedRecipes: Set<UUID>
    @State private var shoppingItems: [ShoppingItem] = []
    @State private var showingRecipeSelector = false
    @State private var estimatedTotal: Double = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Recipe Selection Section
            VStack(spacing: 15) {
                HStack {
                    Text("Selecteer Recepten")
                        .font(.headline)
                    Spacer()
                    Button("Kies Recepten") {
                        showingRecipeSelector = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                if selectedRecipes.isEmpty {
                    Text("Geen recepten geselecteerd")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(selectedRecipeObjects, id: \.id) { recipe in
                                HStack(spacing: 4) {
                                    Text(recipe.name)
                                        .font(.caption)
                                    Button("×") {
                                        selectedRecipes.remove(recipe.id)
                                        generateShoppingList()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            if !shoppingItems.isEmpty {
                // Shopping List
                List {
                    Section {
                        ForEach(shoppingItems.indices, id: \.self) { index in
                            ShoppingItemRow(
                                item: $shoppingItems[index],
                                onToggle: {
                                    calculateTotal()
                                }
                            )
                        }
                    } header: {
                        HStack {
                            Text("Boodschappenlijst")
                            Spacer()
                            Text("Geschat: €\(String(format: "%.2f", estimatedTotal))")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Section {
                        HStack {
                            Text("Totaal Geschat")
                                .font(.headline)
                            Spacer()
                            Text("€\(String(format: "%.2f", estimatedTotal))")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Action Buttons
                HStack(spacing: 15) {
                    Button("Alles Afvinken") {
                        shoppingItems.indices.forEach { index in
                            shoppingItems[index].isPurchased = true
                        }
                        calculateTotal()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button("Lijst Wissen") {
                        shoppingItems = []
                        selectedRecipes = []
                        estimatedTotal = 0.0
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button("Naar Voorraad") {
                        addPurchasedToInventory()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(shoppingItems.allSatisfy { !$0.isPurchased })
                }
                .padding()
            } else {
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "cart")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("Selecteer recepten om een slimme boodschappenlijst te genereren")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Text("💡 Alleen ontbrekende ingrediënten worden toegevoegd")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            }
        }
        .sheet(isPresented: $showingRecipeSelector) {
            RecipeSelectorView(
                recipes: allRecipes,
                selectedRecipes: $selectedRecipes,
                onSelectionChange: generateShoppingList
            )
        }
        .onAppear {
            if !selectedRecipes.isEmpty {
                generateShoppingList()
            }
        }
    }
    
    private var selectedRecipeObjects: [DetailedRecipe] {
        allRecipes.filter { selectedRecipes.contains($0.id) }
    }
    
    private func generateShoppingList() {
        var items: [ShoppingItem] = []
        
        // Collect all ingredients from selected recipes
        for recipe in selectedRecipeObjects {
            for ingredient in recipe.ingredients {
                // Check if we already have this ingredient in inventory
                let hasInInventory = currentInventory.contains { inv in
                    inv.name.localizedCaseInsensitiveContains(ingredient.name) ||
                    ingredient.name.localizedCaseInsensitiveContains(inv.name)
                }
                
                if !hasInInventory {
                    // Check if already in shopping list
                    if let existingIndex = items.firstIndex(where: { $0.name.localizedCaseInsensitiveContains(ingredient.name) }) {
                        // Update quantity if needed (simplified for now)
                        items[existingIndex].recipes.append(recipe.name)
                    } else {
                        let estimatedPrice = estimatePrice(for: ingredient)
                        items.append(ShoppingItem(
                            name: ingredient.name,
                            amount: ingredient.amount,
                            category: categorizeIngredient(ingredient),
                            estimatedPrice: estimatedPrice,
                            recipes: [recipe.name]
                        ))
                    }
                }
            }
        }
        
        shoppingItems = items.sorted { $0.category < $1.category }
        calculateTotal()
    }
    
    private func categorizeIngredient(_ ingredient: RecipeIngredient) -> String {
        switch ingredient.type {
        case .grain:
            return "Graan"
        case .hop:
            return "Hop"
        case .yeast:
            return "Gist"
        case .adjunct:
            return "Adjunct"
        case .other:
            return "Overig"
        }
    }
    
    private func estimatePrice(for ingredient: RecipeIngredient) -> Double {
        // Simple price estimation based on ingredient type and amount
        let basePrice: Double
        switch ingredient.type {
        case .grain:
            basePrice = 2.50 // per kg
        case .hop:
            basePrice = 0.05 // per gram (realistic pricing: €50/kg)
        case .yeast:
            basePrice = 3.50 // per packet
        case .adjunct:
            basePrice = 4.00 // per kg
        case .other:
            basePrice = 5.00 // generic
        }
        
        // Extract numeric amount (simplified)
        let amountString = ingredient.amount.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        let amount = Double(amountString) ?? 1.0
        
        return basePrice * amount
    }
    
    private func calculateTotal() {
        estimatedTotal = shoppingItems.reduce(0) { total, item in
            total + (item.isPurchased ? 0 : item.estimatedPrice)
        }
    }
    
    private func addPurchasedToInventory() {
        // This would add purchased items to inventory
        // For now, just mark them as handled
        shoppingItems.removeAll { $0.isPurchased }
        calculateTotal()
    }
}

struct ShoppingItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: String
    let category: String
    let estimatedPrice: Double
    var isPurchased: Bool = false
    var recipes: [String]
}

struct ShoppingItemRow: View {
    @Binding var item: ShoppingItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                item.isPurchased.toggle()
                onToggle()
            }) {
                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isPurchased ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .strikethrough(item.isPurchased)
                    .foregroundColor(item.isPurchased ? .secondary : .primary)
                
                HStack {
                    Text(item.amount)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(item.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if item.recipes.count > 1 {
                    Text("Voor: \(item.recipes.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("€\(String(format: "%.2f", item.estimatedPrice))")
                    .font(.caption)
                    .foregroundColor(item.isPurchased ? .secondary : .green)
                    .strikethrough(item.isPurchased)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RecipeSelectorView: View {
    let recipes: [DetailedRecipe]
    @Binding var selectedRecipes: Set<UUID>
    let onSelectionChange: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recipes) { recipe in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.headline)
                            Text(recipe.style)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedRecipes.contains(recipe.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedRecipes.contains(recipe.id) {
                            selectedRecipes.remove(recipe.id)
                        } else {
                            selectedRecipes.insert(recipe.id)
                        }
                    }
                }
            }
            .navigationTitle("Selecteer Recepten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Wissen") {
                        selectedRecipes.removeAll()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Klaar") {
                        onSelectionChange()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SimpleIngredient: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let amount: String
}

struct IngredientGroup: Identifiable {
    let id = UUID()
    let category: String
    let items: [SimpleIngredient]
}

extension Array where Element == SimpleIngredient {
    var grouped: [IngredientGroup] {
        let groupedDict = Dictionary(grouping: self) { $0.category }
        return groupedDict.map { IngredientGroup(category: $0.key, items: $0.value) }
            .sorted { $0.category < $1.category }
    }
}

struct SimpleBrewTrackerView: View {
    let selectedRecipe: DetailedRecipe?
    @State private var isBrewingActive = false
    @State private var currentStep = 0
    @State private var stepTimer: Timer?
    @State private var elapsedTime = 0
    @State private var isTimerRunning = false
    @State private var showingStepDetail = false
    @State private var showingDataEntry = false
    @State private var brewStartTime = Date()
    
    // Tracking data
    @State private var currentSession: ActiveBrewSession?
    @State private var currentTemperature = ""
    @State private var currentNotes = ""
    @State private var currentGravity = ""
    
    private var brewingSteps: [BrewStep] {
        return generateBrewingSteps(from: selectedRecipe)
    }
    
    private let defaultBrewingSteps = [
        BrewStep(name: "Graan malen", duration: 15, description: "Maal de granen tot de juiste grofheid", tips: "Gebruik een grove maling voor all-grain, fijnere voor extract", requiresTemperature: false, targetTemperature: ""),
        BrewStep(name: "Maischen", duration: 60, description: "Houd temperatuur tussen 65-68°C", tips: "Roer om de 15 minuten voor gelijke temperatuur", requiresTemperature: true, targetTemperature: "65-68°C"),
        BrewStep(name: "Spoelen", duration: 30, description: "Spoel met 78°C water", tips: "Stop bij 1.010 SG om tannines te vermijden", requiresTemperature: true, targetTemperature: "78°C"),
        BrewStep(name: "Koken", duration: 60, description: "Breng aan de kook en houd rollend", tips: "Voeg hoppen toe volgens recept timing", requiresTemperature: true, targetTemperature: "100°C"),
        BrewStep(name: "Hoppen toevoegen", duration: 5, description: "Voeg hoppen toe op juiste momenten", tips: "Bittere hoppen 60 min, aroma hoppen 5 min", requiresTemperature: false, targetTemperature: ""),
        BrewStep(name: "Koelen", duration: 20, description: "Koel snel naar gisttemperatuur", tips: "Streef naar 18-22°C voor ales, 8-12°C voor lagers", requiresTemperature: true, targetTemperature: "18-22°C"),
        BrewStep(name: "Gist toevoegen", duration: 10, description: "Voeg gehydrateerde gist toe", tips: "Zorg dat wort onder 25°C is", requiresTemperature: true, targetTemperature: "< 25°C"),
        BrewStep(name: "Primaire fermentatie", duration: 10080, description: "7 dagen fermentatie", tips: "Houd temperatuur stabiel, vermijd licht", requiresTemperature: true, targetTemperature: "18-22°C"),
        BrewStep(name: "Secundaire fermentatie", duration: 20160, description: "14 dagen nacuring", tips: "Optioneel: voeg dry hops toe", requiresTemperature: true, targetTemperature: "18-22°C"),
        BrewStep(name: "Bottelen", duration: 30, description: "Bottelen met priming sugar", tips: "Saniteer alles, vermijd oxidatie", requiresTemperature: false, targetTemperature: "")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header in consistent style
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: isBrewingActive ? "drop.fill" : "timer.circle.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(isBrewingActive ? "Actieve Brouwsessie" : "Brouwtracker")
                                .font(.title2)
                                .fontWeight(.bold)
                            if let recipe = selectedRecipe {
                                Text("📖 \(recipe.name)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else if !isBrewingActive {
                                Text("Klaar om te brouwen")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        if isBrewingActive {
                            Text("Stap \(currentStep + 1)/\(brewingSteps.count)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        } else {
                            Text("\(brewingSteps.count) stappen")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                    }
                    
                    if isBrewingActive {
                        Text("Totale tijd: \(formatTime(Int(Date().timeIntervalSince(brewStartTime))))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                
                if isBrewingActive {
                    // Current step card
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(brewingSteps[currentStep].name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                if brewingSteps[currentStep].requiresTemperature {
                                    HStack {
                                        Image(systemName: "thermometer")
                                            .foregroundColor(.orange)
                                        Text("Doel: \(brewingSteps[currentStep].targetTemperature)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Visual indicators
                            VStack(spacing: 4) {
                                if hasDataForCurrentStep() {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                }
                                
                                if brewingSteps[currentStep].requiresTemperature {
                                    Image(systemName: "thermometer")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                }
                            }
                        }
                        
                        // Timer display
                        VStack(spacing: 10) {
                            Text(formatTime(elapsedTime))
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                                .foregroundColor(isTimerRunning ? .green : .primary)
                            
                            if brewingSteps[currentStep].duration > 0 {
                                Text("van \(formatTime(brewingSteps[currentStep].duration * 60))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ProgressView(value: Double(elapsedTime), 
                                           total: Double(brewingSteps[currentStep].duration * 60))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                            }
                        }
                        
                        // Primary Timer Controls
                        HStack(spacing: 15) {
                            Button {
                                toggleTimer()
                            } label: {
                                HStack {
                                    Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                    Text(isTimerRunning ? "Pause" : "Start")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            
                            Button {
                                resetTimer()
                            } label: {
                                HStack {
                                    Image(systemName: "gobackward")
                                    Text("Reset")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                        
                        // Secondary Actions Row
                        HStack(spacing: 12) {
                            Button {
                                showingStepDetail = true
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "info.circle")
                                    Text("Info")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                            
                            Button {
                                showingDataEntry = true
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: hasDataForCurrentStep() ? "checkmark.circle.fill" : "pencil.circle")
                                        .foregroundColor(hasDataForCurrentStep() ? .green : .primary)
                                    Text("Data")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                            
                            Button {
                                // Quick complete step
                                stopTimer()
                                
                                // Mark current step as completed
                                if currentSession != nil {
                                    currentSession?.stepData[currentStep].isCompleted = true
                                    currentSession?.stepData[currentStep].endTime = Date()
                                    currentSession?.stepData[currentStep].actualDuration = elapsedTime
                                }
                                
                                // Save any default data if none was entered
                                if !hasDataForCurrentStep() {
                                    if brewingSteps[currentStep].requiresTemperature {
                                        currentTemperature = brewingSteps[currentStep].targetTemperature.components(separatedBy: "-").first ?? ""
                                    }
                                    currentNotes = "Stap voltooid"
                                }
                                
                                // Move to next step
                                nextStep()
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle")
                                    Text("Klaar")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                            .disabled(currentStep == brewingSteps.count - 1)
                        }
                        
                        // Navigation
                        HStack(spacing: 15) {
                            Button {
                                previousStep()
                            } label: {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Vorige Stap")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(currentStep == 0)
                            
                            Button {
                                nextStep()
                            } label: {
                                HStack {
                                    Text("Volgende Stap")
                                    Image(systemName: "chevron.right")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(currentStep == brewingSteps.count - 1)
                        }
                        
                        // End Session (separated and more prominent)
                        Button {
                            endSession()
                        } label: {
                            HStack {
                                Image(systemName: "stop.circle")
                                Text("Sessie Beëindigen")
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    
                } else {
                    // Start screen - content without duplicate header
                    VStack(spacing: 20) {
                        
                        VStack(spacing: 15) {
                            Text("Deze sessie bevat \(brewingSteps.count) stappen:")
                                .font(.headline)
                            
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(0..<brewingSteps.count, id: \.self) { index in
                                        HStack {
                                            Text("\(index + 1).")
                                                .fontWeight(.medium)
                                                .frame(width: 25, alignment: .leading)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(brewingSteps[index].name)
                                                
                                                if brewingSteps[index].requiresTemperature {
                                                    HStack {
                                                        Image(systemName: "thermometer")
                                                            .foregroundColor(.orange)
                                                        Text(brewingSteps[index].targetTemperature)
                                                    }
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 4) {
                                                if brewingSteps[index].requiresTemperature {
                                                    Image(systemName: "thermometer")
                                                        .foregroundColor(.orange)
                                                        .font(.caption)
                                                }
                                                
                                                if brewingSteps[index].duration > 0 {
                                                    Text("\(brewingSteps[index].duration) min")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 2)
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        Button("Start Nieuwe Brouwsessie") {
                            startSession()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .sheet(isPresented: $showingStepDetail) {
                StepDetailView(step: brewingSteps[currentStep])
            }
            .sheet(isPresented: $showingDataEntry) {
                DataEntryView(
                    step: brewingSteps[currentStep],
                    temperature: $currentTemperature,
                    notes: $currentNotes,
                    gravity: $currentGravity
                )
            }
        }
    }
    
    private func startSession() {
        isBrewingActive = true
        currentStep = 0
        elapsedTime = 0
        brewStartTime = Date()
        
        // Initialize session data
        let stepData = brewingSteps.map { _ in
            StepData(stepIndex: 0, startTime: nil, endTime: nil, actualDuration: 0, temperature: nil, notes: "", gravity: nil, isCompleted: false)
        }
        
                                currentSession = ActiveBrewSession(
            startDate: brewStartTime,
            isActive: true,
            currentStep: 0,
            stepData: stepData
        )
        
        // Clear current data
        currentTemperature = ""
        currentNotes = ""
        currentGravity = ""
    }
    
    private func endSession() {
        isBrewingActive = false
        stopTimer()
        currentStep = 0
        elapsedTime = 0
    }
    
    private func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        stepTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        stepTimer?.invalidate()
        stepTimer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        elapsedTime = 0
    }
    
    private func nextStep() {
        if currentStep < brewingSteps.count - 1 {
            currentStep += 1
            resetTimer()
        }
    }
    
    private func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
            resetTimer()
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    private func hasDataForCurrentStep() -> Bool {
        return !currentTemperature.isEmpty || !currentNotes.isEmpty || !currentGravity.isEmpty
    }
    
    private func generateBrewingSteps(from recipe: DetailedRecipe?) -> [BrewStep] {
        guard let recipe = recipe else {
            return defaultBrewingSteps
        }
        
        var steps = defaultBrewingSteps
        
        // Stap 1: Graan malen - voeg grain ingrediënten toe
        let grainIngredients = recipe.ingredients.filter { $0.type == .grain }
        steps[0].recipeIngredients = grainIngredients
        
        // Stap 2: Maischen - voeg grain ingrediënten en instructies toe
        steps[1].recipeIngredients = grainIngredients
        let maischInstructions = recipe.instructions.filter { instruction in
            instruction.lowercased().contains("maisch") || instruction.lowercased().contains("mout")
        }
        steps[1].recipeInstructions = maischInstructions
        
        // Stap 3: Spoelen - relevante instructies
        let spoelingInstructions = recipe.instructions.filter { instruction in
            instruction.lowercased().contains("spoel") || instruction.lowercased().contains("water")
        }
        steps[2].recipeInstructions = spoelingInstructions
        
        // Stap 4: Koken - hop ingrediënten en instructies
        let hopIngredients = recipe.ingredients.filter { $0.type == .hop }
        steps[3].recipeIngredients = hopIngredients
        let kookInstructions = recipe.instructions.filter { instruction in
            instruction.lowercased().contains("kook") || instruction.lowercased().contains("hop")
        }
        steps[3].recipeInstructions = kookInstructions
        
        // Stap 5: Hoppen toevoegen - specifieke hop timings
        let bitternessHops = hopIngredients.filter { $0.timing.contains("60") || $0.timing.contains("bitt") }
        let aromaHops = hopIngredients.filter { $0.timing.contains("5") || $0.timing.contains("15") || $0.timing.contains("aroma") }
        steps[4].recipeIngredients = bitternessHops + aromaHops
        
        // Stap 6: Koelen - instructies
        let koelingInstructions = recipe.instructions.filter { instruction in
            instruction.lowercased().contains("koel") || instruction.lowercased().contains("temperatuur")
        }
        steps[5].recipeInstructions = koelingInstructions
        
        // Stap 7: Gist toevoegen - yeast ingrediënten
        let yeastIngredients = recipe.ingredients.filter { $0.type == .yeast }
        steps[6].recipeIngredients = yeastIngredients
        let gistInstructions = recipe.instructions.filter { instruction in
            instruction.lowercased().contains("gist") || instruction.lowercased().contains("ferment")
        }
        steps[6].recipeInstructions = gistInstructions
        
        // Stap 8: Primaire fermentatie
        steps[7].recipeIngredients = yeastIngredients
        steps[7].duration = extractFermentationTime(from: recipe.instructions, primary: true)
        
        // Stap 9: Secundaire fermentatie
        let dryHopIngredients = recipe.ingredients.filter { $0.timing.lowercased().contains("dry") }
        steps[8].recipeIngredients = dryHopIngredients
        steps[8].duration = extractFermentationTime(from: recipe.instructions, primary: false)
        
        // Stap 10: Bottelen
        let bottelingInstructions = recipe.instructions.filter { instruction in
            instruction.lowercased().contains("bottelen") || instruction.lowercased().contains("suiker")
        }
        steps[9].recipeInstructions = bottelingInstructions
        
        return steps
    }
    
    private func extractFermentationTime(from instructions: [String], primary: Bool) -> Int {
        let searchTerms = primary ? ["week", "dag", "primair"] : ["week", "dag", "secundair", "nacur"]
        
        for instruction in instructions {
            let lowered = instruction.lowercased()
            for term in searchTerms {
                if lowered.contains(term) {
                    // Probeer dagen of weken te extraheren
                    if let weekMatch = lowered.range(of: #"(\d+)\s*week"#, options: .regularExpression) {
                        if let weeks = Int(String(lowered[weekMatch]).components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                            return weeks * 7 * 24 * 60 // convert to minutes
                        }
                    }
                    if let dayMatch = lowered.range(of: #"(\d+)\s*dag"#, options: .regularExpression) {
                        if let days = Int(String(lowered[dayMatch]).components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                            return days * 24 * 60 // convert to minutes
                        }
                    }
                }
            }
        }
        
        // Default times
        return primary ? 10080 : 20160 // 1 week / 2 weeks in minutes
    }
}

struct BrewStep {
    let name: String
    var duration: Int // in minutes
    let description: String
    let tips: String
    let requiresTemperature: Bool
    let targetTemperature: String
    var recipeIngredients: [RecipeIngredient] = []
    var recipeInstructions: [String] = []
}

struct ActiveBrewSession {
    var id = UUID()
    var startDate: Date
    var isActive: Bool
    var currentStep: Int
    var stepData: [StepData]
}

struct StepData {
    var stepIndex: Int
    var startTime: Date?
    var endTime: Date?
    var actualDuration: Int
    var temperature: Double?
    var notes: String
    var gravity: Double?
    var isCompleted: Bool
}

struct StepDetailView: View {
    let step: BrewStep
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(step.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Temperature info if required
                    if step.requiresTemperature {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("🌡️ Temperatuur:")
                                .font(.headline)
                            Text("Doel: \(step.targetTemperature)")
                                .font(.body)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Recipe ingredients for this step
                    if !step.recipeIngredients.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("🥄 Ingrediënten voor deze stap:")
                                .font(.headline)
                            
                            ForEach(step.recipeIngredients, id: \.name) { ingredient in
                                HStack {
                                    Text("• \(ingredient.amount) \(ingredient.name)")
                                        .font(.body)
                                    Spacer()
                                    Text(ingredient.timing)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Recipe instructions for this step
                    if !step.recipeInstructions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("📋 Recept Instructies:")
                                .font(.headline)
                            
                            ForEach(Array(step.recipeInstructions.enumerated()), id: \.offset) { index, instruction in
                                Text("• \(instruction)")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📝 Beschrijving:")
                            .font(.headline)
                        Text(step.description)
                            .font(.body)
                        
                        Text("💡 Tips:")
                            .font(.headline)
                        Text(step.tips)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        if step.duration > 0 {
                            Text("⏱️ Geschatte tijd:")
                                .font(.headline)
                            Text("\(step.duration) minuten")
                                .font(.body)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Stap Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DataEntryView: View {
    let step: BrewStep
    @Binding var temperature: String
    @Binding var notes: String
    @Binding var gravity: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("📊 Data Invoer")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Stap: \(step.name)")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    // Temperature section
                    if step.requiresTemperature {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("🌡️ Temperatuur")
                                .font(.headline)
                            
                            Text("Doel: \(step.targetTemperature)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField("Bijv. 66.5", text: $temperature)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .focused($isInputFocused)
                                Text("°C")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Gravity section (for specific steps)
                    if step.name.contains("fermentatie") || step.name.contains("Spoelen") {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📏 Soortelijk Gewicht (SG)")
                                .font(.headline)
                            
                            Text("Meet met hydrometer of refractometer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField("Bijv. 1.020", text: $gravity)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .focused($isInputFocused)
                                Text("SG")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Notes section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📝 Notities")
                            .font(.headline)
                        
                        Text("Persoonlijke aantekeningen voor deze stap")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .focused($isInputFocused)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Quick note buttons
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 Snelle Notities")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(getQuickNotes(), id: \.self) { note in
                                Button(note) {
                                    if !notes.isEmpty {
                                        notes += "\n• \(note)"
                                    } else {
                                        notes = "• \(note)"
                                    }
                                }
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Data Invoer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Klaar") {
                        isInputFocused = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuleer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Opslaan") {
                        // Save data logic here
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func getQuickNotes() -> [String] {
        switch step.name {
        case "Maischen":
            return ["pH gemeten", "Goed geroerd", "Temperatuur stabiel", "Enzymactiviteit goed"]
        case "Spoelen":
            return ["Helder wort", "Juiste flow", "Goed afgedekt", "Tannines vermeden"]
        case "Koken":
            return ["Goede kok", "Hoppen toegevoegd", "Schuim verwijderd", "Volume gecontroleerd"]
        case "Koelen":
            return ["Snel gekoeld", "Sanitair gehouden", "Juiste temperatuur", "Goed beluchting"]
        case "Primaire fermentatie":
            return ["Actieve gisting", "Airlock borrelend", "Geen infectie", "Temperatuur stabiel"]
        case "Secundaire fermentatie":
            return ["Heldere beer", "Dry hops toegevoegd", "Geen infectie", "Goede klaring"]
        default:
            return ["Goed verlopen", "Probleem opgelost", "Extra tijd nodig", "Perfect uitgevoerd"]
        }
    }
}

struct SimpleABVCalculatorView: View {
    @State private var originalGravity = ""
    @State private var finalGravity = ""
    @State private var calculatedABV = 0.0
    @State private var attenuation = 0.0
    @State private var calories = 0.0
    @State private var alcoholYield = 0.0
    @State private var showResults = false
    @State private var showingInfo = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header in brouwtracker style
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "percent")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("ABV Calculator")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Bereken alcohol percentage en meer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if showResults {
                        Text(String(format: "%.2f%% ABV", calculatedABV))
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    } else {
                        Text("Klaar voor berekening")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                VStack(spacing: 25) {
                
                // Info Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("ℹ️ Wat betekent dit?")
                            .font(.headline)
                        Spacer()
                        Button("Meer Info") {
                            showingInfo = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    Text("**OG** = Original Gravity (soortelijk gewicht vóór fermentatie)")
                        .font(.caption)
                    Text("**FG** = Final Gravity (soortelijk gewicht ná fermentatie)")
                        .font(.caption)
                    Text("Typische waarden: OG 1.040-1.080, FG 1.008-1.020")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("💡 Je kunt invoeren als 1.050 of als 1050")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Input Section
                VStack(spacing: 20) {
                    Text("Gravity Metingen")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("OG:")
                                .font(.headline)
                                .frame(width: 40, alignment: .leading)
                            TextField("1.050 of 1050", text: $originalGravity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                        }
                        
                        HStack {
                            Text("FG:")
                                .font(.headline)
                                .frame(width: 40, alignment: .leading)
                            TextField("1.010 of 1010", text: $finalGravity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                        }
                    }
                    
                    HStack(spacing: 15) {
                        Button("Bereken Alles") {
                            calculateBrewingStats()
                            isInputFocused = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button("Wissen") {
                            clearAll()
                            isInputFocused = false
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                    
                    // Results Section
                    if showResults {
                        VStack(spacing: 20) {
                            Text("Resultaten")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                ResultCard(title: "ABV", value: String(format: "%.2f%%", calculatedABV), color: .green)
                                ResultCard(title: "Attenuation", value: String(format: "%.1f%%", attenuation), color: .blue)
                                ResultCard(title: "Calorieën", value: String(format: "%.0f kcal/L", calories), color: .orange)
                                ResultCard(title: "Alcohol Opbrengst", value: String(format: "%.1f g/L", alcoholYield), color: .purple)
                            }
                            
                            // Interpretation
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Interpretatie:")
                                    .font(.headline)
                                
                                Text(getInterpretation())
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Klaar") {
                    isInputFocused = false
                }
            }
        }
        .sheet(isPresented: $showingInfo) {
            InfoSheetView()
        }
        }
    
    private func clearAll() {
        originalGravity = ""
        finalGravity = ""
        showResults = false
        calculatedABV = 0.0
        attenuation = 0.0
        calories = 0.0
        alcoholYield = 0.0
    }
    
    private func calculateBrewingStats() {
        guard let ogInput = Double(originalGravity),
              let fgInput = Double(finalGravity) else { 
            showResults = false
            return 
        }
        
        // Convert input to proper gravity format
        // If user enters 1050, convert to 1.050
        // If user enters 1.050, keep as is
        let og = ogInput > 100 ? ogInput / 1000 : ogInput
        let fg = fgInput > 100 ? fgInput / 1000 : fgInput
        
        guard og > fg,
              og >= 1.000, fg >= 1.000,
              og <= 1.200, fg <= 1.050 else { 
            showResults = false
            return 
        }
        
        // ABV calculation (eenvoudige, betrouwbare formule)
        calculatedABV = (og - fg) * 131.25
        
        // Attenuation calculation (vergisting efficiëntie)
        attenuation = ((og - fg) / (og - 1.000)) * 100
        
        // Calories per liter (benadering)
        let realExtract = (0.1808 * (og - 1.000) * 1000) + (0.8192 * (fg - 1.000) * 1000)
        calories = ((6.9 * calculatedABV) + (4.0 * realExtract / 1000)) * 10
        
        // Alcohol yield in grams per liter
        alcoholYield = calculatedABV * 7.94
        
        showResults = true
    }
    
    private func getInterpretation() -> String {
        if calculatedABV < 3.0 {
            return "Laag alcohol bier - Geschikt als sessionable bier"
        } else if calculatedABV < 5.0 {
            return "Standaard sterkte - Typisch voor pilsners en lagers"
        } else if calculatedABV < 7.0 {
            return "Medium-hoog alcohol - IPA/Ale niveau"
        } else if calculatedABV < 10.0 {
            return "Sterk bier - Imperial/Double stijlen"
        } else {
            return "Zeer sterk bier - Barleywine/Imperial stout niveau"
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - IBU Calculator

struct IBUCalculatorView: View {
    @State private var hopAdditions: [HopAddition] = [HopAddition()]
    @State private var beerVolume = ""
    @State private var totalIBU = 0.0
    @State private var showResults = false
    @State private var showingInfo = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header in brouwtracker style
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading) {
                        Text("IBU Calculator")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Bereken bitterheid van je bier")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if showResults {
                        Text(String(format: "%.1f IBU", totalIBU))
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                    } else {
                        Text("Klaar voor berekening")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                VStack(spacing: 25) {
                
                // Info Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("ℹ️ Wat is IBU?")
                            .font(.headline)
                        Spacer()
                        Button("Meer Info") {
                            showingInfo = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    Text("**IBU** = International Bitterness Units (bitterheids-eenheden)")
                        .font(.caption)
                    Text("**Alpha Acid** = percentage bitter zuren in hop")
                        .font(.caption)
                    Text("Typische waarden: Lager 10-25 IBU, IPA 40-80 IBU")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("💡 Langere kooktijd = meer bitterheid")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Beer Volume Section
                VStack(spacing: 15) {
                    Text("Bier Volume")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("Volume:")
                            .font(.headline)
                            .frame(width: 80, alignment: .leading)
                        TextField("23 liter", text: $beerVolume)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .focused($isInputFocused)
                        Text("L")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Hop Additions Section
                VStack(spacing: 20) {
                    HStack {
                        Text("Hop Toevoegingen")
                            .font(.headline)
                        Spacer()
                        Button("+ Hop Toevoegen") {
                            hopAdditions.append(HopAddition())
                        }
                        .font(.caption)
                        .buttonStyle(.borderless)
                        .foregroundColor(.blue)
                    }
                    
                    ForEach(hopAdditions.indices, id: \.self) { index in
                        HopAdditionRow(
                            hopAddition: $hopAdditions[index],
                            index: index,
                            onDelete: {
                                if hopAdditions.count > 1 {
                                    hopAdditions.remove(at: index)
                                }
                            }
                        )
                        .focused($isInputFocused)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Calculate Button
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        Button("Bereken IBU") {
                            calculateIBU()
                            isInputFocused = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button("Wissen") {
                            clearAll()
                            isInputFocused = false
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
                .padding()
                    
                // Results Section
                if showResults {
                    VStack(spacing: 20) {
                        Text("Resultaten")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Total IBU Card
                        VStack(spacing: 15) {
                            Text("Totale Bitterheid")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            Text(String(format: "%.1f IBU", totalIBU))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Individual Hop Contributions
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Hop Bijdragen:")
                                .font(.headline)
                            
                            ForEach(hopAdditions.indices, id: \.self) { index in
                                let hop = hopAdditions[index]
                                let ibu = calculateIndividualIBU(hop: hop)
                                
                                HStack {
                                    Text("Hop \(index + 1):")
                                        .font(.caption)
                                    Spacer()
                                    Text(String(format: "%.1f IBU", ibu))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Interpretation
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Bitterheidsprofiel:")
                                .font(.headline)
                            
                            Text(getIBUInterpretation())
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                
                Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Klaar") {
                    isInputFocused = false
                }
            }
        }
        .sheet(isPresented: $showingInfo) {
            IBUInfoSheetView()
        }
    }
    
    private func clearAll() {
        hopAdditions = [HopAddition()]
        beerVolume = ""
        showResults = false
        totalIBU = 0.0
    }
    
    private func calculateIBU() {
        guard let volume = Double(beerVolume),
              volume > 0 else { 
            showResults = false
            return 
        }
        
        totalIBU = 0.0
        
        for hop in hopAdditions {
            totalIBU += calculateIndividualIBU(hop: hop)
        }
        
        showResults = true
    }
    
    private func calculateIndividualIBU(hop: HopAddition) -> Double {
        guard let alphaAcid = Double(hop.alphaAcidString),
              let weight = Double(hop.weight),
              let boilTime = Double(hop.boilTime),
              let volume = Double(beerVolume),
              alphaAcid > 0, weight > 0, volume > 0 else {
            return 0.0
        }
        
        // Utilization factor based on boil time (Rager formula approximation)
        let utilization: Double
        if boilTime >= 60 {
            utilization = 0.300
        } else if boilTime >= 45 {
            utilization = 0.276
        } else if boilTime >= 30 {
            utilization = 0.229
        } else if boilTime >= 20 {
            utilization = 0.188
        } else if boilTime >= 15 {
            utilization = 0.156
        } else if boilTime >= 10 {
            utilization = 0.124
        } else if boilTime >= 5 {
            utilization = 0.084
        } else {
            utilization = 0.050
        }
        
        // IBU = (Alpha Acid % × Weight(g) × Utilization) / (Volume(L) × 10)
        return (alphaAcid * weight * utilization) / (volume * 10)
    }
    
    private func getIBUInterpretation() -> String {
        if totalIBU < 15 {
            return "Zeer mild - Typisch voor light lagers en wheat beers"
        } else if totalIBU < 25 {
            return "Mild bitter - Geschikt voor pilsners en blonde ales"
        } else if totalIBU < 40 {
            return "Matig bitter - Amber ales en pale ales niveau"
        } else if totalIBU < 60 {
            return "Bitter - IPA en hoppy ales"
        } else if totalIBU < 80 {
            return "Zeer bitter - Double IPA niveau"
        } else {
            return "Extreem bitter - Imperial IPA's en hop bombs"
        }
    }
}

// HopAddition struct moved to AIRecipeGenerator.swift to avoid conflicts

struct HopAdditionRow: View {
    @Binding var hopAddition: HopAddition
    let index: Int
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Hop \(index + 1)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                if index > 0 {
                    Button("Verwijder") {
                        onDelete()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("Alpha Acid:")
                        .frame(width: 80, alignment: .leading)
                        .font(.caption)
                    TextField("5.5", text: .constant(hopAddition.alphaAcidString))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .disabled(true)
                    Text("%")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                HStack {
                    Text("Gewicht:")
                        .frame(width: 80, alignment: .leading)
                        .font(.caption)
                    TextField("30", text: .constant(hopAddition.weight))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .disabled(true)
                    Text("g")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                HStack {
                    Text("Kooktijd:")
                        .frame(width: 80, alignment: .leading)
                        .font(.caption)
                    TextField("60", text: .constant(hopAddition.boilTime))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .disabled(true)
                    Text("min")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct IBUInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🍺 IBU Uitleg")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("**IBU (International Bitterness Units)** meet de bitterheid van bier. Hoe hoger het getal, hoe bitterder het bier.")
                        
                        Text("**Alpha Acid** is het percentage bitter zuren in hop. Elke hop soort heeft een ander percentage (meestal 3-15%).")
                        
                        Text("**Kooktijd** bepaalt hoeveel bitterheid wordt geëxtraheerd. Langere kooktijd = meer bitterheid.")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🎯 Typische IBU Waarden")
                            .font(.headline)
                        
                        Text("• **Light Lager**: 5-15 IBU")
                        Text("• **Pilsner**: 15-35 IBU")  
                        Text("• **Pale Ale**: 25-45 IBU")
                        Text("• **IPA**: 40-80 IBU")
                        Text("• **Double IPA**: 60-120 IBU")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🌿 Populaire Hop Alpha Acid %")
                            .font(.headline)
                        
                        Text("• **Saaz**: 3-5% (Tsjechische noble hop)")
                        Text("• **Cascade**: 5-7% (Amerikaanse aroma hop)")
                        Text("• **Centennial**: 9-12% (Amerikaanse bitter hop)")
                        Text("• **Citra**: 11-15% (Amerikaanse aroma hop)")
                        Text("• **Columbus**: 14-18% (Amerikaanse bitter hop)")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("⏰ Hop Toevoeging Timing")
                            .font(.headline)
                        
                        Text("• **60+ minuten**: Maximale bitterheid, geen aroma")
                        Text("• **15-30 minuten**: Matige bitterheid + wat aroma")
                        Text("• **0-10 minuten**: Minimale bitterheid, veel aroma")
                        Text("• **Dry hopping**: Geen bitterheid, alleen aroma")
                    }
                    
                    Text("💡 **Tip**: Gebruik deze calculator om je hop schema te plannen. Bittere hoppen vroeg toevoegen, aroma hoppen laat!")
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("IBU Calculator Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - SRM Calculator

struct SRMCalculatorView: View {
    @State private var maltAdditions: [MaltAddition] = [MaltAddition()]
    @State private var beerVolume = ""
    @State private var totalSRM = 0.0
    @State private var showResults = false
    @State private var showingInfo = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header in brouwtracker style
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "paintpalette.fill")
                        .foregroundColor(.maltGold)
                    VStack(alignment: .leading) {
                        Text("SRM Calculator")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Bereken bierkleur (SRM)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if showResults {
                        HStack(spacing: 8) {
                            Text(String(format: "%.1f SRM", totalSRM))
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(getSRMColor(totalSRM).opacity(0.3))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                            
                            Rectangle()
                                .fill(getSRMColor(totalSRM))
                                .frame(width: 20, height: 20)
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.primary, lineWidth: 1)
                                )
                        }
                    } else {
                        Text("Klaar voor berekening")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                VStack(spacing: 25) {
                
                // Info Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("ℹ️ Wat is SRM?")
                            .font(.headline)
                        Spacer()
                        Button("Meer Info") {
                            showingInfo = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    Text("**SRM** = Standard Reference Method (bierkleur standaard)")
                        .font(.caption)
                    Text("**Lovibond** = percentage kleur bijdrage van mout")
                        .font(.caption)
                    Text("Typische waarden: Pilsner 2-3 SRM, Stout 30+ SRM")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("💡 Donkerdere mouten hebben hogere Lovibond waarden")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Beer Volume Section
                VStack(spacing: 15) {
                    Text("Bier Volume")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("Volume:")
                            .font(.headline)
                            .frame(width: 80, alignment: .leading)
                        TextField("23 liter", text: $beerVolume)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .focused($isInputFocused)
                        Text("L")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Malt Additions Section
                VStack(spacing: 20) {
                    HStack {
                        Text("Mout Toevoegingen")
                            .font(.headline)
                        Spacer()
                        Button("+ Mout Toevoegen") {
                            maltAdditions.append(MaltAddition())
                        }
                        .font(.caption)
                        .buttonStyle(.borderless)
                        .foregroundColor(.blue)
                    }
                    
                    ForEach(maltAdditions.indices, id: \.self) { index in
                        MaltAdditionRow(
                            maltAddition: $maltAdditions[index],
                            index: index,
                            onDelete: {
                                if maltAdditions.count > 1 {
                                    maltAdditions.remove(at: index)
                                }
                            }
                        )
                        .focused($isInputFocused)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Calculate Button
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        Button("Bereken SRM") {
                            calculateSRM()
                            isInputFocused = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button("Wissen") {
                            clearAll()
                            isInputFocused = false
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
                .padding()
                    
                // Results Section
                if showResults {
                    VStack(spacing: 20) {
                        Text("Resultaten")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Total SRM Card with Color Preview
                        VStack(spacing: 15) {
                            Text("Bierkleur")
                                .font(.headline)
                                .foregroundColor(.brown)
                            
                            HStack(spacing: 15) {
                                VStack {
                                    Text(String(format: "%.1f SRM", totalSRM))
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.brown)
                                    
                                    Text(getSRMDescription(totalSRM))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 8) {
                                    Text("Kleur Preview")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Circle()
                                        .fill(getSRMColor(totalSRM))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(getSRMColor(totalSRM).opacity(0.1))
                        .cornerRadius(12)
                        
                        // Individual Malt Contributions
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Mout Bijdragen:")
                                .font(.headline)
                            
                            ForEach(maltAdditions.indices, id: \.self) { index in
                                let malt = maltAdditions[index]
                                let contribution = calculateIndividualSRM(malt: malt)
                                
                                if !malt.name.isEmpty && !malt.weight.isEmpty && !malt.lovibond.isEmpty {
                                    HStack {
                                        Text("\(malt.name):")
                                            .font(.caption)
                                        Spacer()
                                        Text(String(format: "%.1f SRM", contribution))
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.brown)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Style Recommendations
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Bierstijl Aanbevelingen:")
                                .font(.headline)
                            
                            Text(getStyleRecommendations())
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                
                Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Klaar") {
                    isInputFocused = false
                }
            }
        }
        .sheet(isPresented: $showingInfo) {
            SRMInfoSheetView()
        }
    }
    
    private func clearAll() {
        maltAdditions = [MaltAddition()]
        beerVolume = ""
        showResults = false
        totalSRM = 0.0
    }
    
    private func calculateSRM() {
        guard let volume = Double(beerVolume),
              volume > 0 else { 
            showResults = false
            return 
        }
        
        totalSRM = 0.0
        
        for malt in maltAdditions {
            totalSRM += calculateIndividualSRM(malt: malt)
        }
        
        showResults = true
    }
    
    private func calculateIndividualSRM(malt: MaltAddition) -> Double {
        guard let lovibond = Double(malt.lovibond),
              let weight = Double(malt.weight),
              let volume = Double(beerVolume),
              lovibond > 0, weight > 0, volume > 0 else {
            return 0.0
        }
        
        // Morey's equation: SRM = 1.4922 * ((weight_lb * lovibond) / volume_gal)^0.6859
        // Convert kg to lb and L to gal
        let weightLb = weight * 2.20462
        let volumeGal = volume * 0.264172
        
        let srm = 1.4922 * pow((weightLb * lovibond) / volumeGal, 0.6859)
        
        return srm
    }
    
    private func getSRMColor(_ srm: Double) -> Color {
        // SRM to RGB conversion (approximation)
        switch srm {
        case 0..<2:
            return Color(red: 1.0, green: 0.98, blue: 0.85) // Very pale
        case 2..<4:
            return Color(red: 1.0, green: 0.94, blue: 0.70) // Pale straw
        case 4..<6:
            return Color(red: 1.0, green: 0.90, blue: 0.55) // Straw
        case 6..<9:
            return Color(red: 1.0, green: 0.83, blue: 0.35) // Pale gold
        case 9..<12:
            return Color(red: 1.0, green: 0.75, blue: 0.20) // Gold
        case 12..<16:
            return Color(red: 0.95, green: 0.65, blue: 0.10) // Amber
        case 16..<20:
            return Color(red: 0.90, green: 0.50, blue: 0.05) // Deep amber
        case 20..<24:
            return Color(red: 0.75, green: 0.35, blue: 0.05) // Copper
        case 24..<30:
            return Color(red: 0.60, green: 0.25, blue: 0.05) // Light brown
        case 30..<35:
            return Color(red: 0.45, green: 0.18, blue: 0.05) // Brown
        case 35..<40:
            return Color(red: 0.35, green: 0.12, blue: 0.05) // Dark brown
        default:
            return Color(red: 0.20, green: 0.08, blue: 0.05) // Very dark brown/black
        }
    }
    
    private func getSRMDescription(_ srm: Double) -> String {
        switch srm {
        case 0..<2:
            return "Zeer bleek"
        case 2..<4:
            return "Bleek stroogeel"
        case 4..<6:
            return "Stroogeel"
        case 6..<9:
            return "Bleek goud"
        case 9..<12:
            return "Goud"
        case 12..<16:
            return "Amber"
        case 16..<20:
            return "Diep amber"
        case 20..<24:
            return "Koper"
        case 24..<30:
            return "Licht bruin"
        case 30..<35:
            return "Bruin"
        case 35..<40:
            return "Donkerbruin"
        default:
            return "Zeer donker/zwart"
        }
    }
    
    private func getStyleRecommendations() -> String {
        switch totalSRM {
        case 0..<4:
            return "Perfect voor: Light Lagers, Wheat Beers, Belgian Witbier\nKarakter: Zeer licht en helder, verfrissend"
        case 4..<8:
            return "Perfect voor: Pilsners, Blonde Ales, Kölsch\nKarakter: Licht gouden kleur, clean en crisp"
        case 8..<12:
            return "Perfect voor: Pale Ales, IPAs, Weizen\nKarakter: Gouden kleur, balanced mout karakter"
        case 12..<18:
            return "Perfect voor: Amber Ales, Oktoberfest, ESB\nKarakter: Amber/koper kleur, rijke mout smaak"
        case 18..<25:
            return "Perfect voor: Brown Ales, Porters, Märzen\nKarakter: Diep amber/bruin, volle mout complexiteit"
        case 25..<35:
            return "Perfect voor: Porters, Brown Ales, Doppelbock\nKarakter: Bruin/donkerbruin, rijk en zwaar"
        default:
            return "Perfect voor: Stouts, Imperial Porters, Russian Imperial Stout\nKarakter: Zeer donker/zwart, intense mout smaken"
        }
    }
}

struct MaltAddition: Identifiable {
    let id = UUID()
    var name: String = ""
    var lovibond: String = ""
    var weight: String = ""
}

struct MaltAdditionRow: View {
    @Binding var maltAddition: MaltAddition
    let index: Int
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Mout \(index + 1)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                if index > 0 {
                    Button("Verwijder") {
                        onDelete()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("Naam:")
                        .frame(width: 80, alignment: .leading)
                        .font(.caption)
                    
                    Menu {
                        Button("Pilsner Mout (2°L)") {
                            maltAddition.name = "Pilsner Mout"
                            maltAddition.lovibond = "2"
                        }
                        Button("Pale Ale Mout (3°L)") {
                            maltAddition.name = "Pale Ale Mout"
                            maltAddition.lovibond = "3"
                        }
                        Button("Vienna Mout (4°L)") {
                            maltAddition.name = "Vienna Mout"
                            maltAddition.lovibond = "4"
                        }
                        Button("Munich Mout (9°L)") {
                            maltAddition.name = "Munich Mout"
                            maltAddition.lovibond = "9"
                        }
                        Button("Crystal 40L (40°L)") {
                            maltAddition.name = "Crystal 40L"
                            maltAddition.lovibond = "40"
                        }
                        Button("Crystal 60L (60°L)") {
                            maltAddition.name = "Crystal 60L"
                            maltAddition.lovibond = "60"
                        }
                        Button("Crystal 120L (120°L)") {
                            maltAddition.name = "Crystal 120L"
                            maltAddition.lovibond = "120"
                        }
                        Button("Chocolate Mout (350°L)") {
                            maltAddition.name = "Chocolate Mout"
                            maltAddition.lovibond = "350"
                        }
                        Button("Black Patent (500°L)") {
                            maltAddition.name = "Black Patent"
                            maltAddition.lovibond = "500"
                        }
                        Button("Roasted Barley (300°L)") {
                            maltAddition.name = "Roasted Barley"
                            maltAddition.lovibond = "300"
                        }
                    } label: {
                        HStack {
                            TextField("Kies mout type", text: $maltAddition.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Image(systemName: "chevron.down")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                }
                
                HStack {
                    Text("Lovibond:")
                        .frame(width: 80, alignment: .leading)
                        .font(.caption)
                    TextField("2.0", text: $maltAddition.lovibond)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    Text("°L")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                HStack {
                    Text("Gewicht:")
                        .frame(width: 80, alignment: .leading)
                        .font(.caption)
                    TextField("5.0", text: $maltAddition.weight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    Text("kg")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct SRMInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🎨 SRM Uitleg")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("**SRM (Standard Reference Method)** meet de kleur van bier op een schaal van 1 (zeer licht) tot 40+ (zwart).")
                        
                        Text("**Lovibond (°L)** is de kleurwaarde van individuele mout types. Hoe hoger het getal, hoe donkerder de mout.")
                        
                        Text("**Morey's formule** wordt gebruikt voor nauwkeurige SRM berekening gebaseerd op mout samenstelling.")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🌈 SRM Kleurschaal")
                            .font(.headline)
                        
                        Text("• **1-3 SRM**: Zeer bleek (Light Lagers)")
                        Text("• **3-6 SRM**: Stroogeel (Pilsners)")  
                        Text("• **6-9 SRM**: Goud (Pale Ales)")
                        Text("• **9-16 SRM**: Amber (IPAs, Amber Ales)")
                        Text("• **16-25 SRM**: Bruin (Porters)")
                        Text("• **25+ SRM**: Donkerbruin/Zwart (Stouts)")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🌾 Populaire Mout Types")
                            .font(.headline)
                        
                        Text("• **Pilsner Mout**: 1.5-2°L (basis voor lichte bieren)")
                        Text("• **Pale Ale Mout**: 2.5-3.5°L (basis voor ales)")
                        Text("• **Vienna Mout**: 3-5°L (voegt goud kleur toe)")
                        Text("• **Munich Mout**: 6-10°L (malty karakter)")
                        Text("• **Crystal 60L**: 55-65°L (karamel smaken)")
                        Text("• **Chocolate Mout**: 300-400°L (chocolate smaken)")
                        Text("• **Roasted Barley**: 250-300°L (coffee smaken)")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📊 Berekenings Tips")
                            .font(.headline)
                        
                        Text("• **Basis mouten** (80-90% van recept) bepalen hoofdkleur")
                        Text("• **Specialty mouten** voegen kleur en smaak toe")
                        Text("• **Kleine hoeveelheden** donkere mout hebben grote impact")
                        Text("• **Experimenteer** met verschillende combinaties")
                    }
                    
                    Text("💡 **Tip**: Begin met een basis mout en voeg kleine hoeveelheden specialty mouten toe om gewenste kleur te bereiken!")
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("SRM Calculator Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Carbonation Calculator

struct CarbonationCalculatorView: View {
    @State private var beerVolume = ""
    @State private var beerTemperature = ""
    @State private var targetCO2 = ""
    @State private var selectedPrimingSugar = PrimingSugar.dextrose
    @State private var selectedBeerStyle = BeerStyle.lager
    @State private var calculatedSugar = 0.0
    @State private var residualCO2 = 0.0
    @State private var showResults = false
    @State private var showingInfo = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "bubbles.and.sparkles")
                        .foregroundColor(.brewTheme)
                    VStack(alignment: .leading) {
                        Text("CO₂ Calculator")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Bereken priming sugar voor carbonatie")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if showResults {
                        VStack(alignment: .trailing) {
                            Text(String(format: "%.1f g", calculatedSugar))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.brewTheme)
                            Text(selectedPrimingSugar.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Klaar voor berekening")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondaryCard)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                VStack(spacing: 25) {
                
                // Info Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("ℹ️ CO₂ Carbonatie Uitleg")
                            .font(.headline)
                        Spacer()
                        Button("Meer Info") {
                            showingInfo = true
                        }
                        .font(.caption)
                        .foregroundColor(.brewTheme)
                    }
                    
                    Text("**Carbonatie** = CO₂ concentratie in volumes (vol CO₂)")
                        .font(.caption)
                    Text("**Priming sugar** vergist en produceert CO₂ voor natuurlijke carbonatie")
                        .font(.caption)
                    Text("Temperatuur bepaalt hoeveel CO₂ al opgelost is in het bier")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(10)
                
                // Beer Style Quick Select
                VStack(spacing: 15) {
                    Text("Bierstijl (Aanbevolen CO₂)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(BeerStyle.allCases, id: \.self) { style in
                            Button(action: {
                                selectedBeerStyle = style
                                targetCO2 = String(format: "%.1f", style.recommendedCO2)
                            }) {
                                VStack(spacing: 4) {
                                    Text(style.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("\(String(format: "%.1f", style.recommendedCO2)) vol")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity)
                                .background(selectedBeerStyle == style ? Color.brewTheme.opacity(0.2) : Color.secondaryCard)
                                .foregroundColor(selectedBeerStyle == style ? .brewTheme : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Input Section
                VStack(spacing: 20) {
                    Text("Bier Parameters")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("Volume:")
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)
                            TextField("23 liter", text: $beerVolume)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            Text("L")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Temperatuur:")
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)
                            TextField("20°C", text: $beerTemperature)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            Text("°C")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Doel CO₂:")
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)
                            TextField("2.5 vol", text: $targetCO2)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            Text("vol")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Priming Sugar Selection
                VStack(spacing: 15) {
                    Text("Priming Sugar Type")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(PrimingSugar.allCases, id: \.self) { sugar in
                            Button(action: {
                                selectedPrimingSugar = sugar
                            }) {
                                VStack(spacing: 4) {
                                    Text(sugar.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("×\(String(format: "%.2f", sugar.factor))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                                .frame(maxWidth: .infinity)
                                .background(selectedPrimingSugar == sugar ? Color.maltGold.opacity(0.2) : Color.secondaryCard)
                                .foregroundColor(selectedPrimingSugar == sugar ? .maltGold : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Calculate Button
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        Button("Bereken CO₂") {
                            calculateCarbonation()
                            isInputFocused = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button("Wissen") {
                            clearAll()
                            isInputFocused = false
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
                .padding()
                    
                // Results Section
                if showResults {
                    VStack(spacing: 20) {
                        Text("Resultaten")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result Card
                        VStack(spacing: 15) {
                            Text("Priming Sugar Hoeveelheid")
                                .font(.headline)
                                .foregroundColor(.brewTheme)
                            
                            VStack(spacing: 8) {
                                Text(String(format: "%.1f gram", calculatedSugar))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.brewTheme)
                                
                                Text(selectedPrimingSugar.rawValue)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                
                                Text("Voor \(beerVolume) liter bier")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        
                        // Additional Info
                        VStack(spacing: 15) {
                            Text("Berekening Details")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Residual CO₂ bij \(beerTemperature)°C:")
                                    Spacer()
                                    Text(String(format: "%.2f vol", residualCO2))
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Benodigde CO₂ uit priming:")
                                    Spacer()
                                    Text(String(format: "%.2f vol", Double(targetCO2) ?? 0.0 - residualCO2))
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Sugar factor (\(selectedPrimingSugar.rawValue)):")
                                    Spacer()
                                    Text(String(format: "×%.2f", selectedPrimingSugar.factor))
                                        .fontWeight(.medium)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Per liter:")
                                    Spacer()
                                    Text(String(format: "%.1f g/L", calculatedSugar / (Double(beerVolume) ?? 1.0)))
                                        .fontWeight(.bold)
                                        .foregroundColor(.brewTheme)
                                }
                            }
                            .font(.caption)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        
                        // Style Comparison
                        VStack(spacing: 10) {
                            Text("Bierstijl Vergelijking")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let currentCO2 = Double(targetCO2) ?? 0.0
                            ForEach(BeerStyle.allCases.prefix(4), id: \.self) { style in
                                HStack {
                                    Text(style.name)
                                        .font(.caption)
                                    Spacer()
                                    Text("\(String(format: "%.1f", style.recommendedCO2)) vol")
                                        .font(.caption)
                                        .fontWeight(abs(style.recommendedCO2 - currentCO2) < 0.2 ? .bold : .regular)
                                        .foregroundColor(abs(style.recommendedCO2 - currentCO2) < 0.2 ? .brewTheme : .secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                    }
                }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingInfo) {
            CarbonationInfoSheetView()
        }
    }
    
    private func calculateCarbonation() {
        guard let volume = Double(beerVolume),
              let temp = Double(beerTemperature),
              let targetCO2Vol = Double(targetCO2),
              volume > 0 else {
            return
        }
        
        // Calculate residual CO₂ based on temperature
        // Formula: CO₂ (vol) = 3.0378 - (0.050062 × T) + (0.00026555 × T²)
        residualCO2 = max(0, 3.0378 - (0.050062 * temp) + (0.00026555 * temp * temp))
        
        // Calculate needed CO₂ from priming
        let neededCO2 = max(0, targetCO2Vol - residualCO2)
        
        // Base calculation: 4g dextrose/L produces ~1 vol CO₂
        let baseSugarPerLiter = neededCO2 * 4.0
        
        // Adjust for sugar type
        let adjustedSugarPerLiter = baseSugarPerLiter * selectedPrimingSugar.factor
        
        // Total sugar needed
        calculatedSugar = adjustedSugarPerLiter * volume
        
        showResults = true
    }
    
    private func clearAll() {
        beerVolume = ""
        beerTemperature = ""
        targetCO2 = ""
        calculatedSugar = 0.0
        residualCO2 = 0.0
        showResults = false
        selectedPrimingSugar = .dextrose
        selectedBeerStyle = .lager
    }
}

enum PrimingSugar: String, CaseIterable {
    case dextrose = "Dextrose (Corn Sugar)"
    case sucrose = "Sucrose (Tafelsuiker)"
    case dme = "DME (Dry Malt Extract)"
    case honey = "Honing"
    case brownSugar = "Bruine Suiker"
    
    var factor: Double {
        switch self {
        case .dextrose: return 1.0      // Baseline
        case .sucrose: return 0.95      // Slightly less fermentable  
        case .dme: return 1.33          // Lower fermentability
        case .honey: return 1.25        // Variable, conservative estimate
        case .brownSugar: return 0.97   // Similar to sucrose
        }
    }
}

enum BeerStyle: String, CaseIterable {
    case lager = "Lager"
    case ale = "Ale"
    case wheat = "Weizen"
    case belgian = "Belgian"
    case stout = "Stout"
    case ipa = "IPA"
    
    var name: String { rawValue }
    
    var recommendedCO2: Double {
        switch self {
        case .lager: return 2.5         // Crisp and clean
        case .ale: return 2.3           // Moderate carbonation
        case .wheat: return 2.8         // Higher for style
        case .belgian: return 3.0       // Traditional high carbonation
        case .stout: return 2.1         // Lower for mouthfeel
        case .ipa: return 2.4           // Moderate to highlight hops
        }
    }
}

struct CarbonationInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🫧 CO₂ Carbonatie Uitleg")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("**Carbonatie** is de hoeveelheid CO₂ opgelost in je bier, gemeten in 'volumes' CO₂.")
                        
                        Text("**1 volume CO₂** betekent dat 1 liter bier 1 liter CO₂ gas bevat bij 0°C en 1 atm druk.")
                        
                        Text("**Priming sugar** vergist in de fles en produceert CO₂ voor natuurlijke carbonatie.")
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🌡️ Temperatuur Effect")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Warmer bier bevat minder opgeloste CO₂ dan koud bier.")
                        Text("• **5°C**: ~0.9 vol residual CO₂")
                        Text("• **15°C**: ~0.6 vol residual CO₂")
                        Text("• **20°C**: ~0.5 vol residual CO₂")
                        Text("• **25°C**: ~0.4 vol residual CO₂")
                        
                        Text("De calculator houdt hier automatisch rekening mee.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🍯 Priming Sugar Types")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("• **Dextrose**: Meest gebruikt, 100% vergistbaar")
                        Text("• **Sucrose (tafelsuiker)**: Vergelijkbaar met dextrose")
                        Text("• **DME**: Minder vergistbaar, zachter carbonatie")
                        Text("• **Honing**: Variabel, voegt smaak toe")
                        Text("• **Bruine suiker**: Zoals sucrose + smaak")
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🍺 Bierstijl Richtlijnen")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("• **Lagers**: 2.4-2.6 vol (helder en fris)")
                        Text("• **Ales**: 2.2-2.5 vol (moderate carbonatie)")
                        Text("• **Weizen**: 2.7-3.0 vol (traditioneel hoog)")
                        Text("• **Belgian**: 2.8-3.2 vol (levendig en bruisend)")
                        Text("• **Stouts**: 2.0-2.3 vol (romig mondgevoel)")
                        Text("• **IPAs**: 2.3-2.6 vol (hop karakter behouden)")
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("⚠️ Belangrijke Tips")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("• Meet temperatuur van het bier dat je gaat bottelen")
                        Text("• Zorg voor complete primaire fermentatie")
                        Text("• Verdeel priming sugar gelijkmatig")
                        Text("• Wacht 2-4 weken voor volledige carbonatie")
                        Text("• Bewaar flessen bij stabiele temperatuur")
                    }
                }
                .padding()
            }
            .navigationTitle("CO₂ Carbonatie Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Water Calculator

struct WaterCalculatorView: View {
    @State private var baseWaterProfile = WaterProfile()
    @State private var targetWaterProfile = WaterProfile.pilsner
    @State private var batchSize = ""
    @State private var mashGrainWeight = ""
    @State private var waterAdditions: [WaterAddition] = []
    @State private var showResults = false
    @State private var showingInfo = false
    @State private var calculatedAdditions: [SaltAddition] = []
    @State private var resultingProfile = WaterProfile()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "drop.triangle")
                        .foregroundColor(.brewTheme)
                    VStack(alignment: .leading) {
                        Text("Water Calculator")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Optimaliseer water profiel voor je bierstijl")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if showResults {
                        VStack(alignment: .trailing) {
                            Text("pH: \(String(format: "%.1f", resultingProfile.estimatedPH))")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.brewTheme)
                            Text("Geoptimaliseerd")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Klaar voor berekening")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondaryCard)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                VStack(spacing: 25) {
                
                // Info Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("💧 Water Chemistry Uitleg")
                            .font(.headline)
                        Spacer()
                        Button("Meer Info") {
                            showingInfo = true
                        }
                        .font(.caption)
                        .foregroundColor(.brewTheme)
                    }
                    
                    Text("**Water profiel** bepaalt de smaak van je bier - van hoppy tot malty")
                        .font(.caption)
                    Text("**Calcium** (150-300 ppm) zorgt voor enzyme activiteit en helderheid")
                        .font(.caption)
                    Text("**Sulfaat vs Chloride** ratio bepaalt hop vs mout balans")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(10)
                
                // Target Water Profile Selection
                VStack(spacing: 15) {
                    Text("Doel Water Profiel")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(WaterProfile.knownProfiles, id: \.name) { profile in
                            Button(action: {
                                targetWaterProfile = profile
                            }) {
                                VStack(spacing: 4) {
                                    Text(profile.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(profile.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(targetWaterProfile.name == profile.name ? Color.brewTheme.opacity(0.2) : Color.secondaryCard)
                                .foregroundColor(targetWaterProfile.name == profile.name ? .brewTheme : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Source Water Profile
                VStack(spacing: 15) {
                    Text("Bron Water Profiel (ppm)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Ca²⁺:")
                                .font(.subheadline)
                                .frame(width: 60, alignment: .leading)
                            TextField("20", value: $baseWaterProfile.calcium, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            
                            Text("Mg²⁺:")
                                .font(.subheadline)
                                .frame(width: 60, alignment: .leading)
                            TextField("5", value: $baseWaterProfile.magnesium, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                        }
                        
                        HStack {
                            Text("SO₄²⁻:")
                                .font(.subheadline)
                                .frame(width: 60, alignment: .leading)
                            TextField("15", value: $baseWaterProfile.sulfate, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            
                            Text("Cl⁻:")
                                .font(.subheadline)
                                .frame(width: 60, alignment: .leading)
                            TextField("10", value: $baseWaterProfile.chloride, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                        }
                        
                        HStack {
                            Text("HCO₃⁻:")
                                .font(.subheadline)
                                .frame(width: 60, alignment: .leading)
                            TextField("50", value: $baseWaterProfile.bicarbonate, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            
                            Text("Na⁺:")
                                .font(.subheadline)
                                .frame(width: 60, alignment: .leading)
                            TextField("8", value: $baseWaterProfile.sodium, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                        }
                    }
                    
                    // Quick water profile buttons
                    HStack {
                        Button("Amsterdam Water") {
                            baseWaterProfile = WaterProfile.amsterdam
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondaryCard)
                        .cornerRadius(6)
                        
                        Button("RO Water") {
                            baseWaterProfile = WaterProfile.ro
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondaryCard)
                        .cornerRadius(6)
                        
                        Button("Distilled") {
                            baseWaterProfile = WaterProfile.distilled
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondaryCard)
                        .cornerRadius(6)
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Batch Parameters
                VStack(spacing: 15) {
                    Text("Batch Parameters")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Batch Volume:")
                                .font(.subheadline)
                                .frame(width: 120, alignment: .leading)
                            TextField("23 liter", text: $batchSize)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            Text("L")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Grain Weight:")
                                .font(.subheadline)
                                .frame(width: 120, alignment: .leading)
                            TextField("5 kg", text: $mashGrainWeight)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            Text("kg")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Calculate Button
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        Button("Bereken Water Treatment") {
                            calculateWaterTreatment()
                            isInputFocused = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button("Reset") {
                            clearAll()
                            isInputFocused = false
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
                .padding()
                    
                // Results Section
                if showResults {
                    VStack(spacing: 20) {
                        Text("Water Treatment Plan")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Salt Additions
                        if !calculatedAdditions.isEmpty {
                            VStack(spacing: 15) {
                                Text("Zout Toevoegingen")
                                    .font(.headline)
                                    .foregroundColor(.brewTheme)
                                
                                ForEach(calculatedAdditions, id: \.name) { addition in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(addition.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(addition.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text(String(format: "%.1f g", addition.amount))
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.brewTheme)
                                            Text("per \(batchSize)L")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                        }
                        
                        // Before vs After Comparison
                        VStack(spacing: 15) {
                            Text("Voor vs Na Behandeling")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Ion")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .frame(width: 50, alignment: .leading)
                                    Text("Voor")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .frame(width: 50, alignment: .center)
                                    Text("Doel")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .frame(width: 50, alignment: .center)
                                    Text("Na")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .frame(width: 50, alignment: .center)
                                }
                                .foregroundColor(.secondary)
                                
                                Divider()
                                
                                WaterComparisonRow(ion: "Ca²⁺", before: baseWaterProfile.calcium, target: targetWaterProfile.calcium, after: resultingProfile.calcium)
                                WaterComparisonRow(ion: "Mg²⁺", before: baseWaterProfile.magnesium, target: targetWaterProfile.magnesium, after: resultingProfile.magnesium)
                                WaterComparisonRow(ion: "SO₄²⁻", before: baseWaterProfile.sulfate, target: targetWaterProfile.sulfate, after: resultingProfile.sulfate)
                                WaterComparisonRow(ion: "Cl⁻", before: baseWaterProfile.chloride, target: targetWaterProfile.chloride, after: resultingProfile.chloride)
                                WaterComparisonRow(ion: "HCO₃⁻", before: baseWaterProfile.bicarbonate, target: targetWaterProfile.bicarbonate, after: resultingProfile.bicarbonate)
                                
                                Divider()
                                
                                HStack {
                                    Text("SO₄:Cl")
                                        .font(.caption)
                                        .frame(width: 50, alignment: .leading)
                                    Text(String(format: "%.1f", baseWaterProfile.sulfateToChlorideRatio))
                                        .font(.caption)
                                        .frame(width: 50, alignment: .center)
                                    Text(String(format: "%.1f", targetWaterProfile.sulfateToChlorideRatio))
                                        .font(.caption)
                                        .frame(width: 50, alignment: .center)
                                    Text(String(format: "%.1f", resultingProfile.sulfateToChlorideRatio))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.brewTheme)
                                        .frame(width: 50, alignment: .center)
                                }
                                
                                HStack {
                                    Text("Est. pH")
                                        .font(.caption)
                                        .frame(width: 50, alignment: .leading)
                                    Text(String(format: "%.1f", baseWaterProfile.estimatedPH))
                                        .font(.caption)
                                        .frame(width: 50, alignment: .center)
                                    Text(String(format: "%.1f", targetWaterProfile.estimatedPH))
                                        .font(.caption)
                                        .frame(width: 50, alignment: .center)
                                    Text(String(format: "%.1f", resultingProfile.estimatedPH))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.brewTheme)
                                        .frame(width: 50, alignment: .center)
                                }
                            }
                            .font(.caption)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        
                        // Brewing Notes
                        VStack(spacing: 10) {
                            Text("Brouw Aanbevelingen")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                let ratio = resultingProfile.sulfateToChlorideRatio
                                if ratio > 2.0 {
                                    Text("🍺 **Hoppy Profile**: SO₄:Cl > 2:1 - perfect voor IPA's en hoppy ales")
                                } else if ratio > 1.0 {
                                    Text("⚖️ **Balanced Profile**: SO₄:Cl ~1.5:1 - geschikt voor de meeste bierstijlen")
                                } else {
                                    Text("🍞 **Malty Profile**: Cl > SO₄ - ideaal voor malty ales en stouts")
                                }
                                
                                if resultingProfile.calcium < 150 {
                                    Text("⚠️ **Laag Calcium**: Voeg meer calcium toe voor enzyme activiteit")
                                        .foregroundColor(.orange)
                                } else if resultingProfile.calcium > 300 {
                                    Text("⚠️ **Hoog Calcium**: Mogelijk te hoog voor sommige stijlen")
                                        .foregroundColor(.orange)
                                }
                                
                                Text("💡 **Tip**: Voeg zouten toe aan mash water voor beste resultaat")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                    }
                }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingInfo) {
            WaterChemistryInfoSheetView()
        }
    }
    
    private func calculateWaterTreatment() {
        guard let batchVolume = Double(batchSize),
              let grainWeight = Double(mashGrainWeight),
              batchVolume > 0 else {
            return
        }
        
        // Calculate required salt additions to reach target profile
        calculatedAdditions = []
        resultingProfile = baseWaterProfile
        
        // Calcium Sulfate (Gypsum) - CaSO4·2H2O
        let calciumNeeded = max(0, targetWaterProfile.calcium - baseWaterProfile.calcium)
        let sulfateNeeded = max(0, targetWaterProfile.sulfate - baseWaterProfile.sulfate)
        
        if calciumNeeded > 0 || sulfateNeeded > 0 {
            // Gypsum adds 232 ppm Ca and 558 ppm SO4 per gram per liter
            let gypsumForCa = calciumNeeded / 232.0
            let gypsumForSO4 = sulfateNeeded / 558.0
            let gypsumAmount = max(gypsumForCa, gypsumForSO4) * batchVolume
            
            if gypsumAmount > 0.1 {
                calculatedAdditions.append(SaltAddition(
                    name: "Gypsum (CaSO₄·2H₂O)",
                    description: "Verhoogt calcium en sulfaat",
                    amount: gypsumAmount
                ))
                
                resultingProfile.calcium += gypsumAmount / batchVolume * 232.0
                resultingProfile.sulfate += gypsumAmount / batchVolume * 558.0
            }
        }
        
        // Calcium Chloride - CaCl2·2H2O  
        let chlorideNeeded = max(0, targetWaterProfile.chloride - baseWaterProfile.chloride)
        let remainingCalciumNeeded = max(0, targetWaterProfile.calcium - resultingProfile.calcium)
        
        if chlorideNeeded > 0 || remainingCalciumNeeded > 0 {
            // Calcium Chloride adds 272 ppm Ca and 482 ppm Cl per gram per liter
            let calciumChlorideForCa = remainingCalciumNeeded / 272.0
            let calciumChlorideForCl = chlorideNeeded / 482.0
            let calciumChlorideAmount = max(calciumChlorideForCa, calciumChlorideForCl) * batchVolume
            
            if calciumChlorideAmount > 0.1 {
                calculatedAdditions.append(SaltAddition(
                    name: "Calcium Chloride (CaCl₂·2H₂O)",
                    description: "Verhoogt calcium en chloride",
                    amount: calciumChlorideAmount
                ))
                
                resultingProfile.calcium += calciumChlorideAmount / batchVolume * 272.0
                resultingProfile.chloride += calciumChlorideAmount / batchVolume * 482.0
            }
        }
        
        // Epsom Salt (MgSO4·7H2O)
        let magnesiumNeeded = max(0, targetWaterProfile.magnesium - baseWaterProfile.magnesium)
        if magnesiumNeeded > 0 {
            // Epsom salt adds 99 ppm Mg and 389 ppm SO4 per gram per liter
            let epsomAmount = magnesiumNeeded / 99.0 * batchVolume
            
            if epsomAmount > 0.1 {
                calculatedAdditions.append(SaltAddition(
                    name: "Epsom Salt (MgSO₄·7H₂O)",
                    description: "Verhoogt magnesium en sulfaat",
                    amount: epsomAmount
                ))
                
                resultingProfile.magnesium += epsomAmount / batchVolume * 99.0
                resultingProfile.sulfate += epsomAmount / batchVolume * 389.0
            }
        }
        
        // Calculate estimated mash pH (simplified)
        resultingProfile.estimatedPH = calculateEstimatedPH(profile: resultingProfile, grainWeight: grainWeight)
        
        showResults = true
    }
    
    private func calculateEstimatedPH(profile: WaterProfile, grainWeight: Double) -> Double {
        // Simplified mash pH calculation
        // Base pH from grain bill (assuming typical pale malt)
        let basePH = 5.8
        
        // Alkalinity effect (bicarbonate raises pH)
        let alkalinityEffect = profile.bicarbonate / 50.0 * 0.1
        
        // Calcium/Magnesium effect (lowers pH)
        let calciumEffect = (profile.calcium + profile.magnesium) / 200.0 * 0.2
        
        return max(5.0, min(6.5, basePH + alkalinityEffect - calciumEffect))
    }
    
    private func clearAll() {
        baseWaterProfile = WaterProfile()
        targetWaterProfile = WaterProfile.pilsner
        batchSize = ""
        mashGrainWeight = ""
        waterAdditions = []
        calculatedAdditions = []
        resultingProfile = WaterProfile()
        showResults = false
    }
}

struct WaterComparisonRow: View {
    let ion: String
    let before: Double
    let target: Double
    let after: Double
    
    var body: some View {
        HStack {
            Text(ion)
                .font(.caption)
                .frame(width: 50, alignment: .leading)
            Text(String(format: "%.0f", before))
                .font(.caption)
                .frame(width: 50, alignment: .center)
            Text(String(format: "%.0f", target))
                .font(.caption)
                .frame(width: 50, alignment: .center)
            Text(String(format: "%.0f", after))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(abs(after - target) < 20 ? .green : .orange)
                .frame(width: 50, alignment: .center)
        }
    }
}

struct WaterProfile {
    var name: String = "Custom"
    var description: String = "Custom water profile"
    var calcium: Double = 20
    var magnesium: Double = 5
    var sulfate: Double = 15
    var chloride: Double = 10
    var bicarbonate: Double = 50
    var sodium: Double = 8
    var estimatedPH: Double = 7.0
    
    var sulfateToChlorideRatio: Double {
        return chloride > 0 ? sulfate / chloride : sulfate
    }
    
    static let pilsner = WaterProfile(
        name: "Pilsner",
        description: "Zacht, laag mineraal",
        calcium: 50,
        magnesium: 10,
        sulfate: 25,
        chloride: 15,
        bicarbonate: 20,
        sodium: 5,
        estimatedPH: 5.3
    )
    
    static let ipa = WaterProfile(
        name: "IPA",
        description: "Hoog sulfaat, hoppy",
        calcium: 200,
        magnesium: 15,
        sulfate: 350,
        chloride: 75,
        bicarbonate: 30,
        sodium: 10,
        estimatedPH: 5.4
    )
    
    static let stout = WaterProfile(
        name: "Stout",
        description: "Hoog chloride, malty",
        calcium: 150,
        magnesium: 25,
        sulfate: 75,
        chloride: 200,
        bicarbonate: 150,
        sodium: 15,
        estimatedPH: 5.6
    )
    
    static let balanced = WaterProfile(
        name: "Balanced",
        description: "Universeel profiel",
        calcium: 150,
        magnesium: 15,
        sulfate: 150,
        chloride: 100,
        bicarbonate: 75,
        sodium: 10,
        estimatedPH: 5.5
    )
    
    static let amsterdam = WaterProfile(
        name: "Amsterdam",
        description: "Lokaal water profiel",
        calcium: 65,
        magnesium: 15,
        sulfate: 45,
        chloride: 85,
        bicarbonate: 120,
        sodium: 25,
        estimatedPH: 7.2
    )
    
    static let ro = WaterProfile(
        name: "RO Water",
        description: "Reverse osmosis",
        calcium: 0,
        magnesium: 0,
        sulfate: 0,
        chloride: 0,
        bicarbonate: 0,
        sodium: 0,
        estimatedPH: 7.0
    )
    
    static let distilled = WaterProfile(
        name: "Distilled",
        description: "Gedestilleerd water",
        calcium: 0,
        magnesium: 0,
        sulfate: 0,
        chloride: 0,
        bicarbonate: 0,
        sodium: 0,
        estimatedPH: 7.0
    )
    
    static let knownProfiles: [WaterProfile] = [
        .pilsner, .ipa, .stout, .balanced
    ]
}

struct WaterAddition {
    var salt: WaterSalt
    var amount: Double // grams
}

struct SaltAddition {
    let name: String
    let description: String
    let amount: Double
}

enum WaterSalt: String, CaseIterable {
    case gypsum = "Gypsum (CaSO₄)"
    case calciumChloride = "Calcium Chloride (CaCl₂)"
    case epsomSalt = "Epsom Salt (MgSO₄)"
    case bakingSoda = "Baking Soda (NaHCO₃)"
    case salt = "Salt (NaCl)"
    
    var description: String {
        switch self {
        case .gypsum: return "Verhoogt Ca²⁺ en SO₄²⁻"
        case .calciumChloride: return "Verhoogt Ca²⁺ en Cl⁻"
        case .epsomSalt: return "Verhoogt Mg²⁺ en SO₄²⁻"
        case .bakingSoda: return "Verhoogt Na⁺ en HCO₃⁻"
        case .salt: return "Verhoogt Na⁺ en Cl⁻"
        }
    }
}

struct WaterChemistryInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💧 Water Chemistry Basics")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("**Water is 90% van je bier** - de juiste mineralen maken het verschil tussen een goede en geweldige brew.")
                        
                        Text("**Ionen** zijn opgeloste mineralen die de smaak, mouthfeel en brouwproces beïnvloeden.")
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🧪 Belangrijke Ionen")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("• **Calcium (Ca²⁺)**: 150-300 ppm - enzyme activiteit, eiwit neerslag, helderheid")
                        Text("• **Magnesium (Mg²⁺)**: 10-30 ppm - gist voeding, enzyme co-factor")
                        Text("• **Sulfaat (SO₄²⁻)**: 150-400 ppm - hop karakter, droge finish")
                        Text("• **Chloride (Cl⁻)**: 50-200 ppm - mout zoetheid, mouthfeel")
                        Text("• **Bicarbonaat (HCO₃⁻)**: 0-300 ppm - mash pH buffer")
                        Text("• **Sodium (Na⁺)**: 0-150 ppm - smaak versterker (in kleine hoeveelheden)")
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("⚖️ SO₄:Cl Ratio")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("**De sulfaat-chloride ratio bepaalt het karakter:**")
                        Text("• **> 2:1**: Hoppy, droog, crisp (IPA, Pilsner)")
                        Text("• **1:1**: Balanced (Most ales)")
                        Text("• **< 1:2**: Malty, rond, zoet (Stout, Porter)")
                        
                        Text("**Burton-on-Trent** (SO₄:Cl = 4:1) is beroemd voor hoppy ales")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🧂 Zout Toevoegingen")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("• **Gypsum (CaSO₄·2H₂O)**: Verhoogt Ca²⁺ en SO₄²⁻")
                        Text("• **Calcium Chloride (CaCl₂·2H₂O)**: Verhoogt Ca²⁺ en Cl⁻")
                        Text("• **Epsom Salt (MgSO₄·7H₂O)**: Verhoogt Mg²⁺ en SO₄²⁻")
                        Text("• **Baking Soda (NaHCO₃)**: Verhoogt alkaliteit")
                        Text("• **Salt (NaCl)**: Verhoogt Na⁺ en Cl⁻")
                        
                        Text("**Tip**: Start met kleine hoeveelheden en proef het verschil!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🔬 Mash pH")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("**Optimale mash pH**: 5.2 - 5.6")
                        Text("• Betere enzyme activiteit")
                        Text("• Verbeterde extract efficiency")
                        Text("• Minder tannin extractie")
                        Text("• Helderder bier")
                        
                        Text("**pH strips** of digitale meter gebruiken voor meting")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🇳🇱 Nederlandse Water")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("**Nederlands kraanwater** is meestal:")
                        Text("• Relatief zacht (laag Ca²⁺/Mg²⁺)")
                        Text("• Matig alkalisch (HCO₃⁻)")
                        Text("• Geschikt voor lichte bieren")
                        Text("• Heeft aanpassingen nodig voor hoppy bieren")
                        
                        Text("**Tip**: Check je lokale waterrapport of gebruik RO water voor controle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Water Chemistry Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Brew History Models

struct CompletedBrewSession: Identifiable {
    let id = UUID()
    let recipeName: String
    let recipeStyle: String
    let startDate: Date
    let endDate: Date
    let finalABV: Double?
    let originalGravity: Double?
    let finalGravity: Double?
    let totalDuration: TimeInterval
    let rating: Int // 1-5 stars
    let notes: String
    let success: Bool
    let photos: [String] // Photo file names
    
    var brewDurationFormatted: String {
        let days = Int(totalDuration) / (24 * 3600)
        if days > 0 {
            return "\(days) dagen"
        } else {
            let hours = Int(totalDuration) / 3600
            return "\(hours) uur"
        }
    }
    
    var brewDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startDate)
    }
}

struct BrewHistoryView: View {
    @Binding var selectedRecipeForBrewing: DetailedRecipe?
    @State private var completedSessions: [CompletedBrewSession] = [
        // Sample data
        CompletedBrewSession(
            recipeName: "Klassiek Pilsner",
            recipeStyle: "Czech Pilsner",
            startDate: Calendar.current.date(byAdding: .day, value: -21, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            finalABV: 4.8,
            originalGravity: 1.048,
            finalGravity: 1.010,
            totalDuration: 14 * 24 * 3600, // 14 days
            rating: 5,
            notes: "Perfect gelukt! Heldere smaak en mooie mousse.",
            success: true,
            photos: []
        ),
        CompletedBrewSession(
            recipeName: "American IPA",
            recipeStyle: "American IPA", 
            startDate: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: -31, to: Date()) ?? Date(),
            finalABV: 6.1,
            originalGravity: 1.062,
            finalGravity: 1.012,
            totalDuration: 14 * 24 * 3600,
            rating: 4,
            notes: "Goede hop aroma's, volgende keer iets minder bitter.",
            success: true,
            photos: []
        ),
        CompletedBrewSession(
            recipeName: "Weizen Experiment",
            recipeStyle: "Hefeweizen",
            startDate: Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: -58, to: Date()) ?? Date(),
            finalABV: nil,
            originalGravity: 1.052,
            finalGravity: nil,
            totalDuration: 2 * 24 * 3600,
            rating: 1,
            notes: "Infectie gekregen, helaas weg moeten gooien.",
            success: false,
            photos: []
        )
    ]
    @State private var selectedSession: CompletedBrewSession?
    @State private var showingStats = false
    
    var successRate: Double {
        let successful = completedSessions.filter { $0.success }.count
        return completedSessions.isEmpty ? 0 : Double(successful) / Double(completedSessions.count) * 100
    }
    
    var averageABV: Double {
        let successful = completedSessions.filter { $0.success && $0.finalABV != nil }
        let totalABV = successful.compactMap { $0.finalABV }.reduce(0, +)
        guard !successful.isEmpty else { return 0 }
        let result = totalABV / Double(successful.count)
        return result.isNaN || result.isInfinite ? 0 : result
    }
    
    var averageRating: Double {
        let successful = completedSessions.filter { $0.success }
        let totalRating = successful.map { $0.rating }.reduce(0, +)
        guard !successful.isEmpty else { return 0 }
        let result = Double(totalRating) / Double(successful.count)
        return result.isNaN || result.isInfinite ? 0 : result
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header in consistent style
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Brouw Geschiedenis")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Overzicht van alle brouwsessies")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(completedSessions.count) sessies")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                
                // Quick Stats
                VStack(spacing: 15) {
                    HStack {
                        Text("📊 Snelle Statistieken")
                            .font(.headline)
                        Spacer()
                        Button("Meer Stats") {
                            showingStats = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        StatCard(title: "Success Rate", value: String(format: "%.0f%%", successRate), icon: "checkmark.circle.fill", color: successRate > 80 ? .green : .orange)
                        StatCard(title: "Gem. ABV", value: String(format: "%.1f%%", averageABV), icon: "percent", color: .blue)
                        StatCard(title: "Gem. Rating", value: String(format: "%.1f ⭐", averageRating), icon: "star.fill", color: .purple)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Sessions List
                List {
                    ForEach(completedSessions.sorted { $0.endDate > $1.endDate }) { session in
                        BrewHistoryRowView(session: session, selectedRecipeForBrewing: $selectedRecipeForBrewing)
                            .onTapGesture {
                                selectedSession = session
                            }
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingStats) {
                BrewStatsView(sessions: completedSessions)
            }
            .sheet(item: $selectedSession) { session in
                BrewSessionDetailView(session: session, selectedRecipeForBrewing: $selectedRecipeForBrewing)
            }
        }
    }
}

struct BrewHistoryRowView: View {
    let session: CompletedBrewSession
    @Binding var selectedRecipeForBrewing: DetailedRecipe?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.recipeName)
                        .font(.headline)
                        .foregroundColor(session.success ? .primary : .secondary)
                    Text(session.recipeStyle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if session.success {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    
                    if session.success {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= session.rating ? "star.fill" : "star")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(session.brewDateFormatted)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(session.brewDurationFormatted)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let abv = session.finalABV {
                    HStack(spacing: 4) {
                        Image(systemName: "percent")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(String(format: "%.1f%% ABV", abv))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            if !session.notes.isEmpty {
                Text(session.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
            
            // Actions row
            if session.success {
                HStack {
                    Button {
                        // TODO: Add quick review editor
                        print("Quick review for: \(session.recipeName)")
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "star.circle")
                            Text("Review")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Spacer()
                    
                    Button {
                        let mockRecipe = DetailedRecipe(
                            name: session.recipeName,
                            style: session.recipeStyle,
                            abv: session.finalABV ?? 5.0,
                            ibu: 30,
                            difficulty: .intermediate,
                            brewTime: 300,
                            ingredients: [],
                            instructions: [],
                            notes: "Opnieuw gebrouwen vanaf geschiedenis"
                        )
                        selectedRecipeForBrewing = mockRecipe
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("Brouw opnieuw")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct BrewSessionDetailView: View {
    let session: CompletedBrewSession
    @Binding var selectedRecipeForBrewing: DetailedRecipe?
    @Environment(\.dismiss) private var dismiss
    @State private var showingReviewEditor = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text(session.recipeName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(session.recipeStyle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            if session.success {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Succesvol")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Mislukt")
                                    .foregroundColor(.red)
                            }
                            
                            Spacer()
                            
                            if session.success {
                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= session.rating ? "star.fill" : "star")
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Stats
                    if session.success {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📊 Resultaten")
                                .font(.headline)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                if let abv = session.finalABV {
                                    ResultCard(title: "ABV", value: String(format: "%.1f%%", abv), color: .green)
                                }
                                if let og = session.originalGravity {
                                    ResultCard(title: "OG", value: String(format: "%.3f", og), color: .blue)
                                }
                                if let fg = session.finalGravity {
                                    ResultCard(title: "FG", value: String(format: "%.3f", fg), color: .orange)
                                }
                                ResultCard(title: "Duur", value: session.brewDurationFormatted, color: .purple)
                            }
                        }
                    }
                    
                    // Timeline
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📅 Timeline")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(.green)
                                Text("Start: \(session.startDate, formatter: detailDateFormatter)")
                                    .font(.body)
                            }
                            
                            HStack {
                                Image(systemName: session.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(session.success ? .blue : .red)
                                Text("Einde: \(session.endDate, formatter: detailDateFormatter)")
                                    .font(.body)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // Notes
                    if !session.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📝 Notities")
                                .font(.headline)
                            
                            Text(session.notes)
                                .font(.body)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    
                    // Brew Again Section
                    if session.success {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("🔄 Acties")
                                .font(.headline)
                            
                            HStack(spacing: 12) {
                                Button {
                                    // Find matching recipe and set it for brewing
                                    // In a real app, you'd fetch the actual recipe from your data source
                                    let mockRecipe = DetailedRecipe(
                                        name: session.recipeName,
                                        style: session.recipeStyle,
                                        abv: session.finalABV ?? 5.0,
                                        ibu: 30,
                                        difficulty: .intermediate,
                                        brewTime: 300,
                                        ingredients: [],
                                        instructions: [],
                                        notes: "Opnieuw gebrouwen vanaf geschiedenis"
                                    )
                                    selectedRecipeForBrewing = mockRecipe
                                    dismiss()
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Brouw Opnieuw")
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Button {
                                    showingReviewEditor = true
                                } label: {
                                    HStack {
                                        Image(systemName: "pencil.circle")
                                        Text("Review Bewerken")
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Brouw Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingReviewEditor) {
                ReviewEditorView(session: session)
            }
        }
    }
    
    private var detailDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }
}

struct BrewStatsView: View {
    let sessions: [CompletedBrewSession]
    @Environment(\.dismiss) private var dismiss
    
    var successfulSessions: [CompletedBrewSession] {
        sessions.filter { $0.success }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Overview Stats
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📊 Overzicht")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            StatCard(title: "Totaal Brouwsels", value: "\(sessions.count)", icon: "flask.fill", color: .blue)
                            StatCard(title: "Succesvol", value: "\(successfulSessions.count)", icon: "checkmark.circle.fill", color: .green)
                            StatCard(title: "Success Rate", value: String(format: "%.0f%%", Double(successfulSessions.count) / Double(sessions.count) * 100), icon: "chart.bar.fill", color: .orange)
                            StatCard(title: "Gemiddelde Rating", value: String(format: "%.1f ⭐", averageRating), icon: "star.fill", color: .purple)
                        }
                    }
                    
                    // ABV Stats
                    if !successfulSessions.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("🍺 Alcohol Statistieken")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                                            StatCard(title: "Gem. ABV", value: String(format: "%.1f%%", averageABV), icon: "percent", color: .green)
                            StatCard(title: "Hoogste ABV", value: String(format: "%.1f%%", maxABV), icon: "arrow.up.circle.fill", color: .red)
                            StatCard(title: "Laagste ABV", value: String(format: "%.1f%%", minABV), icon: "arrow.down.circle.fill", color: .blue)
                            StatCard(title: "ABV Bereik", value: String(format: "%.1f%%", maxABV - minABV), icon: "chart.line.uptrend.xyaxis", color: .orange)
                            }
                        }
                    }
                    
                    // Recipe Styles
                    VStack(alignment: .leading, spacing: 15) {
                        Text("🎯 Populaire Stijlen")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(popularStyles, id: \.style) { styleData in
                            HStack {
                                Text(styleData.style)
                                    .font(.body)
                                Spacer()
                                Text("\(styleData.count)x")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(4)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Statistieken")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var averageRating: Double {
        let totalRating = successfulSessions.map { $0.rating }.reduce(0, +)
        return successfulSessions.isEmpty ? 0 : Double(totalRating) / Double(successfulSessions.count)
    }
    
    private var averageABV: Double {
        let abvSessions = successfulSessions.compactMap { $0.finalABV }
        guard !abvSessions.isEmpty else { return 0 }
        let result = abvSessions.reduce(0, +) / Double(abvSessions.count)
        return result.isNaN || result.isInfinite ? 0 : result
    }
    
    private var maxABV: Double {
        return successfulSessions.compactMap { $0.finalABV }.max() ?? 0
    }
    
    private var minABV: Double {
        return successfulSessions.compactMap { $0.finalABV }.min() ?? 0
    }
    
    private var popularStyles: [(style: String, count: Int)] {
        let styleCounts = Dictionary(grouping: sessions) { $0.recipeStyle }
            .mapValues { $0.count }
        return styleCounts.sorted { $0.value > $1.value }
            .map { (style: $0.key, count: $0.value) }
    }
}

// MARK: - Review Editor

struct ReviewEditorView: View {
    let session: CompletedBrewSession
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentRating: Int
    @State private var currentNotes: String
    @State private var brewingTips: String = ""
    @State private var improvementNotes: String = ""
    
    init(session: CompletedBrewSession) {
        self.session = session
        self._currentRating = State(initialValue: session.rating)
        self._currentNotes = State(initialValue: session.notes)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("📝 Review Bewerken")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(session.recipeName)
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("Gebrouwen op \(session.brewDateFormatted)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Rating Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("⭐ Beoordeling")
                            .font(.headline)
                        
                        Text("Hoe tevreden ben je met dit brouwsel?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 15) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    currentRating = star
                                } label: {
                                    Image(systemName: star <= currentRating ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundColor(star <= currentRating ? .orange : .gray)
                                }
                            }
                            
                            Spacer()
                            
                            Text(ratingDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Overall Notes Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📝 Algemene Notities")
                            .font(.headline)
                        
                        Text("Hoe ging het brouwen? Wat viel op?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $currentNotes)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Brewing Tips Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("💡 Brouw Tips")
                            .font(.headline)
                        
                        Text("Wat zou je volgende keer anders doen?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $brewingTips)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Improvement Notes Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("🎯 Verbeteringen")
                            .font(.headline)
                        
                        Text("Aanpassingen voor volgende keer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $improvementNotes)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Quick Rating Buttons
                    VStack(alignment: .leading, spacing: 15) {
                        Text("🚀 Snelle Beoordeling")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            QuickRatingButton(title: "Perfect! 😍", rating: 5, currentRating: $currentRating, notes: $currentNotes, note: "Geweldig gelukt! Precies zoals gepland.")
                            QuickRatingButton(title: "Goed 👍", rating: 4, currentRating: $currentRating, notes: $currentNotes, note: "Goed resultaat, kleine verbeterpunten.")
                            QuickRatingButton(title: "Oké 😐", rating: 3, currentRating: $currentRating, notes: $currentNotes, note: "Redelijk resultaat, moet beter kunnen.")
                            QuickRatingButton(title: "Matig 😕", rating: 2, currentRating: $currentRating, notes: $currentNotes, note: "Niet helemaal gelukt, lering getrokken.")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Review Bewerken")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuleren") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Opslaan") {
                        // TODO: Save the updated review
                        // In a real app, you'd update the session in your data store
                        print("Saving review - Rating: \(currentRating), Notes: \(currentNotes)")
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var ratingDescription: String {
        switch currentRating {
        case 5: return "Uitstekend!"
        case 4: return "Goed"
        case 3: return "Gemiddeld"
        case 2: return "Matig"
        case 1: return "Slecht"
        default: return ""
        }
    }
}

struct QuickRatingButton: View {
    let title: String
    let rating: Int
    @Binding var currentRating: Int
    @Binding var notes: String
    let note: String
    
    var body: some View {
        Button {
            currentRating = rating
            if notes.isEmpty {
                notes = note
            }
        } label: {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(currentRating == rating ? Color.blue.opacity(0.2) : Color(.systemGray5))
                .foregroundColor(currentRating == rating ? .blue : .primary)
                .cornerRadius(8)
        }
    }
}

// MARK: - XML Import

struct XMLImportView: View {
    @Environment(\.dismiss) private var dismiss
    let onImport: ([DetailedRecipe]) -> Void
    
    @State private var isImporting = false
    @State private var importedRecipes: [DetailedRecipe] = []
    @State private var errorMessage: String?
    @State private var showingFilePicker = false
    @State private var xmlContent = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "tray.and.arrow.down.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("XML Recepten Import")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Importeer BeerXML recepten of plak XML inhoud")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                                    Text("💡 Tip: Voor beste resultaten, kopieer XML bestanden naar je Downloads map")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                
                Text("Als je nog steeds problemen hebt, probeer dan de XML inhoud direct te plakken")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }
                .padding()
                
                // Import Methods
                VStack(spacing: 20) {
                    // File Import Button
                    Button {
                        showingFilePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text("Selecteer XML Bestand")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Text("of")
                        .foregroundColor(.secondary)
                    
                    // Text Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Plak XML Inhoud:")
                            .font(.headline)
                        
                        TextEditor(text: $xmlContent)
                            .frame(minHeight: 150)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    
                    if !xmlContent.isEmpty {
                        Button {
                            parseXMLContent()
                        } label: {
                            HStack {
                                if isImporting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.down.doc.fill")
                                }
                                Text(isImporting ? "Importeren..." : "Importeer XML")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(xmlContent.isEmpty ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(xmlContent.isEmpty || isImporting)
                    }
                }
                .padding()
                
                // Results
                if !importedRecipes.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("✅ Gevonden Recepten:")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 10) {
                                ForEach(importedRecipes) { recipe in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(recipe.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(recipe.style)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(String(format: "%.1f%%", recipe.abv))
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.green.opacity(0.2))
                                            .foregroundColor(.green)
                                            .cornerRadius(4)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                        
                        Button {
                            onImport(importedRecipes)
                            dismiss()
                        } label: {
                            Text("Voeg \(importedRecipes.count) Recepten Toe")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                
                // Error Message
                if let error = errorMessage {
                    Text("❌ \(error)")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("XML Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuleren") {
                        dismiss()
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.xml, .plainText, .data],
            allowsMultipleSelection: false
        ) { result in
            // Dispatch to main queue to avoid view service issues
            DispatchQueue.main.async {
                handleFileImport(result)
            }
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let urls):
                print("📁 File picker returned \(urls.count) URLs")
                
                guard let url = urls.first else { 
                    self.errorMessage = "Geen bestand geselecteerd."
                    return 
                }
                
                print("📁 Selected URL: \(url)")
                print("📁 File extension: \(url.pathExtension)")
                print("📁 File name: \(url.lastPathComponent)")
                
                // Check if the file extension is appropriate
                let validExtensions = ["xml", "beerxml", "txt"]
                let fileExtension = url.pathExtension.lowercased()
                
                if !validExtensions.contains(fileExtension) && !fileExtension.isEmpty {
                    self.errorMessage = """
                    Ongeldig bestandstype: .\(fileExtension)
                    
                    Ondersteunde formaten:
                    • .xml (BeerXML bestanden)
                    • .beerxml
                    • .txt (platte tekst XML)
                    """
                    return
                }
                
                // Add a small delay to ensure the file picker has fully closed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.importFileFromURL(url)
                }
                
            case .failure(let error):
                print("📁 File picker error: \(error)")
                self.errorMessage = "Fout bij selecteren bestand: \(error.localizedDescription)"
            }
        }
    }
    
    private func importFileFromURL(_ url: URL) {
        // Add loading state
        isImporting = true
        errorMessage = nil
        
        // Create a task with timeout
        Task {
            do {
                let result = try await withTimeout(seconds: 10) {
                    try await importFileWithTimeout(url)
                }
                
                await MainActor.run {
                    self.xmlContent = result
                    self.parseXMLContent()
                    self.isImporting = false
                    
                    // Clear content after parsing to free memory
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if !self.isImporting {
                            self.xmlContent = ""
                        }
                    }
                }
            } catch TimeoutError.timedOut {
                await MainActor.run {
                    self.errorMessage = "Bestand importeren duurde te lang. Probeer een kleiner bestand."
                    self.isImporting = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Fout bij importeren: \(error.localizedDescription)"
                    self.isImporting = false
                }
            }
        }
    }
    
    private func importFileWithTimeout(_ url: URL) async throws -> String {
        // Try reading with different approaches
        var content: String?
        var readMethod = ""
        
        // Method 1: Direct read with UTF-8
        if content == nil {
            do {
                content = try String(contentsOf: url, encoding: .utf8)
                readMethod = "Direct UTF-8"
            } catch {
                print("📁 Direct UTF-8 failed: \(error)")
            }
        }
        
        // Method 2: Read as Data first, then convert
        if content == nil {
            do {
                let data = try Data(contentsOf: url)
                if let stringContent = String(data: data, encoding: .utf8) {
                    content = stringContent
                    readMethod = "Data->UTF-8"
                } else if let stringContent = String(data: data, encoding: .ascii) {
                    content = stringContent
                    readMethod = "Data->ASCII"
                }
            } catch {
                print("📁 Data read failed: \(error)")
            }
        }
        
        guard let finalContent = content, !finalContent.isEmpty else {
            throw ImportError.unreadableFile
        }
        
        print("📁 Successfully read file using: \(readMethod)")
        print("📁 Content length: \(finalContent.count) characters")
        
        return finalContent
    }
    
    // Helper function to add timeout to async operations
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError.timedOut
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    // Custom errors
    enum TimeoutError: Error {
        case timedOut
    }
    
    enum ImportError: Error, LocalizedError {
        case unreadableFile
        
        var errorDescription: String? {
            switch self {
            case .unreadableFile:
                return """
                Het bestand kon niet worden gelezen of is leeg.
                
                Controleer of:
                • Het bestand een geldig XML bestand is
                • Het bestand niet beschadigd is
                • Je toegang hebt tot het bestand
                """
            }
        }
    }
    
    private func parseXMLContent() {
        isImporting = true
        errorMessage = nil
        
        // Validate content first
        guard !xmlContent.isEmpty else {
            isImporting = false
            errorMessage = "XML inhoud is leeg"
            return
        }
        
        guard xmlContent.contains("<recipe") || xmlContent.contains("<RECIPE") else {
            isImporting = false
            errorMessage = "Geen <recipe> elementen gevonden in XML"
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let parser = BeerXMLParser()
            let recipes = parser.parseXML(self.xmlContent)
            
            DispatchQueue.main.async {
                self.isImporting = false
                
                if recipes.isEmpty {
                    self.errorMessage = "Geen geldige recepten gevonden in XML.\n\nControleer of het bestand BeerXML formaat heeft."
                } else {
                    self.importedRecipes = recipes
                    self.errorMessage = nil
                }
            }
        }
    }
}

// MARK: - BeerXML Parser

class BeerXMLParser: NSObject, XMLParserDelegate {
    private var recipes: [DetailedRecipe] = []
    private var currentRecipe: BeerXMLRecipe?
    private var currentElement = ""
    private var currentValue = ""
    
    // Temporary recipe data structure for parsing
    private struct BeerXMLRecipe {
        var name = ""
        var style = ""
        var og: Double = 1.050
        var fg: Double = 1.010
        var abv: Double = 5.0
        var ibu: Int = 30
        var ingredients: [RecipeIngredient] = []
        var instructions: [String] = []
        var notes = ""
        var brewTime: Int = 240
    }
    
    func parseXML(_ xmlString: String) -> [DetailedRecipe] {
        recipes = []
        currentRecipe = nil
        
        guard let data = xmlString.data(using: .utf8), !data.isEmpty else {
            return []
        }
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        // Set parser settings for better error handling
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        
        let success = parser.parse()
        
        if !success {
            print("XML parsing failed: \(parser.parserError?.localizedDescription ?? "Unknown error")")
        }
        
        return recipes
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, 
                namespaceURI: String?, qualifiedName qName: String?, 
                attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName.lowercased()
        currentValue = ""
        
        if currentElement == "recipe" {
            currentRecipe = BeerXMLRecipe()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, 
                namespaceURI: String?, qualifiedName qName: String?) {
        let element = elementName.lowercased()
        
        guard var recipe = currentRecipe else { return }
        
        switch element {
        case "name":
            recipe.name = currentValue.isEmpty ? "Onbekend Recept" : currentValue
        case "style", "style_name":
            if !currentValue.isEmpty {
                recipe.style = currentValue
            }
        case "og", "original_gravity":
            if let value = Double(currentValue) {
                recipe.og = value > 10 ? value / 1000 : value // Handle both 1.050 and 1050 formats
            }
        case "fg", "final_gravity":
            if let value = Double(currentValue) {
                recipe.fg = value > 10 ? value / 1000 : value
            }
        case "abv", "alcohol_by_volume":
            if let value = Double(currentValue) {
                recipe.abv = value
            }
        case "ibu":
            if let value = Int(currentValue) {
                recipe.ibu = value
            }
        case "notes", "description":
            if !currentValue.isEmpty {
                recipe.notes = currentValue
            }
        case "boil_time":
            if let value = Int(currentValue) {
                recipe.brewTime = value + 60 // Add mash time estimate
            }
        case "recipe":
            // Calculate ABV if not provided
            if recipe.abv == 5.0 { // Default value, likely not set
                recipe.abv = (recipe.og - recipe.fg) * 131.25
            }
            
            // Convert to DetailedRecipe
            let detailedRecipe = DetailedRecipe(
                name: recipe.name,
                style: recipe.style.isEmpty ? "Onbekende Stijl" : recipe.style,
                abv: recipe.abv,
                ibu: recipe.ibu,
                difficulty: determineDifficulty(abv: recipe.abv, ibu: recipe.ibu),
                brewTime: recipe.brewTime,
                ingredients: recipe.ingredients.isEmpty ? generateDefaultIngredients(og: recipe.og, ibu: recipe.ibu) : recipe.ingredients,
                instructions: recipe.instructions.isEmpty ? generateDefaultInstructions() : recipe.instructions,
                notes: recipe.notes.isEmpty ? "Geïmporteerd via XML" : recipe.notes
            )
            
            recipes.append(detailedRecipe)
            currentRecipe = nil
        default:
            break
        }
        
        currentRecipe = recipe
        currentValue = ""
    }
    
    private func determineDifficulty(abv: Double, ibu: Int) -> RecipeDifficulty {
        if abv > 8.0 || ibu > 60 {
            return .advanced
        } else if abv > 5.5 || ibu > 30 {
            return .intermediate
        } else {
            return .beginner
        }
    }
    
    private func generateDefaultIngredients(og: Double, ibu: Int) -> [RecipeIngredient] {
        var ingredients: [RecipeIngredient] = []
        
        // Base malt (estimate based on OG)
        let maltAmount = Int((og - 1.0) * 1000 * 0.8) // Rough calculation
        ingredients.append(RecipeIngredient(
            name: "Pilsner Mout",
            amount: "\(maltAmount)g",
            type: .grain,
            timing: "Maischen"
        ))
        
        // Hop (estimate based on IBU)
        let hopAmount = Int(Double(ibu) * 0.8) // Rough calculation
        ingredients.append(RecipeIngredient(
            name: "Hop Pellets",
            amount: "\(hopAmount)g",
            type: .hop,
            timing: "60 min"
        ))
        
        // Yeast
        ingredients.append(RecipeIngredient(
            name: "Droge Gist",
            amount: "11g",
            type: .yeast,
            timing: "Gisting"
        ))
        
        return ingredients
    }
    
    private func generateDefaultInstructions() -> [String] {
        return [
            "Maischen op 65°C gedurende 60 minuten",
            "Spoelen met 78°C water",
            "Koken gedurende 60 minuten, hoppen toevoegen volgens schema",
            "Afkoelen tot 20°C",
            "Gist toevoegen en vergisten op 18-20°C",
            "Nabezinken en botelen na 1-2 weken"
        ]
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}