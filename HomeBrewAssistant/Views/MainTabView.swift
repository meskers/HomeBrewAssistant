//
//  MainTabView.swift
//  HomeBrewAssistant
//
//  Refactored for better architecture and accessibility
//  Reduced from 1849 lines to ~60 lines

import SwiftUI

struct MainTabView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedRecipeForBrewing: DetailedRecipe?
    @State private var recipes: [DetailedRecipe] = DefaultRecipesDatabase.getAllDefaultRecipes()
    
    var body: some View {
        TabView {
            // 1. RECEPTEN - Recipe management
            RecipesTabView(
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
            IngredientsView(selectedRecipeForBrewing: $selectedRecipeForBrewing)
            .tabItem {
                Label("tab.inventory".localized, systemImage: "list.clipboard.fill")
            }
            .accessibilityLabel("Ingredients tab")
            
            // 5. FOTO'S - Photo Gallery (tijdelijk uitgeschakeld)
            VStack {
                Image(systemName: "photo.stack")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                Text("Foto functie tijdelijk uitgeschakeld")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text("Wordt binnenkort toegevoegd")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Label("tab.photos".localized, systemImage: "photo.stack.fill")
            }
            .accessibilityLabel("Photos tab")
            
            // 6. MEER - Additional tools and settings
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

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}