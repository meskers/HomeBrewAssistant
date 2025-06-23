import SwiftUI

// MARK: - Simplified Ingredients View
struct SmartIngredientsView: View {
    let selectedRecipe: DetailedRecipe?
    @Binding var allRecipes: [DetailedRecipe]
    @State private var currentView: IngredientsViewMode = .inventory
    @State private var ingredients: [SimpleIngredient] = [] // Clean start - no mock data
    @State private var newIngredientName = ""
    @State private var newIngredientAmount = ""
    @State private var selectedCategory = "Graan"
    
    private let categories = ["Graan", "Hop", "Gist", "Overig"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: currentView == .inventory ? "list.clipboard.fill" : "cart.fill")
                            .foregroundColor(.blue)
                            .accessibilityLabel("Ingredients icon")
                        VStack(alignment: .leading) {
                            Text(currentView == .inventory ? "Ingrediënten Voorraad" : "Boodschappenlijst")
                                .font(.title2)
                                .fontWeight(.bold)
                            if let recipe = selectedRecipe, currentView == .inventory {
                                Text("📖 Voor recept: \(recipe.name)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .accessibilityLabel("For recipe: \(recipe.name)")
                            } else {
                                Text("Beheer je brouw ingrediënten")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Text("\(ingredients.count) items")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                            .accessibilityLabel("\(ingredients.count) ingredients")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                
                // Simple Ingredients List
                List {
                    ForEach(ingredients.grouped) { group in
                        Section(group.category) {
                            ForEach(group.items) { ingredient in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(ingredient.name)
                                            .font(.headline)
                                        Text(ingredient.amount)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\(ingredient.name), \(ingredient.amount)")
                            }
                            .onDelete { indexSet in
                                let itemsToDelete = indexSet.map { group.items[$0] }
                                ingredients.removeAll { item in
                                    itemsToDelete.contains { $0.id == item.id }
                                }
                            }
                        }
                    }
                }
                .accessibilityLabel("Ingredients list")
                
                // Add new ingredient section
                VStack(spacing: 10) {
                    HStack {
                        TextField("Ingredient naam", text: $newIngredientName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .accessibilityLabel("Ingredient name")
                        
                        TextField("Hoeveelheid", text: $newIngredientAmount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                            .accessibilityLabel("Amount")
                    }
                    
                    HStack {
                        Picker("Categorie", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .accessibilityLabel("Category")
                        
                        Button("Toevoegen") {
                            if !newIngredientName.isEmpty && !newIngredientAmount.isEmpty {
                                ingredients.append(SimpleIngredient(
                                    name: newIngredientName,
                                    category: selectedCategory,
                                    amount: newIngredientAmount
                                ))
                                newIngredientName = ""
                                newIngredientAmount = ""
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityLabel("Add ingredient")
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Supporting Types
enum IngredientsViewMode {
    case inventory
    case shopping
}

struct SimpleIngredient: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let amount: String
}

struct IngredientGroup: Identifiable {
    let id = UUID()
    let category: String
    let items: [SimpleIngredient]
}

extension Array where Element == SimpleIngredient {
    var grouped: [IngredientGroup] {
        let categorized = Dictionary(grouping: self) { $0.category }
        return categorized.map { category, items in
            IngredientGroup(category: category, items: items.sorted { $0.name < $1.name })
        }.sorted { $0.category < $1.category }
    }
}
