import SwiftUI

// MARK: - Recipe Row Components

struct SimpleRecipeRowView: View {
    let recipe: DetailedRecipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(recipe.name)
                    .font(.headline)
                    .font(.body.weight(.bold))
                    .accessibilityLabel("Recipe name: \(recipe.name)")
                Spacer()
                DifficultyBadge(difficulty: recipe.difficulty)
            }
            
            Text(recipe.style)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .accessibilityLabel("Beer style: \(recipe.style)")
            
            HStack {
                Label(String(format: "%.1f%%", recipe.abv), systemImage: "drop.fill")
                    .accessibilityLabel("Alcohol by volume: \(String(format: "%.1f", recipe.abv)) percent")
                Label("\(recipe.ibu)", systemImage: "leaf.fill")
                    .accessibilityLabel("IBU: \(recipe.ibu)")
                Label("\(recipe.brewTime) min", systemImage: "clock.fill")
                    .accessibilityLabel("Brew time: \(recipe.brewTime) minutes")
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.brewTheme)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

struct DifficultyBadge: View {
    let difficulty: RecipeDifficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .font(.body.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(difficulty.color.opacity(0.2))
            .foregroundColor(difficulty.color)
            .cornerRadius(8)
            .accessibilityLabel("Difficulty: \(difficulty.rawValue)")
    }
}
