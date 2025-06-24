import SwiftUI
import UniformTypeIdentifiers

// MARK: - Recipes Tab View
struct RecipesTabView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Binding var selectedRecipeForBrewing: DetailedRecipe?
    @Binding var recipes: [DetailedRecipe]
    @State private var showingAddRecipe = false
    @State private var selectedRecipe: DetailedRecipe?
    @State private var selectedRecipeForScaling: DetailedRecipe?
    @State private var searchText = ""
    @State private var showingXMLImport = false
    @State private var showingAbout = false
    @State private var showingBeerXMLImportExport = false
    @State private var showingAIGenerator = false
    
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
                // Header in brouwtracker style
                RecipeHeaderView(
                    selectedRecipeForBrewing: selectedRecipeForBrewing,
                    recipeCount: filteredRecipes.count
                )
                
                // Search bar
                RecipeSearchBar(searchText: $searchText)
                
                // Recipe List
                RecipeListContent(
                    filteredRecipes: filteredRecipes,
                    selectedRecipe: $selectedRecipe,
                    selectedRecipeForScaling: $selectedRecipeForScaling,
                    selectedRecipeForBrewing: $selectedRecipeForBrewing,
                    deleteAction: deleteRecipe
                )
                
                // Action Buttons
                RecipeActionButtons(
                    showingAIGenerator: $showingAIGenerator,
                    showingAddRecipe: $showingAddRecipe,
                    showingXMLImport: $showingXMLImport
                )
            }
            .navigationBarHidden(false)
            .navigationTitle("HomeBrewAssistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingBeerXMLImportExport = true
                    } label: {
                        Image(systemName: "square.and.arrow.up.on.square")
                            .foregroundColor(.brewTheme)
                            .accessibilityLabel("Import/Export BeerXML")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // AI Recipe Generator Button
                        Button(action: {
                            print("🤖 AI Generator button tapped!"); showingAIGenerator = true; print("🤖 State set to: \(showingAIGenerator)")
                        }) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.purple)
                                .accessibilityLabel("AI Recipe Generator")
                        }
                        
                        Button {
                            showingAbout = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.brewTheme)
                                .accessibilityLabel("About")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
                    .environmentObject(localizationManager)
            }
            .sheet(isPresented: $showingBeerXMLImportExport) {
                BeerXMLImportExportView(recipes: $recipes)
                    .environmentObject(localizationManager)
            }
            .sheet(isPresented: $showingXMLImport) {
                BeerXMLImportExportView(recipes: $recipes)
                    .environmentObject(localizationManager)
            }
            .sheet(item: $selectedRecipe) { recipe in
                SimpleRecipeDetailView(recipe: recipe)
            }
            .sheet(item: $selectedRecipeForScaling) { recipe in
                RecipeScalingView(recipe: recipe, originalBatchSize: 23.0)
            .sheet(isPresented: $showingAIGenerator) {
                AIRecipeGeneratorView(recipes: $recipes)
            }
            .sheet(isPresented: $showingAddRecipe) {
                RecipeBuilderView()
            }            }
            .sheet(isPresented: $showingAddRecipe) {
                RecipeBuilderView()
            }
        }
        .accessibilityElement(children: .contain)
    }
    
    private func deleteRecipe(at offsets: IndexSet) {
        recipes.remove(atOffsets: offsets)
    }
}

// MARK: - Recipe Header Component
struct RecipeHeaderView: View {
    let selectedRecipeForBrewing: DetailedRecipe?
    let recipeCount: Int
    
    var body: some View {
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
                Text("recipes.count".localized(with: recipeCount))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primaryCard)
                    .cornerRadius(8)
                    .accessibilityLabel("Recipe count: \(recipeCount)")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top)
    }
}

// MARK: - Search Bar Component
struct RecipeSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
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
    }
}

// MARK: - Recipe List Content
struct RecipeListContent: View {
    let filteredRecipes: [DetailedRecipe]
    @Binding var selectedRecipe: DetailedRecipe?
    @Binding var selectedRecipeForScaling: DetailedRecipe?
    @Binding var selectedRecipeForBrewing: DetailedRecipe?
    let deleteAction: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(filteredRecipes) { recipe in
                VStack(alignment: .leading, spacing: 8) {
                    SimpleRecipeRowView(recipe: recipe)
                        .onTapGesture {
                            selectedRecipe = recipe
                        }
                    
                    RecipeActionRow(
                        recipe: recipe,
                        selectedRecipe: $selectedRecipe,
                        selectedRecipeForScaling: $selectedRecipeForScaling,
                        selectedRecipeForBrewing: $selectedRecipeForBrewing
                    )
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: deleteAction)
        }
        .accessibilityLabel("Recipe list")
    }
}

// MARK: - Recipe Action Row
struct RecipeActionRow: View {
    let recipe: DetailedRecipe
    @Binding var selectedRecipe: DetailedRecipe?
    @Binding var selectedRecipeForScaling: DetailedRecipe?
    @Binding var selectedRecipeForBrewing: DetailedRecipe?
    
    var body: some View {
        HStack {
            Button("📖 \("recipes.details".localized)") {
                selectedRecipe = recipe
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .accessibilityLabel("View recipe details for \(recipe.name)")
            
            Button("📏 Schaal") {
                selectedRecipeForScaling = recipe
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .accessibilityLabel("Scale recipe \(recipe.name)")
            
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
}

// MARK: - Recipe Action Buttons
struct RecipeActionButtons: View {
    @Binding var showingAIGenerator: Bool
    @Binding var showingAddRecipe: Bool
    @Binding var showingXMLImport: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 15) {
                Button("🤖 AI Generator") {
                    print("🤖 AI Generator button tapped!"); showingAIGenerator = true; print("🤖 State set to: \(showingAIGenerator)")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .tint(.purple)
                .accessibilityLabel("Open AI Recipe Generator")
                
                Button("recipes.add".localized) {
                    showingAddRecipe = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Add new recipe")
            }
            
            Button("📥 \("recipes.import".localized)") {
                showingXMLImport = true
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Import recipes from BeerXML")
        }
        .padding()
    }
} 