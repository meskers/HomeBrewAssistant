import SwiftUI

struct DetailedRecipeView: View {
    let recipe: DetailedRecipe
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @StateObject private var photoManager = PhotoManager.shared
    @State private var showingScalingView = false
    @State private var showingBrewingView = false
    @State private var showingInventoryCheck = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerSection
                    
                    // Recipe Statistics
                    recipeStatsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Ingredients
                    ingredientsSection
                    
                    // Instructions
                    instructionsSection
                    
                    // Notes
                    if !recipe.notes.isEmpty {
                        notesSection
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(recipe.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sluiten") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.brewTheme)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schaal") {
                        showingScalingView = true
                    }
                    .foregroundColor(.brewTheme)
                }
            }
            .sheet(isPresented: $showingScalingView) {
                RecipeScalingView(recipe: recipe)
                    .environmentObject(LocalizationManager.shared)
            }
            .sheet(isPresented: $showingBrewingView) {
                EnhancedBrewingView(selectedRecipe: recipe)
            }
            .sheet(isPresented: $showingInventoryCheck) {
                InventoryCheckView(recipe: recipe)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: difficultyIcon)
                    .font(.system(size: 40))
                    .foregroundColor(difficultyColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text(recipe.style)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        
                    HStack {
                        difficultyBadge
                        brewTimeBadge
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("⚡ Snelle Acties")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                // Recipe Scaling Button
                Button(action: {
                    showingScalingView = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Schaal Recept")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                            
                            Text("Pas batch grootte aan")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(.brewTheme)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Start Brewing Button
                Button(action: {
                    HapticManager.shared.success()
                    withAnimation(.premiumSlide) {
                        showingInventoryCheck = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Start Brouwen")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                            
                            Text("Begin brouwsessie")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(.green)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Recipe Stats Section
    private var recipeStatsSection: some View {
        VStack(spacing: 12) {
            Text("�� Receptspecificaties")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                statCard(icon: "🎯", title: "ABV", value: "\(String(format: "%.1f", recipe.abv))%")
                statCard(icon: "🌿", title: "IBU", value: "\(recipe.ibu)")
                statCard(icon: "⏱️", title: "Brouwtijd", value: "\(recipe.brewTime) min")
                statCard(icon: "🎓", title: "Moeilijkheid", value: recipe.difficulty.rawValue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func statCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title2)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body.weight(.semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Ingredients Section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🌾 Ingrediënten")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach([IngredientType.grain, .hop, .yeast, .adjunct, .other], id: \.self) { type in
                    if let ingredients = groupedIngredients[type] {
                        ingredientTypeSection(type: type, ingredients: ingredients)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var groupedIngredients: [IngredientType: [RecipeIngredient]] {
        Dictionary(grouping: recipe.ingredients, by: { $0.type })
    }
    
    private func ingredientTypeSection(type: IngredientType, ingredients: [RecipeIngredient]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ingredientTypeTitle(type))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.brewTheme)
            
            ForEach(ingredients, id: \.name) { ingredient in
                HStack {
                    Text("•")
                        .foregroundColor(.brewTheme)
                    
                    Text(ingredient.name)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(ingredient.amount)
                            .font(.body.weight(.medium))
                            .foregroundColor(.primary)
                        
                        if !ingredient.timing.isEmpty {
                            Text(ingredient.timing)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func ingredientTypeTitle(_ type: IngredientType) -> String {
        switch type {
        case .grain:
            return "Mout & Granen"
        case .hop:
            return "Hop"
        case .yeast:
            return "Gist"
        case .adjunct:
            return "Adjuncten"
        case .other:
            return "Overige"
        }
    }
    
    // MARK: - Instructions Section
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📋 Bereidingswijze")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.body.weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(.brewTheme)
                            .clipShape(Circle())
                        
                        Text(instruction)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📝 Opmerkingen")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(recipe.notes)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helper Properties
    private var difficultyIcon: String {
        switch recipe.difficulty {
        case .beginner:
            return "graduationcap"
        case .intermediate:
            return "brain"
        case .advanced:
            return "flask"
        }
    }
    
    private var difficultyColor: Color {
        switch recipe.difficulty {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        }
    }
    
    private var difficultyBadge: some View {
        Text(recipe.difficulty.rawValue)
            .font(.caption.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor)
            .cornerRadius(6)
    }
    
    private var brewTimeBadge: some View {
        Text("\(recipe.brewTime) min")
            .font(.caption.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.brewTheme)
            .cornerRadius(6)
    }
}

#Preview {
    let sampleRecipe = DetailedRecipe(
        name: "AI Generated IPA",
        style: "American IPA",
        abv: 6.2,
        ibu: 55,
        difficulty: .intermediate,
        brewTime: 300,
        ingredients: [
            RecipeIngredient(name: "Pale Malt", amount: "4.5 kg", type: .grain, timing: "Maischen"),
            RecipeIngredient(name: "Crystal Malt", amount: "0.5 kg", type: .grain, timing: "Maischen"),
            RecipeIngredient(name: "Centennial", amount: "30 g", type: .hop, timing: "60 min"),
            RecipeIngredient(name: "Citra", amount: "25 g", type: .hop, timing: "15 min"),
            RecipeIngredient(name: "US-05", amount: "1 pak", type: .yeast, timing: "Fermentatie")
        ],
        instructions: [
            "Verwarm water naar 67°C",
            "Maisch 60 minuten",
            "Kook 60 minuten met hop toevoegingen",
            "Koel naar 18°C en voeg gist toe",
            "Fermenteer 10-14 dagen"
        ],
        notes: "🤖 AI Generated Recipe\n\nEen moderne Amerikaanse IPA met citrus hop karakter."
    )
    
    DetailedRecipeView(recipe: sampleRecipe)
}
