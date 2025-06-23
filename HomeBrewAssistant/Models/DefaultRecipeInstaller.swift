import Foundation
import CoreData

/// Professional Default Recipe Installer for App Store ready experience
/// Handles installation of default recipes to CoreData for new users only
class DefaultRecipeInstaller {
    
    /// Installs default recipes to CoreData after onboarding completion
    /// Only runs for new App Store downloads, not existing users
    static func installDefaultRecipesToCoreData(context: NSManagedObjectContext) {
        // Check if default recipes are already installed
        let hasDefaultRecipes = UserDefaults.standard.bool(forKey: "defaultRecipesInstalled")
        
        guard !hasDefaultRecipes else {
            print("✅ Default recipes already installed, skipping...")
            return
        }
        
        print("🍺 Installing default recipes for new user...")
        
        let defaultRecipes = DefaultRecipesDatabase.getAllDefaultRecipes()
        
        for recipe in defaultRecipes {
            // Create CoreData recipe
            let coreDataRecipe = DetailedRecipeModel(context: context)
            coreDataRecipe.id = UUID()
            coreDataRecipe.name = recipe.name
            // Note: style is stored in notes field since CoreData model doesn't have style
            coreDataRecipe.type = "beer" // Default type
            coreDataRecipe.notes = "\(recipe.style)\n\n\(recipe.notes ?? "")"
            coreDataRecipe.brewer = "HomeBrewAssistant" // Mark as default recipe
            coreDataRecipe.createdAt = Date()
            coreDataRecipe.updatedAt = Date()
            
            // Add ingredients
            for ingredient in recipe.ingredients {
                let coreDataIngredient = Ingredient(context: context)
                coreDataIngredient.id = UUID()
                coreDataIngredient.name = ingredient.name
                coreDataIngredient.amount = ingredient.amount
                coreDataIngredient.type = ingredient.type.rawValue
                coreDataIngredient.timing = ingredient.timing
                coreDataIngredient.recipe = coreDataRecipe
            }
        }
        
        // Save to CoreData
        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: "defaultRecipesInstalled")
            UserDefaults.standard.synchronize()
            print("✅ Default recipes successfully installed to CoreData!")
        } catch {
            print("❌ Failed to install default recipes: \(error)")
        }
    }
    
    /// Resets the default recipes installation flag (used by factory reset)
    static func resetInstallationFlag() {
        UserDefaults.standard.removeObject(forKey: "defaultRecipesInstalled")
        UserDefaults.standard.synchronize()
        print("🔄 Default recipes installation flag reset")
    }
} 