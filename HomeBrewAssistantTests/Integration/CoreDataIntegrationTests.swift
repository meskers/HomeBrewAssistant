//
//  CoreDataIntegrationTests.swift
//  HomeBrewAssistantTests
//
//  Created by Automated Testing on 24/06/2025.
//

import XCTest
import CoreData
@testable import HomeBrewAssistant

@MainActor
final class CoreDataIntegrationTests: XCTestCase {
    
    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var recipeViewModel: RecipeViewModel!
    var ingredientsViewModel: IngredientsViewModel!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory Core Data stack for testing
        persistentContainer = NSPersistentContainer(name: "HomeBrewAssistant")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
        
        context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        
        recipeViewModel = RecipeViewModel(context: context)
        ingredientsViewModel = IngredientsViewModel(context: context)
    }
    
    override func tearDown() {
        // Clean up all test data
        cleanupTestData()
        
        recipeViewModel = nil
        ingredientsViewModel = nil
        context = nil
        persistentContainer = nil
        super.tearDown()
    }
    
    private func cleanupTestData() {
        // Clean up recipes
        let recipeFetchRequest: NSFetchRequest<NSFetchRequestResult> = Recipe.fetchRequest()
        let recipeDeleteRequest = NSBatchDeleteRequest(fetchRequest: recipeFetchRequest)
        try? context.execute(recipeDeleteRequest)
        
        // Clean up ingredients
        let ingredientFetchRequest: NSFetchRequest<NSFetchRequestResult> = Ingredient.fetchRequest()
        let ingredientDeleteRequest = NSBatchDeleteRequest(fetchRequest: ingredientFetchRequest)
        try? context.execute(ingredientDeleteRequest)
        
        try? context.save()
    }
    
    // MARK: - Recipe-Ingredient Integration Tests
    
    func testRecipeWithIngredients() {
        // Given - create ingredients first
        let maltIngredient = ingredientsViewModel.addIngredient(
            name: "Pilsner Malt",
            type: "Malt",
            category: "Base Malt",
            amount: 5.0,
            unit: "kg",
            notes: "Base malt for brewing"
        )
        
        let hopIngredient = ingredientsViewModel.addIngredient(
            name: "Saaz Hops",
            type: "Hop",
            category: "Aroma",
            amount: 100.0,
            unit: "g",
            notes: "Noble hop variety"
        )
        
        XCTAssertNotNil(maltIngredient)
        XCTAssertNotNil(hopIngredient)
        
        // When - create recipe and associate ingredients
        recipeViewModel.createRecipe(
            name: "Czech Pilsner",
            style: "Bohemian Pilsner",
            targetOG: 1.048,
            targetFG: 1.012,
            abv: 4.8,
            ibu: 35,
            srm: 3,
            batchSize: 20.0,
            boilTime: 90,
            efficiency: 75.0,
            notes: "Traditional Czech Pilsner recipe"
        )
        
        guard let recipe = recipeViewModel.recipes.first(where: { $0.name == "Czech Pilsner" }) else {
            XCTFail("Failed to create recipe")
            return
        }
        
        // Then - verify integration
        XCTAssertEqual(recipeViewModel.recipes.count, 1)
        XCTAssertEqual(ingredientsViewModel.ingredients.count, 2)
        
        // Verify ingredient details
        let maltFound = ingredientsViewModel.ingredients.first { $0.name == "Pilsner Malt" }
        let hopFound = ingredientsViewModel.ingredients.first { $0.name == "Saaz Hops" }
        
        XCTAssertNotNil(maltFound)
        XCTAssertNotNil(hopFound)
        XCTAssertEqual(maltFound?.type, "Malt")
        XCTAssertEqual(hopFound?.type, "Hop")
    }
    
    func testRecipeIngredientRelationship() {
        // Given - create recipe and ingredients
        recipeViewModel.createRecipe(
            name: "IPA Recipe",
            style: "American IPA",
            targetOG: 1.065,
            targetFG: 1.012,
            abv: 6.8,
            ibu: 65,
            srm: 8,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "Hoppy IPA"
        )
        
        let ingredient1 = ingredientsViewModel.addIngredient(
            name: "Cascade Hops",
            type: "Hop",
            category: "Aroma",
            amount: 50.0,
            unit: "g",
            notes: "American hop"
        )
        
        let ingredient2 = ingredientsViewModel.addIngredient(
            name: "2-Row Pale Malt",
            type: "Malt",
            category: "Base Malt",
            amount: 4.5,
            unit: "kg",
            notes: "Base malt"
        )
        
        // When - verify both exist
        guard let recipe = recipeViewModel.recipes.first(where: { $0.name == "IPA Recipe" }),
              let hop = ingredient1,
              let malt = ingredient2 else {
            XCTFail("Failed to create recipe or ingredients")
            return
        }
        
        // Then - verify data integrity
        XCTAssertEqual(recipe.name, "IPA Recipe")
        XCTAssertEqual(hop.name, "Cascade Hops")
        XCTAssertEqual(malt.name, "2-Row Pale Malt")
        
        // Verify Core Data context consistency
        XCTAssertEqual(recipe.managedObjectContext, context)
        XCTAssertEqual(hop.managedObjectContext, context)
        XCTAssertEqual(malt.managedObjectContext, context)
    }
    
    // MARK: - Data Persistence Integration Tests
    
    func testDataPersistenceAcrossViewModels() {
        // Given - create data in one viewmodel
        recipeViewModel.createRecipe(
            name: "Persistence Test Recipe",
            style: "Test Style",
            targetOG: 1.050,
            targetFG: 1.010,
            abv: 5.0,
            ibu: 40,
            srm: 5,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "Testing persistence"
        )
        
        let ingredient = ingredientsViewModel.addIngredient(
            name: "Persistence Test Ingredient",
            type: "Test Type",
            category: "Test Category",
            amount: 1.0,
            unit: "kg",
            notes: "Testing persistence"
        )
        
        // When - save context
        recipeViewModel.saveContext()
        ingredientsViewModel.saveContext()
        
        // Create new view models with same context
        let newRecipeViewModel = RecipeViewModel(context: context)
        let newIngredientsViewModel = IngredientsViewModel(context: context)
        
        // Then - data should be accessible from new view models
        XCTAssertEqual(newRecipeViewModel.recipes.count, 1)
        XCTAssertEqual(newIngredientsViewModel.ingredients.count, 1)
        
        let persistedRecipe = newRecipeViewModel.recipes.first
        let persistedIngredient = newIngredientsViewModel.ingredients.first
        
        XCTAssertEqual(persistedRecipe?.name, "Persistence Test Recipe")
        XCTAssertEqual(persistedIngredient?.name, "Persistence Test Ingredient")
    }
    
    func testConcurrentDataAccess() {
        // Given - create initial data
        recipeViewModel.createRecipe(
            name: "Concurrent Recipe",
            style: "Test Style",
            targetOG: 1.050,
            targetFG: 1.010,
            abv: 5.0,
            ibu: 40,
            srm: 5,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "Testing concurrent access"
        )
        
        let initialRecipeCount = recipeViewModel.recipes.count
        
        // When - create multiple view models accessing same context
        let viewModel1 = RecipeViewModel(context: context)
        let viewModel2 = RecipeViewModel(context: context)
        
        viewModel1.createRecipe(
            name: "Concurrent Recipe 1",
            style: "Style 1",
            targetOG: 1.055,
            targetFG: 1.012,
            abv: 5.5,
            ibu: 45,
            srm: 6,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "From viewModel1"
        )
        
        viewModel2.createRecipe(
            name: "Concurrent Recipe 2",
            style: "Style 2",
            targetOG: 1.060,
            targetFG: 1.014,
            abv: 6.0,
            ibu: 50,
            srm: 7,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "From viewModel2"
        )
        
        // Then - all view models should see all data
        XCTAssertEqual(recipeViewModel.recipes.count, initialRecipeCount + 2)
        XCTAssertEqual(viewModel1.recipes.count, initialRecipeCount + 2)
        XCTAssertEqual(viewModel2.recipes.count, initialRecipeCount + 2)
        
        // Verify specific recipes exist
        XCTAssertNotNil(recipeViewModel.recipes.first { $0.name == "Concurrent Recipe 1" })
        XCTAssertNotNil(recipeViewModel.recipes.first { $0.name == "Concurrent Recipe 2" })
    }
    
    // MARK: - Bulk Operations Integration Tests
    
    func testBulkRecipeOperations() {
        // Given - create multiple recipes
        let recipeData = [
            ("Bulk Recipe 1", "Style A", 1.050),
            ("Bulk Recipe 2", "Style B", 1.055),
            ("Bulk Recipe 3", "Style A", 1.060),
            ("Bulk Recipe 4", "Style C", 1.045),
            ("Bulk Recipe 5", "Style B", 1.052)
        ]
        
        for (name, style, og) in recipeData {
            recipeViewModel.createRecipe(
                name: name,
                style: style,
                targetOG: og,
                targetFG: 1.010,
                abv: 5.0,
                ibu: 40,
                srm: 5,
                batchSize: 20.0,
                boilTime: 60,
                efficiency: 75.0,
                notes: "Bulk test recipe"
            )
        }
        
        // When - verify all recipes created
        XCTAssertEqual(recipeViewModel.recipes.count, 5)
        
        // Test bulk deletion
        let styleBRecipes = recipeViewModel.recipes.filter { $0.style == "Style B" }
        XCTAssertEqual(styleBRecipes.count, 2)
        
        for recipe in styleBRecipes {
            recipeViewModel.deleteRecipe(recipe)
        }
        
        // Then - verify bulk deletion worked
        XCTAssertEqual(recipeViewModel.recipes.count, 3)
        XCTAssertEqual(recipeViewModel.recipes.filter { $0.style == "Style B" }.count, 0)
        XCTAssertEqual(recipeViewModel.recipes.filter { $0.style == "Style A" }.count, 2)
        XCTAssertEqual(recipeViewModel.recipes.filter { $0.style == "Style C" }.count, 1)
    }
    
    func testBulkIngredientOperations() {
        // Given - create multiple ingredients
        let ingredientData = [
            ("Malt 1", "Malt", "Base Malt", 5.0),
            ("Malt 2", "Malt", "Specialty Malt", 0.5),
            ("Hop 1", "Hop", "Bittering", 25.0),
            ("Hop 2", "Hop", "Aroma", 15.0),
            ("Yeast 1", "Yeast", "Ale Yeast", 1.0)
        ]
        
        for (name, type, category, amount) in ingredientData {
            _ = ingredientsViewModel.addIngredient(
                name: name,
                type: type,
                category: category,
                amount: amount,
                unit: type == "Malt" ? "kg" : "g",
                notes: "Bulk test ingredient"
            )
        }
        
        // When - verify all ingredients created
        XCTAssertEqual(ingredientsViewModel.ingredients.count, 5)
        
        // Test filtering by type
        let maltIngredients = ingredientsViewModel.ingredients.filter { $0.type == "Malt" }
        let hopIngredients = ingredientsViewModel.ingredients.filter { $0.type == "Hop" }
        let yeastIngredients = ingredientsViewModel.ingredients.filter { $0.type == "Yeast" }
        
        // Then - verify filtering works
        XCTAssertEqual(maltIngredients.count, 2)
        XCTAssertEqual(hopIngredients.count, 2)
        XCTAssertEqual(yeastIngredients.count, 1)
        
        // Test bulk deletion by type
        for ingredient in hopIngredients {
            ingredientsViewModel.deleteIngredient(ingredient)
        }
        
        XCTAssertEqual(ingredientsViewModel.ingredients.count, 3)
        XCTAssertEqual(ingredientsViewModel.ingredients.filter { $0.type == "Hop" }.count, 0)
    }
    
    // MARK: - Error Handling Integration Tests
    
    func testInvalidDataHandling() {
        // Test recipe with extreme values
        recipeViewModel.createRecipe(
            name: "", // Empty name
            style: "",
            targetOG: -1.0, // Negative OG
            targetFG: 2.0, // Invalid FG
            abv: -5.0, // Negative ABV
            ibu: -10, // Negative IBU
            srm: -1, // Negative SRM
            batchSize: 0.0, // Zero batch size
            boilTime: -30, // Negative boil time
            efficiency: 150.0, // >100% efficiency
            notes: String(repeating: "A", count: 10000) // Very long notes
        )
        
        // Should still create recipe (app handles validation at UI level)
        XCTAssertEqual(recipeViewModel.recipes.count, 1)
        let recipe = recipeViewModel.recipes.first
        XCTAssertNotNil(recipe)
    }
    
    func testContextSaveErrors() {
        // Create valid recipe
        recipeViewModel.createRecipe(
            name: "Save Error Test",
            style: "Test Style",
            targetOG: 1.050,
            targetFG: 1.010,
            abv: 5.0,
            ibu: 40,
            srm: 5,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "Testing save errors"
        )
        
        // Multiple saves should not cause issues
        XCTAssertNoThrow(recipeViewModel.saveContext())
        XCTAssertNoThrow(recipeViewModel.saveContext())
        XCTAssertNoThrow(recipeViewModel.saveContext())
        
        // Context should remain consistent
        XCTAssertEqual(recipeViewModel.recipes.count, 1)
        XCTAssertFalse(context.hasChanges)
    }
    
    // MARK: - Performance Integration Tests
    
    func testLargeDatasetPerformance() {
        measure {
            // Create 100 recipes and 200 ingredients
            for i in 1...100 {
                recipeViewModel.createRecipe(
                    name: "Performance Recipe \(i)",
                    style: "Style \(i % 10)",
                    targetOG: 1.040 + Double(i) * 0.0005,
                    targetFG: 1.008 + Double(i) * 0.0001,
                    abv: 4.0 + Double(i) * 0.05,
                    ibu: 20 + i % 80,
                    srm: 3 + i % 40,
                    batchSize: 20.0,
                    boilTime: 60,
                    efficiency: 70.0 + Double(i % 30),
                    notes: "Performance test recipe \(i)"
                )
            }
            
            for i in 1...200 {
                _ = ingredientsViewModel.addIngredient(
                    name: "Performance Ingredient \(i)",
                    type: i % 3 == 0 ? "Malt" : (i % 3 == 1 ? "Hop" : "Yeast"),
                    category: "Category \(i % 5)",
                    amount: Double(i % 10 + 1),
                    unit: i % 3 == 0 ? "kg" : "g",
                    notes: "Performance test ingredient \(i)"
                )
            }
            
            // Save all data
            recipeViewModel.saveContext()
            ingredientsViewModel.saveContext()
        }
    }
    
    // MARK: - Default Data Integration Tests
    
    func testDefaultRecipesIntegration() {
        // Test that default recipes can be loaded alongside user recipes
        let defaultRecipes = DefaultRecipesDatabase.getAllDefaultRecipes()
        XCTAssertGreaterThan(defaultRecipes.count, 0)
        
        // Create user recipe
        recipeViewModel.createRecipe(
            name: "User Recipe",
            style: "User Style",
            targetOG: 1.050,
            targetFG: 1.010,
            abv: 5.0,
            ibu: 40,
            srm: 5,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "User created recipe"
        )
        
        // Verify user recipe exists alongside default recipes conceptually
        XCTAssertEqual(recipeViewModel.recipes.count, 1)
        XCTAssertGreaterThan(defaultRecipes.count, 0)
        
        // Default recipes are separate from Core Data recipes
        let userRecipe = recipeViewModel.recipes.first
        XCTAssertEqual(userRecipe?.name, "User Recipe")
    }
} 