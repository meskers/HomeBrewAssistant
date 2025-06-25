//
//  RecipeDetailView.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 10/06/2025.
//


import SwiftUI
import CoreData

struct RecipeDetailView: View {
    let recipe: DetailedRecipeModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingEditView = false
    @State private var showingScalingView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: iconForRecipeType(recipe.wrappedType))
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(recipe.wrappedName)
                                    .font(.title)
                                    .font(.body.weight(.bold))
                                
                                Text(recipe.wrappedType)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        if let createdAt = recipe.createdAt {
                            Text("Aangemaakt op \(createdAt, style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Recipe Stats
                    if recipe.originalGravity > 0 || recipe.finalGravity > 0 || recipe.abv > 0 {
                        RecipeStatsView(recipe: recipe)
                    }
                    
                    // Ingredients Section
                    if !recipe.ingredientsArray.isEmpty {
                        RecipeIngredientsSection(ingredients: recipe.ingredientsArray)
                    }
                    
                    // Notes Section
                    if !recipe.wrappedNotes.isEmpty {
                        NotesSection(notes: recipe.wrappedNotes)
                    }
                    
                    // Fermentation Steps
                    if !recipe.fermentationStepsArray.isEmpty {
                        FermentationSection(steps: recipe.fermentationStepsArray)
                    }
                    
                    // Action Buttons
                    ActionButtonsView(
                        onEdit: { showingEditView = true },
                        onScale: { showingScalingView = true }
                    )
                }
                .padding()
            }
            .navigationTitle("Recept Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Bewerk") {
                        showingEditView = true
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                RecipeBuilderView(recipeToEdit: recipe)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingScalingView) {
                // TODO: Implement proper conversion from DetailedRecipeModel to DetailedRecipe
                Text("Recipe Scaling - Nog niet geïmplementeerd")
                    .navigationTitle("Recept Schalen")
            }
        }
    }
    
    private func iconForRecipeType(_ type: String) -> String {
        switch type.lowercased() {
        case "beer", "bier":
            return "drop.fill"
        case "wine", "wijn":
            return "wineglass.fill"
        case "cider":
            return "applelogo"
        case "mead":
            return "honeybee.fill"
        default:
            return "flask.fill"
        }
    }
}

struct RecipeStatsView: View {
    let recipe: DetailedRecipeModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Receptgegevens")
                .font(.headline)
                .font(.body.weight(.semibold))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                if recipe.originalGravity > 0 {
                    RecipeStatCard(title: "Original Gravity", value: String(format: "%.3f", recipe.originalGravity))
                }
                
                if recipe.finalGravity > 0 {
                    RecipeStatCard(title: "Final Gravity", value: String(format: "%.3f", recipe.finalGravity))
                }
                
                if recipe.abv > 0 {
                    RecipeStatCard(title: "ABV", value: String(format: "%.1f%%", recipe.abv))
                }
                
                if recipe.bitterness > 0 {
                    RecipeStatCard(title: "IBU", value: String(format: "%.0f", recipe.bitterness))
                }
                
                if recipe.efficiency > 0 {
                    RecipeStatCard(title: "Efficiency", value: String(format: "%.0f%%", recipe.efficiency))
                }
                
                if recipe.boilTime > 0 {
                    RecipeStatCard(title: "Kooktijd", value: "\(recipe.boilTime) min")
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecipeStatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .font(.body.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct RecipeIngredientsSection: View {
    let ingredients: [Ingredient]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingrediënten (\(ingredients.count))")
                .font(.headline)
                .font(.body.weight(.semibold))
            
            LazyVStack(spacing: 8) {
                ForEach(ingredients, id: \.self) { ingredient in
                    RecipeIngredientRow(ingredient: ingredient)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecipeIngredientRow: View {
    let ingredient: Ingredient
    
    var body: some View {
        HStack {
            Image(systemName: iconForIngredientType(ingredient.wrappedType))
                .foregroundColor(colorForIngredientType(ingredient.wrappedType))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.wrappedName)
                    .font(.body)
                    .font(.body.weight(.medium))
                
                if !ingredient.wrappedTiming.isEmpty {
                    Text(ingredient.wrappedTiming)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(ingredient.wrappedAmount)
                .font(.body)
                .font(.body.weight(.semibold))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func iconForIngredientType(_ type: String) -> String {
        switch type.lowercased() {
        case "grain", "graan":
            return "leaf.fill"
        case "hop":
            return "flower.fill"
        case "yeast", "gist":
            return "bubble.middle.top.fill"
        default:
            return "circle.fill"
        }
    }
    
    private func colorForIngredientType(_ type: String) -> Color {
        switch type.lowercased() {
        case "grain", "graan":
            return .brown
        case "hop":
            return .green
        case "yeast", "gist":
            return .orange
        default:
            return .gray
        }
    }
}

struct NotesSection: View {
    let notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notities")
                .font(.headline)
                .font(.body.weight(.semibold))
            
            Text(notes)
                .font(.body)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FermentationSection: View {
    let steps: [FermentationStep]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fermentatiestappen (\(steps.count))")
                .font(.headline)
                .font(.body.weight(.semibold))
            
            LazyVStack(spacing: 8) {
                ForEach(steps, id: \.self) { step in
                    FermentationStepRow(step: step)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FermentationStepRow: View {
    let step: FermentationStep
    
    var body: some View {
        HStack {
            Image(systemName: "thermometer")
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(step.wrappedName)
                    .font(.body)
                    .font(.body.weight(.medium))
                
                if !step.wrappedDescription.isEmpty {
                    Text(step.wrappedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if step.temperature > 0 {
                    Text("\(Int(step.temperature))°C")
                        .font(.body)
                        .font(.body.weight(.semibold))
                }
                
                if step.duration > 0 {
                    Text("\(step.duration) dagen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct ActionButtonsView: View {
    let onEdit: () -> Void
    let onScale: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onEdit) {
                Label("Bewerk Recept", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button(action: onScale) {
                Label("Recept Schalen", systemImage: "plus.magnifyingglass")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let recipes = try! context.fetch(DetailedRecipeModel.fetchRequest())
    
    return RecipeDetailView(recipe: recipes.first!)
        .environment(\.managedObjectContext, context)
}