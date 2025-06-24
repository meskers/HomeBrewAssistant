import SwiftUI
import Foundation

// MARK: - Local Recipe Models (for Default Recipes and AI Generation)

struct DetailedRecipe: Identifiable, Equatable {
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
    
    static func == (lhs: DetailedRecipe, rhs: DetailedRecipe) -> Bool {
        return lhs.id == rhs.id
    }
}

struct RecipeIngredient: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let amount: String
    let type: IngredientType
    let timing: String
    
    static func == (lhs: RecipeIngredient, rhs: RecipeIngredient) -> Bool {
        return lhs.id == rhs.id
    }
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
