import SwiftUI
import Foundation

class IngredientsViewModel: ObservableObject {
    @Published var ingredients: [InventoryItem] = [
        InventoryItem(name: "Pilsner Malt", category: .grain, amount: "5 kg", inStock: true),
        InventoryItem(name: "Munich Malt", category: .grain, amount: "2 kg", inStock: true),
        InventoryItem(name: "Cascade Hop", category: .hop, amount: "100 g", inStock: false),
        InventoryItem(name: "Centennial Hop", category: .hop, amount: "50 g", inStock: true),
        InventoryItem(name: "SafAle US-05", category: .yeast, amount: "2 pakjes", inStock: true),
        InventoryItem(name: "Irish Moss", category: .other, amount: "10 g", inStock: true)
    ]
    
    @Published var selectedCategory: IngredientType? = nil
    @Published var searchText = ""
    
    var filteredIngredients: [InventoryItem] {
        var filtered = ingredients
        
        // Filter by category
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
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

 