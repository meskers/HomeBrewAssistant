import SwiftUI
import Foundation

// MARK: - Recipe Ingredient Model
struct IngredientModel: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: String
    var amount: String
    var timing: String
    
    init(id: UUID = UUID(), name: String, type: String, amount: String, timing: String) {
        self.id = id
        self.name = name
        self.type = type
        self.amount = amount
        self.timing = timing
    }
}

// MARK: - Inventory Item Model
struct InventoryItem: Identifiable {
    let id = UUID()
    var name: String
    var category: IngredientType
    var amount: String
    var inStock: Bool
}

// MARK: - Ingredient Category
enum IngredientType: String, CaseIterable, Codable {
    case grain = "Grain"
    case hop = "Hop"
    case yeast = "Yeast"
    case adjunct = "Adjunct"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .grain:
            return "leaf.fill"
        case .hop:
            return "flower.fill"
        case .yeast:
            return "bubble.left.fill"
        case .adjunct:
            return "plus.circle.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
}

struct IngredientCategory: Identifiable {
    let id = UUID()
    let type: IngredientType
    var ingredients: [IngredientModel]
}

extension IngredientModel {
    static var example: IngredientModel {
        IngredientModel(
            name: "Pale Malt",
            type: "Grain",
            amount: "5.0 kg",
            timing: "Mash"
        )
    }
    
    static var examples: [IngredientModel] {
        [
            IngredientModel(name: "Pale Malt", type: "Grain", amount: "5.0 kg", timing: "Mash"),
            IngredientModel(name: "Cascade Hops", type: "Hop", amount: "50 g", timing: "60 min"),
            IngredientModel(name: "Safale US-05", type: "Yeast", amount: "11.5 g", timing: "Pitch")
        ]
    }
} 