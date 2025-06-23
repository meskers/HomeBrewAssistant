//
//  MainTabView.swift
//  HomeBrewAssistant
//
//  Refactored for better architecture and accessibility
//  Reduced from 1849 lines to ~150 lines

import SwiftUI

struct MainTabView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedRecipeForBrewing: DetailedRecipe?
    @State private var recipes: [DetailedRecipe] = DefaultRecipesDatabase.getAllDefaultRecipes()
    
    var body: some View {
        TabView {
            // 1. RECEPTEN - Recipe management
            SimpleRecipeListView(
                selectedRecipeForBrewing: $selectedRecipeForBrewing,
                recipes: $recipes
            )
            .tabItem {
                Label("tab.recipes".localized, systemImage: "book.closed.fill")
            }
            .accessibilityLabel("Recipes tab")
            
            // 2. BROUWEN - Brewing process
            EnhancedBrewingView(selectedRecipe: selectedRecipeForBrewing)
                .tabItem {
                    Label("tab.brewing".localized, systemImage: "timer.circle.fill")
                }
                .accessibilityLabel("Brewing tab")
            
            // 3. CALCULATORS - Brewing calculators
            CalculatorsView()
                .tabItem {
                    Label("tab.calculators".localized, systemImage: "function")
                }
                .accessibilityLabel("Calculators tab")
            
            // 4. INGREDIËNTEN - Inventory management
            SmartIngredientsView(
                selectedRecipe: selectedRecipeForBrewing,
                allRecipes: $recipes
            )
            .tabItem {
                Label("tab.inventory".localized, systemImage: "list.clipboard.fill")
            }
            .accessibilityLabel("Ingredients tab")
            
            // 5. MEER - Additional tools and settings
            MoreView(
                selectedRecipeForBrewing: $selectedRecipeForBrewing,
                recipes: $recipes
            )
            .tabItem {
                Label("tab.more".localized, systemImage: "ellipsis.circle.fill")
            }
            .accessibilityLabel("More tab")
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Simple Recipe List View (Simplified)
struct SimpleRecipeListView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Binding var selectedRecipeForBrewing: DetailedRecipe?
    @Binding var recipes: [DetailedRecipe]
    @State private var showingAddRecipe = false
    @State private var selectedRecipe: DetailedRecipe?
    @State private var searchText = ""
    
    var filteredRecipes: [DetailedRecipe] {
        if searchText.isEmpty {
            return recipes
        } else {
            return recipes.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(searchText) ||
                recipe.style.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.brewTheme)
                        VStack(alignment: .leading) {
                            Text("recipes.title".localized)
                                .font(.title2)
                                .fontWeight(.bold)
                            if let recipe = selectedRecipeForBrewing {
                                Text("🍺 \("recipes.selected".localized): \(recipe.name)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .accessibilityLabel("Selected recipe for brewing: \(recipe.name)")
                            } else {
                                Text("recipes.select.instruction".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Text("recipes.count".localized(with: filteredRecipes.count))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primaryCard)
                            .cornerRadius(8)
                            .accessibilityLabel("Recipe count: \(filteredRecipes.count)")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("recipes.search.placeholder".localized, text: $searchText)
                        .accessibilityLabel("Search recipes")
                        .accessibilityHint("Enter recipe name or beer style to filter")
                }
                .padding()
                .background(Color.primaryCard)
                .cornerRadius(10)
                .padding()
                
                // Recipe List
                List {
                    ForEach(filteredRecipes) { recipe in
                        VStack(alignment: .leading, spacing: 8) {
                            SimpleRecipeRowView(recipe: recipe)
                                .onTapGesture {
                                    selectedRecipe = recipe
                                }
                            
                            HStack {
                                Button("📖 \("recipes.details".localized)") {
                                    selectedRecipe = recipe
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .accessibilityLabel("View recipe details for \(recipe.name)")
                                
                                Spacer()
                                
                                Button("🍺 \("recipes.use.for.brewing".localized)") {
                                    selectedRecipeForBrewing = recipe
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                                .accessibilityLabel("Use \(recipe.name) for brewing")
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteRecipe)
                }
                .accessibilityLabel("Recipe list")
                
                // Add Recipe Button
                Button("recipes.add".localized) {
                    showingAddRecipe = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding()
                .accessibilityLabel("Add new recipe")
            }
            .navigationBarHidden(false)
            .navigationTitle("HomeBrewAssistant")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddRecipe) {
                RecipeBuilderView()
            }
            .sheet(item: $selectedRecipe) { recipe in
                SimpleRecipeDetailView(recipe: recipe)
            }
        }
        .accessibilityElement(children: .contain)
    }
    
    private func deleteRecipe(at offsets: IndexSet) {
        recipes.remove(atOffsets: offsets)
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
