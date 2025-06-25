import Foundation
import SwiftUI

// MARK: - Core Ingredient Type (for Recipe compatibility)
enum IngredientType: String, CaseIterable, Codable {
    case grain = "grain"
    case hop = "hop"
    case yeast = "yeast"
    case adjunct = "adjunct"
    case other = "other"
    
    var localizedName: String {
        switch self {
        case .grain: return "Mout & Granen"
        case .hop: return "Hop"
        case .yeast: return "Gist"
        case .adjunct: return "Adjuncten"
        case .other: return "Overige"
        }
    }
    
    var icon: String {
        switch self {
        case .grain: return "leaf.fill"
        case .hop: return "leaf.circle.fill"
        case .yeast: return "circle.circle.fill"
        case .adjunct: return "plus.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .grain: return .maltGold
        case .hop: return .hopGreen
        case .yeast: return .orange
        case .adjunct: return .purple
        case .other: return .gray
        }
    }
}

// MARK: - Legacy Models (for existing code compatibility)

struct InventoryItem: Identifiable, Codable {
    var id: UUID
    var name: String
    var category: String
    var amount: Double
    var unit: String
    var isLowStock: Bool
    var inStock: Bool
    var notes: String
    
    init(id: UUID = UUID(), name: String, category: String, amount: Double = 0, unit: String = "g", isLowStock: Bool = false, inStock: Bool = true, notes: String = "") {
        self.id = id
        self.name = name
        self.category = category
        self.amount = amount
        self.unit = unit
        self.isLowStock = isLowStock
        self.inStock = inStock
        self.notes = notes
    }
}

struct IngredientModel: Identifiable, Codable {
    var id: UUID
    var name: String
    var amount: String
    var type: String
    var timing: String
    var notes: String
    
    init(id: UUID = UUID(), name: String, amount: String, type: String, timing: String = "", notes: String = "") {
        self.id = id
        self.name = name
        self.amount = amount
        self.type = type
        self.timing = timing
        self.notes = notes
    }
}

// MARK: - Shopping List Models
struct ShoppingListItem: Identifiable, Codable {
    var id: UUID
    var ingredientName: String
    var requiredAmount: Double
    var estimatedPrice: Double
    var isAcquired: Bool
    var notes: String
    
    init(id: UUID = UUID(), ingredientName: String, requiredAmount: Double, estimatedPrice: Double = 0.0, isAcquired: Bool = false, notes: String = "") {
        self.id = id
        self.ingredientName = ingredientName
        self.requiredAmount = requiredAmount
        self.estimatedPrice = estimatedPrice
        self.isAcquired = isAcquired
        self.notes = notes
    }
}

struct RecipeRequirement: Identifiable {
    let id = UUID()
    let ingredientName: String
    let requiredAmount: Double
    let availableAmount: Double
    let isAvailable: Bool
}

// MARK: - Smart Inventory Manager
class SmartInventoryManager: ObservableObject {
    @Published var ingredients: [InventoryItem] = []
    @Published var shoppingList: [ShoppingListItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let ingredientsKey = "inventory_ingredients"
    private let shoppingListKey = "shopping_list"
    
    init() {
        loadInventory()
        loadShoppingList()
    }
    
    // MARK: - Inventory Management
    func addIngredient(_ ingredient: InventoryItem) {
        ingredients.append(ingredient)
        saveInventory()
    }
    
    func removeIngredient(_ ingredient: InventoryItem) {
        ingredients.removeAll { $0.id == ingredient.id }
        saveInventory()
    }
    
    func updateIngredient(_ ingredient: InventoryItem) {
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            ingredients[index] = ingredient
            saveInventory()
        }
    }
    
    func toggleStock(for ingredient: InventoryItem) {
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            ingredients[index].inStock.toggle()
            saveInventory()
        }
    }
    
    // MARK: - Recipe Analysis
    func checkRecipeRequirements(_ recipe: DetailedRecipe) -> [RecipeRequirement] {
        var requirements: [RecipeRequirement] = []
        
        for recipeIngredient in recipe.ingredients {
            // Parse the amount from the recipe ingredient
            let parsedAmount = parseIngredientAmount(recipeIngredient.amount)
            let requiredAmount = parsedAmount.value
            
            // Find matching ingredient in inventory
            let availableItem = ingredients.first { ingredient in
                ingredient.name.lowercased().contains(recipeIngredient.name.lowercased()) ||
                recipeIngredient.name.lowercased().contains(ingredient.name.lowercased())
            }
            
            let availableAmount = availableItem?.amount ?? 0.0
            let isAvailable = availableAmount >= requiredAmount && (availableItem?.inStock ?? false)
            
            let requirement = RecipeRequirement(
                ingredientName: recipeIngredient.name,
                requiredAmount: requiredAmount,
                availableAmount: availableAmount,
                isAvailable: isAvailable
            )
            
            requirements.append(requirement)
        }
        
        return requirements
    }
    
    func generateShoppingListForRecipe(_ recipe: DetailedRecipe) {
        let requirements = checkRecipeRequirements(recipe)
        var newShoppingItems: [ShoppingListItem] = []
        
        for requirement in requirements {
            if !requirement.isAvailable {
                let neededQuantity = requirement.requiredAmount - requirement.availableAmount
                let estimatedPrice = estimatePrice(for: requirement.ingredientName, quantity: neededQuantity)
                
                let shoppingItem = ShoppingListItem(
                    ingredientName: requirement.ingredientName,
                    requiredAmount: neededQuantity,
                    estimatedPrice: estimatedPrice
                )
                
                newShoppingItems.append(shoppingItem)
            }
        }
        
        // Update shopping list (remove duplicates)
        for newItem in newShoppingItems {
            if let existingIndex = shoppingList.firstIndex(where: { $0.ingredientName == newItem.ingredientName }) {
                shoppingList[existingIndex] = newItem
            } else {
                shoppingList.append(newItem)
            }
        }
        
        saveShoppingList()
    }
    
    // MARK: - Shopping List Management
    func markAsAcquired(_ item: ShoppingListItem) {
        // Determine category based on ingredient name
        let category = determineIngredientCategory(item.ingredientName)
        let defaultUnit = getDefaultUnit(for: category)
        
        // Convert amount to appropriate unit for display
        let (convertedAmount, displayUnit) = convertToDisplayUnit(item.requiredAmount, category: category)
        
        // Add to inventory
        let newInventoryItem = InventoryItem(
            name: item.ingredientName,
            category: category.rawValue,
            amount: convertedAmount,
            unit: displayUnit,
            isLowStock: false,
            inStock: true,
            notes: "Gekocht voor recept"
        )
        
        ingredients.append(newInventoryItem)
        saveInventory() // 🔧 FIX: Save inventory after adding item
        
        // Remove from shopping list
        shoppingList.removeAll { $0.id == item.id }
        saveShoppingList()
    }
    
    func removeFromShoppingList(at offsets: IndexSet) {
        shoppingList.remove(atOffsets: offsets)
        saveShoppingList()
    }
    
    func removeFromShoppingList(_ item: ShoppingListItem) {
        shoppingList.removeAll { $0.id == item.id }
        saveShoppingList()
    }
    
    // MARK: - Helper Methods
    
    /// Determine ingredient category based on name
    private func determineIngredientCategory(_ ingredientName: String) -> IngredientType {
        let lowerName = ingredientName.lowercased()
        
        if lowerName.contains("mout") || lowerName.contains("grain") || lowerName.contains("gerst") || lowerName.contains("wheat") || lowerName.contains("tarwe") {
            return .grain
        } else if lowerName.contains("hop") {
            return .hop
        } else if lowerName.contains("gist") || lowerName.contains("yeast") {
            return .yeast
        } else if lowerName.contains("suiker") || lowerName.contains("honey") || lowerName.contains("honing") || lowerName.contains("spice") || lowerName.contains("kruiden") {
            return .adjunct
        } else {
            return .other
        }
    }
    
    /// Get default unit for ingredient category
    private func getDefaultUnit(for category: IngredientType) -> String {
        switch category {
        case .grain:
            return "kg"
        case .hop:
            return "g"
        case .yeast:
            return "pak"
        case .adjunct:
            return "g"
        case .other:
            return "g"
        }
    }
    
    /// Convert amount to display-friendly unit
    private func convertToDisplayUnit(_ amountInGrams: Double, category: IngredientType) -> (amount: Double, unit: String) {
        switch category {
        case .grain:
            if amountInGrams >= 1000 {
                return (amountInGrams / 1000, "kg")
            } else {
                return (amountInGrams, "g")
            }
        case .hop:
            return (amountInGrams, "g")
        case .yeast:
            // Assume ~11g per pack
            let packs = max(1, round(amountInGrams / 11))
            return (packs, "pak")
        case .adjunct, .other:
            if amountInGrams >= 1000 {
                return (amountInGrams / 1000, "kg")
            } else {
                return (amountInGrams, "g")
            }
        }
    }
    
    private func parseIngredientAmount(_ amountString: String) -> (value: Double, unit: String) {
        let trimmed = amountString.trimmingCharacters(in: .whitespaces)
        
        // Enhanced patterns voor Nederlandse en Engelse eenheden
        let patterns = [
            (#"(\d+(?:[,\.]\d+)?)\s*(kg|kilo|kilogram)"#, "kg"),
            (#"(\d+(?:[,\.]\d+)?)\s*(g|gram|gr|grams)"#, "g"),
            (#"(\d+(?:[,\.]\d+)?)\s*(pak|pakje|package|pack)"#, "pak"),
            (#"(\d+(?:[,\.]\d+)?)\s*(l|liter|litre)"#, "l"),
            (#"(\d+(?:[,\.]\d+)?)\s*(ml|milliliter|millilitre)"#, "ml"),
            (#"(\d+(?:[,\.]\d+)?)"#, "g") // Fallback: numbers without unit assumed to be grams
        ]
        
        for (pattern, defaultUnit) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) {
                
                let valueRange = Range(match.range(at: 1), in: trimmed)!
                var valueString = String(trimmed[valueRange])
                valueString = valueString.replacingOccurrences(of: ",", with: ".")
                
                var value = Double(valueString) ?? 0.0
                var unit = defaultUnit
                
                // Als er een tweede capture group is voor de unit
                if match.numberOfRanges > 2 {
                    let unitRange = Range(match.range(at: 2), in: trimmed)!
                    unit = String(trimmed[unitRange]).lowercased()
                }
                
                // Converteer naar gram voor consistente berekening
                switch unit.lowercased() {
                case "kg", "kilo", "kilogram":
                    value = value * 1000
                    unit = "g"
                case "pak", "pakje", "package", "pack":
                    value = value * 11 // Typische gist pakje grootte
                    unit = "g"
                case "l", "liter", "litre":
                    value = value * 1000 // 1:1 voor vloeistoffen
                    unit = "ml"
                default:
                    break // Blijf bij originele waarde voor g, ml etc.
                }
                
                return (value, unit)
            }
        }
        
        return (0.0, "g")
    }
    
    private func estimatePrice(for ingredientName: String, quantity: Double) -> Double {
        // Basic price estimation based on ingredient type
        let lowerName = ingredientName.lowercased()
        
        if lowerName.contains("mout") || lowerName.contains("grain") {
            return quantity * 0.003 // €3 per kg
        } else if lowerName.contains("hop") {
            return quantity * 0.02 // €20 per kg
        } else if lowerName.contains("gist") || lowerName.contains("yeast") {
            return 3.50 // Fixed price per pack
        } else {
            return quantity * 0.005 // Default €5 per kg
        }
    }
    
    // MARK: - Persistence
    private func saveInventory() {
        if let encoded = try? JSONEncoder().encode(ingredients) {
            userDefaults.set(encoded, forKey: ingredientsKey)
        }
    }
    
    private func loadInventory() {
        if let data = userDefaults.data(forKey: ingredientsKey),
           let decoded = try? JSONDecoder().decode([InventoryItem].self, from: data) {
            ingredients = decoded
        }
    }
    
    private func saveShoppingList() {
        if let encoded = try? JSONEncoder().encode(shoppingList) {
            userDefaults.set(encoded, forKey: shoppingListKey)
        }
    }
    
    private func loadShoppingList() {
        if let data = userDefaults.data(forKey: shoppingListKey),
           let decoded = try? JSONDecoder().decode([ShoppingListItem].self, from: data) {
            shoppingList = decoded
        }
    }
}

// MARK: - Simple Ingredient (for IngredientsView)
struct SimpleIngredient: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: IngredientType
    var amount: Double
    var unit: String
    var notes: String
    var isLowStock: Bool
    
    init(id: UUID = UUID(), name: String, category: IngredientType, amount: Double = 0, unit: String = "g", notes: String = "", isLowStock: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.amount = amount
        self.unit = unit
        self.notes = notes
        self.isLowStock = isLowStock
    }
}
