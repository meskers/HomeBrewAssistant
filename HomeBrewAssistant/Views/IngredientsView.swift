import SwiftUI

struct IngredientsView: View {
    @StateObject private var inventoryManager = SmartInventoryManager()
    @State private var selectedTab = 0
    @State private var showingAddForm = false
    @State private var selectedCategory: IngredientType? = nil
    @Binding var selectedRecipeForBrewing: DetailedRecipe?
    
    init(selectedRecipeForBrewing: Binding<DetailedRecipe?> = .constant(nil)) {
        self._selectedRecipeForBrewing = selectedRecipeForBrewing
    }
    
    var filteredItems: [InventoryItem] {
        if let selectedCategory = selectedCategory {
            return inventoryManager.ingredients.filter { $0.category == selectedCategory.rawValue }
        }
        return inventoryManager.ingredients
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Selected Recipe Header (if any)
                if let recipe = selectedRecipeForBrewing {
                    selectedRecipeHeader(recipe)
                }
                
                // Tab Picker
                Picker("Tabs", selection: $selectedTab) {
                    Text("Voorraad").tag(0)
                    Text("Boodschappen").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    inventoryTab
                        .tag(0)
                    
                    shoppingListTab
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("🌾 Ingrediënten")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: selectedTab == 0 && !inventoryManager.ingredients.isEmpty ? 
                    AnyView(Menu {
                        Button("Alle categorieën") {
                            selectedCategory = nil
                        }
                        
                        ForEach(IngredientType.allCases, id: \.self) { category in
                            Button(category.localizedName) {
                                selectedCategory = category
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }) : AnyView(EmptyView()),
                trailing: Button(action: {
                    showingAddForm = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddForm) {
                AddInventoryItemSheet(isPresented: $showingAddForm, inventoryManager: inventoryManager)
            }
            .onChange(of: selectedRecipeForBrewing) { recipe in
                if let recipe = recipe {
                    generateShoppingListForRecipe(recipe)
                }
            }
        }
    }
    

    
    // MARK: - Selected Recipe Header
    private func selectedRecipeHeader(_ recipe: DetailedRecipe) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.brewTheme)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("🍺 Geselecteerd Recept")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(recipe.name)
                        .font(.subheadline)
                        .foregroundColor(.brewTheme)
                }
                
                Spacer()
                
                Button("📋 Check Voorraad") {
                    generateShoppingListForRecipe(recipe)
                    selectedTab = 1 // Switch to shopping list tab
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.brewTheme)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Generate Shopping List
    private func generateShoppingListForRecipe(_ recipe: DetailedRecipe) {
        inventoryManager.generateShoppingListForRecipe(recipe)
        
        // Show notification if shopping list is generated
        if !inventoryManager.shoppingList.isEmpty {
            HapticManager.shared.success()
        }
    }
    
    // MARK: - Inventory Tab
    private var inventoryTab: some View {
        VStack {
            if inventoryManager.ingredients.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "list.clipboard")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("Nog geen voorraad")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Voeg je eerste ingrediënt toe")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(filteredItems) { ingredient in
                        InventoryItemCard(item: ingredient, inventoryManager: inventoryManager)
                    }
                    .onDelete { offsets in
                        deleteInventoryItems(at: offsets)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    // MARK: - Shopping List Tab
    private var shoppingListTab: some View {
        VStack {
            if inventoryManager.shoppingList.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "cart")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    if selectedRecipeForBrewing != nil {
                        Text("Alle ingrediënten zijn op voorraad!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Je hebt alles wat je nodig hebt voor dit recept")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Boodschappenlijst is leeg")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Selecteer een recept om te brouwen voor automatische boodschappenlijst")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                Spacer()
            } else {
                VStack(spacing: 16) {
                    // Total Cost Header
                    HStack {
                        Text("💰 Totaal: €\(String(format: "%.2f", totalCost))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Spacer()
                        Button("Wis Alles") {
                            inventoryManager.shoppingList.removeAll()
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    
                    List {
                        ForEach(inventoryManager.shoppingList) { item in
                            ShoppingListItemRow(item: item, inventoryManager: inventoryManager)
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                let item = inventoryManager.shoppingList[index]
                                inventoryManager.removeFromShoppingList(item)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
    
    private var totalCost: Double {
        inventoryManager.shoppingList.reduce(0) { $0 + $1.estimatedPrice }
    }
    
    private func deleteInventoryItems(at offsets: IndexSet) {
        for offset in offsets {
            let ingredient = inventoryManager.ingredients[offset]
            inventoryManager.removeIngredient(ingredient)
        }
    }
}

struct InventoryItemCard: View {
    let item: InventoryItem
    let inventoryManager: SmartInventoryManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: getCategoryIcon(item.category))
                .foregroundColor(getCategoryColor(item.category))
                .font(.title2)
            
            // Item Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                HStack {
                    Text("\(formatAmount(item.amount)) \(item.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if !item.inStock {
                        Text("❌ Op")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(6)
                    } else if item.isLowStock {
                        Text("⚠️ Laag")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(6)
                    } else {
                        Text("✅ Ok")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(6)
                    }
                }
            }
            
            Spacer()
            
            // Toggle Stock Button
            Button(action: {
                inventoryManager.toggleStock(for: item)
            }) {
                Image(systemName: item.inStock ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(item.inStock ? .green : .red)
                    .font(.title3)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount == floor(amount) {
            return String(Int(amount))
        } else {
            return String(format: "%.1f", amount)
        }
    }
    
    private func getCategoryIcon(_ category: String) -> String {
        let lowerCategory = category.lowercased()
        if lowerCategory.contains("mout") || lowerCategory.contains("grain") {
            return "leaf.fill"
        } else if lowerCategory.contains("hop") {
            return "leaf.circle.fill"
        } else if lowerCategory.contains("gist") || lowerCategory.contains("yeast") {
            return "circle.circle.fill"
        } else {
            return "plus.circle.fill"
        }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        let lowerCategory = category.lowercased()
        if lowerCategory.contains("mout") || lowerCategory.contains("grain") {
            return .maltGold
        } else if lowerCategory.contains("hop") {
            return .hopGreen
        } else if lowerCategory.contains("gist") || lowerCategory.contains("yeast") {
            return .orange
        } else {
            return .purple
        }
    }
}

struct ShoppingListItemRow: View {
    let item: ShoppingListItem
    let inventoryManager: SmartInventoryManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Ingredient Icon
            Image(systemName: getIngredientIcon(item.ingredientName))
                .foregroundColor(getIngredientColor(item.ingredientName))
                .font(.title2)
            
            // Item Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.ingredientName)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text("Hoeveelheid: \(formatQuantity(item.requiredAmount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Price and Action
            VStack(alignment: .trailing, spacing: 4) {
                Text("€\(String(format: "%.2f", item.estimatedPrice))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Button("🛒 Kopen") {
                    HapticManager.shared.success()
                    withAnimation(.spring()) {
                    inventoryManager.markAsAcquired(item)
                    }
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .foregroundColor(.green)
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatQuantity(_ quantity: Double) -> String {
        if quantity < 1000 {
            return String(format: "%.0f g", quantity)
        } else {
            return String(format: "%.1f kg", quantity / 1000)
        }
    }
    
    private func getIngredientIcon(_ name: String) -> String {
        let lowerName = name.lowercased()
        if lowerName.contains("mout") || lowerName.contains("grain") {
            return "leaf.fill"
        } else if lowerName.contains("hop") {
            return "leaf.circle.fill"
        } else if lowerName.contains("gist") || lowerName.contains("yeast") {
            return "circle.circle.fill"
        } else {
            return "plus.circle.fill"
        }
    }
    
    private func getIngredientColor(_ name: String) -> Color {
        let lowerName = name.lowercased()
        if lowerName.contains("mout") || lowerName.contains("grain") {
            return .maltGold
        } else if lowerName.contains("hop") {
            return .hopGreen
        } else if lowerName.contains("gist") || lowerName.contains("yeast") {
            return .orange
        } else {
            return .purple
        }
    }
}

struct AddInventoryItemSheet: View {
    @Binding var isPresented: Bool
    let inventoryManager: SmartInventoryManager
    
    @State private var name = ""
    @State private var category: IngredientType = .other
    @State private var amount: Double = 0
    @State private var unit = "g"
    @State private var notes = ""
    @State private var isLowStock = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ingrediënt Details")) {
                    TextField("Naam", text: $name)
                    
                    Picker("Categorie", selection: $category) {
                        ForEach(IngredientType.allCases, id: \.self) { category in
                            Text(category.localizedName).tag(category)
                        }
                    }
                    
                    HStack {
                        Text("Hoeveelheid")
                        Spacer()
                        TextField("0", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Eenheid", selection: $unit) {
                        Text("gram").tag("g")
                        Text("kilogram").tag("kg")
                        Text("pakje").tag("pak")
                        Text("liter").tag("l")
                        Text("milliliter").tag("ml")
                    }
                    
                    TextField("Opmerkingen (optioneel)", text: $notes)
                        .lineLimit(3)
                    
                    Toggle("Laag in voorraad", isOn: $isLowStock)
                }
            }
            .navigationTitle("Nieuw Ingrediënt")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Annuleer") {
                    isPresented = false
                },
                trailing: Button("Voeg Toe") {
                    let newItem = InventoryItem(
                        name: name,
                        category: category.rawValue,
                        amount: amount,
                        unit: unit,
                        isLowStock: isLowStock,
                        inStock: true,
                        notes: notes
                    )
                    inventoryManager.addIngredient(newItem)
                    isPresented = false
                }
                .disabled(name.isEmpty)
            )
        }
    }
    

}

#Preview {
    IngredientsView()
}
