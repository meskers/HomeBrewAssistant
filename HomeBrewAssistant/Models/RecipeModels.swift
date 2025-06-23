import SwiftUI
import Foundation

// MARK: - Local Recipe Models (for Default Recipes and AI Generation)

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
