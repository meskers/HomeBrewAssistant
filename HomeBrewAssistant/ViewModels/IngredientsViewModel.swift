import SwiftUI
import Foundation

class IngredientsViewModel: ObservableObject {
    @Published var ingredients: [InventoryItem] = []
    // CLEAN APP STORE EXPERIENCE: No mock ingredients
    // Users should start with empty ingredient inventory
    
    @Published var selectedCategory: IngredientType? = nil
    @Published var searchText = ""
    
    var filteredIngredients: [InventoryItem] {
        var filtered = ingredients
        
        // Filter by category
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory.rawValue }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) 
            }
        }
        
        return filtered
    }
    
    var lowStockItems: [InventoryItem] {
        ingredients.filter { !$0.inStock }
    }
    
    func addIngredient(_ ingredient: InventoryItem) {
        ingredients.append(ingredient)
    }
    
    func deleteIngredients(at offsets: IndexSet) {
        let indicesToDelete = offsets.map { filteredIngredients[$0].id }
        ingredients.removeAll { indicesToDelete.contains($0.id) }
    }
    
    func toggleStock(for ingredient: InventoryItem) {
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            ingredients[index].inStock.toggle()
        }
    }
}
