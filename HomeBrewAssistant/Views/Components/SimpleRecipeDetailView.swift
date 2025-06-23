import SwiftUI

// MARK: - Simple Recipe Detail View
struct SimpleRecipeDetailView: View {
    let recipe: DetailedRecipe
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Recipe header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .accessibilityLabel("Recipe: \(recipe.name)")
                        
                        Text(recipe.style)
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Label(String(format: "%.1f%%", recipe.abv), systemImage: "drop.fill")
                                .accessibilityLabel("Alcohol by volume: \(String(format: "%.1f", recipe.abv)) percent")
                            Label("\(recipe.ibu)", systemImage: "leaf.fill")
                                .accessibilityLabel("IBU: \(recipe.ibu)")
                            Label("\(recipe.brewTime) min", systemImage: "clock.fill")
                                .accessibilityLabel("Brew time: \(recipe.brewTime) minutes")
                        }
                        .font(.subheadline)
                        .foregroundColor(.brewTheme)
                    }
                    
                    Divider()
                    
                    // Recipe details
                    if !recipe.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text(recipe.notes)
                                .font(.body)
                        }
                        .accessibilityElement(children: .combine)
                    }
                    
                    if !recipe.ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            ForEach(recipe.ingredients) { ingredient in
                                HStack {
                                    Text("•")
                                    Text("\(ingredient.name) - \(ingredient.amount)")
                                    Spacer()
                                }
                                .font(.body)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Ingredients list")
                    }
                    
                    if !recipe.instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instructions")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                                HStack(alignment: .top) {
                                    Text("\(index + 1).")
                                        .fontWeight(.medium)
                                    Text(instruction)
                                        .font(.body)
                                }
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                .padding()
            }
            .navigationTitle("Recipe Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Close recipe details")
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}
