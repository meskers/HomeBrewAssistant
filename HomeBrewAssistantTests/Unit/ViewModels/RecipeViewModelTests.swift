//
//  RecipeViewModelTests.swift
//  HomeBrewAssistantTests
//
//  Created by Automated Testing on 24/06/2025.
//

import XCTest
import CoreData
@testable import HomeBrewAssistant

@MainActor
final class RecipeViewModelTests: XCTestCase {
    
    var viewModel: RecipeViewModel!
    var mockContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory Core Data stack for testing
        let persistentContainer = NSPersistentContainer(name: "HomeBrewAssistant")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
        
        mockContext = persistentContainer.viewContext
        viewModel = RecipeViewModel(context: mockContext)
    }
    
    override func tearDown() {
        // Clean up test data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Recipe.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try? mockContext.execute(deleteRequest)
        try? mockContext.save()
        
        viewModel = nil
        mockContext = nil
        super.tearDown()
    }
    
    // MARK: - Recipe Creation Tests
    
    func testCreateRecipe() {
        // Given
        let recipeName = "Test IPA"
        let initialCount = viewModel.recipes.count
        
        // When
        viewModel.createRecipe(
            name: recipeName,
            style: "American IPA",
            targetOG: 1.065,
            targetFG: 1.012,
            abv: 6.8,
            ibu: 65,
            srm: 8,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "Test recipe notes"
        )
        
        // Then
        XCTAssertEqual(viewModel.recipes.count, initialCount + 1)
        
        let createdRecipe = viewModel.recipes.first { $0.name == recipeName }
        XCTAssertNotNil(createdRecipe)
        XCTAssertEqual(createdRecipe?.name, recipeName)
        XCTAssertEqual(createdRecipe?.style, "American IPA")
        XCTAssertEqual(createdRecipe?.targetOG, 1.065, accuracy: 0.001)
        XCTAssertEqual(createdRecipe?.targetFG, 1.012, accuracy: 0.001)
        XCTAssertEqual(createdRecipe?.abv, 6.8, accuracy: 0.1)
        XCTAssertEqual(createdRecipe?.ibu, 65, accuracy: 0.1)
        XCTAssertEqual(createdRecipe?.srm, 8, accuracy: 0.1)
        XCTAssertEqual(createdRecipe?.batchSize, 20.0, accuracy: 0.1)
        XCTAssertEqual(createdRecipe?.boilTime, 60)
        XCTAssertEqual(createdRecipe?.efficiency, 75.0, accuracy: 0.1)
        XCTAssertEqual(createdRecipe?.notes, "Test recipe notes")
        XCTAssertNotNil(createdRecipe?.dateCreated)
        XCTAssertNotNil(createdRecipe?.id)
    }
    
    func testCreateRecipeWithEmptyName() {
        // Given
        let initialCount = viewModel.recipes.count
        
        // When
        viewModel.createRecipe(
            name: "",
            style: "American IPA",
            targetOG: 1.065,
            targetFG: 1.012,
            abv: 6.8,
            ibu: 65,
            srm: 8,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "Empty name test"
        )
        
        // Then - Recipe should still be created with empty name
        XCTAssertEqual(viewModel.recipes.count, initialCount + 1)
        let createdRecipe = viewModel.recipes.last
        XCTAssertEqual(createdRecipe?.name, "")
    }
    
    // MARK: - Recipe Deletion Tests
    
    func testDeleteRecipe() {
        // Given - create a recipe first
        viewModel.createRecipe(
            name: "Recipe to Delete",
            style: "Pilsner",
            targetOG: 1.045,
            targetFG: 1.008,
            abv: 4.8,
            ibu: 35,
            srm: 3,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 80.0,
            notes: "Will be deleted"
        )
        
        let initialCount = viewModel.recipes.count
        guard let recipeToDelete = viewModel.recipes.first(where: { $0.name == "Recipe to Delete" }) else {
            XCTFail("Failed to create test recipe")
            return
        }
        
        // When
        viewModel.deleteRecipe(recipeToDelete)
        
        // Then
        XCTAssertEqual(viewModel.recipes.count, initialCount - 1)
        XCTAssertNil(viewModel.recipes.first { $0.name == "Recipe to Delete" })
    }
    
    func testDeleteMultipleRecipes() {
        // Given - create multiple recipes
        let recipeNames = ["Recipe 1", "Recipe 2", "Recipe 3"]
        
        for name in recipeNames {
            viewModel.createRecipe(
                name: name,
                style: "Test Style",
                targetOG: 1.050,
                targetFG: 1.010,
                abv: 5.0,
                ibu: 40,
                srm: 5,
                batchSize: 20.0,
                boilTime: 60,
                efficiency: 75.0,
                notes: "Test recipe"
            )
        }
        
        let initialCount = viewModel.recipes.count
        let recipesToDelete = viewModel.recipes.filter { recipeNames.contains($0.name ?? "") }
        
        // When
        for recipe in recipesToDelete {
            viewModel.deleteRecipe(recipe)
        }
        
        // Then
        XCTAssertEqual(viewModel.recipes.count, initialCount - recipeNames.count)
        for name in recipeNames {
            XCTAssertNil(viewModel.recipes.first { $0.name == name })
        }
    }
    
    // MARK: - Recipe Update Tests
    
    func testUpdateRecipe() {
        // Given - create a recipe first
        viewModel.createRecipe(
            name: "Original Name",
            style: "Original Style",
            targetOG: 1.050,
            targetFG: 1.010,
            abv: 5.0,
            ibu: 40,
            srm: 5,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "Original notes"
        )
        
        guard let recipe = viewModel.recipes.first(where: { $0.name == "Original Name" }) else {
            XCTFail("Failed to create test recipe")
            return
        }
        
        // When - update the recipe
        recipe.name = "Updated Name"
        recipe.style = "Updated Style"
        recipe.targetOG = 1.055
        recipe.targetFG = 1.012
        recipe.abv = 5.5
        recipe.ibu = 45
        recipe.srm = 6
        recipe.batchSize = 25.0
        recipe.boilTime = 90
        recipe.efficiency = 80.0
        recipe.notes = "Updated notes"
        
        viewModel.saveContext()
        
        // Then - verify updates
        let updatedRecipe = viewModel.recipes.first { $0.name == "Updated Name" }
        XCTAssertNotNil(updatedRecipe)
        XCTAssertEqual(updatedRecipe?.name, "Updated Name")
        XCTAssertEqual(updatedRecipe?.style, "Updated Style")
        XCTAssertEqual(updatedRecipe?.targetOG, 1.055, accuracy: 0.001)
        XCTAssertEqual(updatedRecipe?.targetFG, 1.012, accuracy: 0.001)
        XCTAssertEqual(updatedRecipe?.abv, 5.5, accuracy: 0.1)
        XCTAssertEqual(updatedRecipe?.ibu, 45, accuracy: 0.1)
        XCTAssertEqual(updatedRecipe?.srm, 6, accuracy: 0.1)
        XCTAssertEqual(updatedRecipe?.batchSize, 25.0, accuracy: 0.1)
        XCTAssertEqual(updatedRecipe?.boilTime, 90)
        XCTAssertEqual(updatedRecipe?.efficiency, 80.0, accuracy: 0.1)
        XCTAssertEqual(updatedRecipe?.notes, "Updated notes")
        
        // Original should no longer exist
        XCTAssertNil(viewModel.recipes.first { $0.name == "Original Name" })
    }
    
    // MARK: - Recipe Fetching Tests
    
    func testFetchRecipes() {
        // Given - create some test recipes
        let testRecipes = [
            ("IPA", "American IPA"),
            ("Stout", "Imperial Stout"),
            ("Lager", "German Pilsner")
        ]
        
        for (name, style) in testRecipes {
            viewModel.createRecipe(
                name: name,
                style: style,
                targetOG: 1.050,
                targetFG: 1.010,
                abv: 5.0,
                ibu: 40,
                srm: 5,
                batchSize: 20.0,
                boilTime: 60,
                efficiency: 75.0,
                notes: "Test recipe"
            )
        }
        
        // When
        viewModel.fetchRecipes()
        
        // Then
        XCTAssertGreaterThanOrEqual(viewModel.recipes.count, testRecipes.count)
        
        for (name, style) in testRecipes {
            let recipe = viewModel.recipes.first { $0.name == name }
            XCTAssertNotNil(recipe)
            XCTAssertEqual(recipe?.style, style)
        }
    }
    
    func testEmptyRecipesList() {
        // Given - no recipes created
        
        // When
        viewModel.fetchRecipes()
        
        // Then
        XCTAssertEqual(viewModel.recipes.count, 0)
    }
    
    // MARK: - Recipe Search/Filter Tests
    
    func testRecipesByStyle() {
        // Given - create recipes with different styles
        let ipaRecipes = ["IPA 1", "IPA 2"]
        let stoutRecipes = ["Stout 1", "Stout 2"]
        
        for name in ipaRecipes {
            viewModel.createRecipe(
                name: name,
                style: "American IPA",
                targetOG: 1.065,
                targetFG: 1.012,
                abv: 6.5,
                ibu: 65,
                srm: 8,
                batchSize: 20.0,
                boilTime: 60,
                efficiency: 75.0,
                notes: "IPA recipe"
            )
        }
        
        for name in stoutRecipes {
            viewModel.createRecipe(
                name: name,
                style: "Imperial Stout",
                targetOG: 1.080,
                targetFG: 1.018,
                abv: 8.5,
                ibu: 55,
                srm: 40,
                batchSize: 20.0,
                boilTime: 90,
                efficiency: 75.0,
                notes: "Stout recipe"
            )
        }
        
        // When/Then - verify recipes are grouped by style
        let ipaRecipesFound = viewModel.recipes.filter { $0.style == "American IPA" }
        let stoutRecipesFound = viewModel.recipes.filter { $0.style == "Imperial Stout" }
        
        XCTAssertEqual(ipaRecipesFound.count, 2)
        XCTAssertEqual(stoutRecipesFound.count, 2)
        
        for name in ipaRecipes {
            XCTAssertTrue(ipaRecipesFound.contains { $0.name == name })
        }
        
        for name in stoutRecipes {
            XCTAssertTrue(stoutRecipesFound.contains { $0.name == name })
        }
    }
    
    // MARK: - Core Data Context Tests
    
    func testSaveContext() {
        // Given
        viewModel.createRecipe(
            name: "Save Test Recipe",
            style: "Test Style",
            targetOG: 1.050,
            targetFG: 1.010,
            abv: 5.0,
            ibu: 40,
            srm: 5,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "Save test"
        )
        
        // When
        viewModel.saveContext()
        
        // Then - verify context has no unsaved changes
        XCTAssertFalse(mockContext.hasChanges)
        
        // Verify recipe persists after context save
        let recipe = viewModel.recipes.first { $0.name == "Save Test Recipe" }
        XCTAssertNotNil(recipe)
    }
    
    func testContextSaveError() {
        // This test would require mocking Core Data errors
        // For now, we'll test that saveContext doesn't crash
        
        // Given - valid recipe
        viewModel.createRecipe(
            name: "Error Test Recipe",
            style: "Test Style",
            targetOG: 1.050,
            targetFG: 1.010,
            abv: 5.0,
            ibu: 40,
            srm: 5,
            batchSize: 20.0,
            boilTime: 60,
            efficiency: 75.0,
            notes: "Error test"
        )
        
        // When/Then - should not crash
        XCTAssertNoThrow(viewModel.saveContext())
    }
    
    // MARK: - Recipe Validation Tests
    
    func testRecipeWithExtremeValues() {
        // Given - recipe with extreme values
        viewModel.createRecipe(
            name: "Extreme Recipe",
            style: "Experimental",
            targetOG: 1.200, // Very high OG
            targetFG: 0.990, // Very low FG
            abv: 25.0, // Very high ABV
            ibu: 150, // Very high IBU
            srm: 100, // Very dark
            batchSize: 1000.0, // Very large batch
            boilTime: 300, // Very long boil
            efficiency: 100.0, // Perfect efficiency
            notes: "Extreme values test"
        )
        
        // When/Then - recipe should be created regardless of extreme values
        let recipe = viewModel.recipes.first { $0.name == "Extreme Recipe" }
        XCTAssertNotNil(recipe)
        XCTAssertEqual(recipe?.targetOG, 1.200, accuracy: 0.001)
        XCTAssertEqual(recipe?.targetFG, 0.990, accuracy: 0.001)
        XCTAssertEqual(recipe?.abv, 25.0, accuracy: 0.1)
        XCTAssertEqual(recipe?.ibu, 150, accuracy: 0.1)
        XCTAssertEqual(recipe?.srm, 100, accuracy: 0.1)
        XCTAssertEqual(recipe?.batchSize, 1000.0, accuracy: 0.1)
        XCTAssertEqual(recipe?.boilTime, 300)
        XCTAssertEqual(recipe?.efficiency, 100.0, accuracy: 0.1)
    }
    
    // MARK: - Performance Tests
    
    func testManyRecipesPerformance() {
        measure {
            // Create 100 recipes
            for i in 1...100 {
                viewModel.createRecipe(
                    name: "Performance Recipe \(i)",
                    style: "Test Style \(i % 10)",
                    targetOG: 1.050 + Double(i) * 0.001,
                    targetFG: 1.010 + Double(i) * 0.0002,
                    abv: 5.0 + Double(i) * 0.05,
                    ibu: 40 + i,
                    srm: 5 + i % 20,
                    batchSize: 20.0,
                    boilTime: 60,
                    efficiency: 75.0,
                    notes: "Performance test recipe \(i)"
                )
            }
            
            // Fetch all recipes
            viewModel.fetchRecipes()
        }
    }
} 