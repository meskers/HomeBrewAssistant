import SwiftUI

struct InventoryCheckView: View {
    let recipe: DetailedRecipe
    @StateObject private var inventoryManager = SmartInventoryManager()
    @State private var requirements: [RecipeRequirement] = []
    @State private var showingShoppingList = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "checklist.checked")
                            .foregroundColor(.brewTheme)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text("📋 Voorraadcontrole")
                                .font(.title2)
                                .font(.body.weight(.bold))
                            Text("Recept: \(recipe.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(availableCount)/\(requirements.count)")
                                .font(.title2)
                                .font(.body.weight(.bold))
                                .foregroundColor(allIngredientsAvailable ? .green : .orange)
                            Text(allIngredientsAvailable ? "✅ Alles op voorraad" : "⚠️ Items ontbreken")
                                .font(.caption2)
                                .foregroundColor(allIngredientsAvailable ? .green : .orange)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Requirements List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(requirements) { requirement in
                            IngredientRequirementCard(requirement: requirement)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    if !missingIngredients.isEmpty {
                        Button(action: {
                            inventoryManager.generateShoppingListForRecipe(recipe)
                            showingShoppingList = true
                        }) {
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                Text("Genereer Boodschappenlijst (\(missingIngredients.count) items)")
                                    .font(.body.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    if allIngredientsAvailable {
                        Button(action: {
                            // Navigate to brewing view
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Start Brouwen")
                                    .font(.body.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sluiten") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                loadRequirements()
            }
            .sheet(isPresented: $showingShoppingList) {
                ShoppingListView(inventoryManager: inventoryManager)
            }
        }
    }
    
    private var availableCount: Int {
        requirements.filter { $0.isAvailable }.count
    }
    
    private var allIngredientsAvailable: Bool {
        !requirements.isEmpty && requirements.allSatisfy { $0.isAvailable }
    }
    
    private var missingIngredients: [RecipeRequirement] {
        requirements.filter { !$0.isAvailable }
    }
    
    private func loadRequirements() {
        requirements = inventoryManager.checkRecipeRequirements(recipe)
    }
}

struct IngredientRequirementCard: View {
    let requirement: RecipeRequirement
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            Image(systemName: requirement.isAvailable ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(requirement.isAvailable ? .green : .orange)
                .font(.title2)
            
            // Ingredient Info
            VStack(alignment: .leading, spacing: 4) {
                Text(requirement.ingredientName)
                    .font(.headline)
                    .font(.body.weight(.medium))
                
                HStack {
                    Text("Nodig: \(formatAmount(requirement.requiredAmount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Op voorraad: \(formatAmount(requirement.availableAmount))")
                        .font(.caption)
                        .foregroundColor(requirement.isAvailable ? .green : .orange)
                }
            }
            
            Spacer()
            
            // Status Badge
            Text(requirement.isAvailable ? "✅" : "❌")
                .font(.title3)
        }
        .padding()
        .background(Color.primaryCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(requirement.isAvailable ? Color.green.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount == 0 {
            return "0"
        } else if amount < 1 {
            return String(format: "%.1f g", amount)
        } else if amount < 1000 {
            return String(format: "%.0f g", amount)
        } else {
            return String(format: "%.1f kg", amount / 1000)
        }
    }
}

struct ShoppingListView: View {
    @ObservedObject var inventoryManager: SmartInventoryManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text("🛒 Boodschappenlijst")
                                .font(.title2)
                                .font(.body.weight(.bold))
                            Text("Items om te kopen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("€\(String(format: "%.2f", totalCost))")
                                .font(.title2)
                                .font(.body.weight(.bold))
                                .foregroundColor(.green)
                            Text("Totale kosten")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Shopping List
                if inventoryManager.shoppingList.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("Geen items om te kopen")
                            .font(.title2)
                            .font(.body.weight(.bold))
                        Text("Alle ingrediënten zijn op voorraad")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(inventoryManager.shoppingList) { item in
                            ShoppingListItemCard(item: item, inventoryManager: inventoryManager)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sluiten") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !inventoryManager.shoppingList.isEmpty {
                        Button("Wis Alles") {
                            inventoryManager.shoppingList.removeAll()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private var totalCost: Double {
        inventoryManager.shoppingList.reduce(0) { $0 + $1.estimatedPrice }
    }
}

struct ShoppingListItemCard: View {
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
                    .font(.body.weight(.medium))
                
                Text("Hoeveelheid: \(formatQuantity(item.requiredAmount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Price and Action
            VStack(alignment: .trailing, spacing: 4) {
                Text("€\(String(format: "%.2f", item.estimatedPrice))")
                    .font(.headline)
                    .font(.body.weight(.bold))
                    .foregroundColor(.green)
                
                Button("✓ Gekocht") {
                    inventoryManager.markAsAcquired(item)
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
