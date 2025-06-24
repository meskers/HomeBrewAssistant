import SwiftUI
import CoreData
import Foundation

enum RecipeError: LocalizedError {
    case emptyName
    case noIngredients
    case duplicateName
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Receptnaam is verplicht"
        case .noIngredients:
            return "Voeg minimaal één ingrediënt toe"
        case .duplicateName:
            return "Er bestaat al een recept met deze naam"
        }
    }
}

class RecipeViewModel: ObservableObject {
    // Receptgegevens
    @Published var recipeName = ""
    @Published var selectedType: RecipeType = .beer
    @Published var instructions = ""
    
    // Ingrediëntenlijst
    @Published var ingredients: [IngredientModel] = []
    
    // Nieuwe ingrediënt invoervelden
    @Published var newIngredientName = ""
    @Published var newIngredientAmount = ""
    
    // Voor het bewerken van bestaande recepten
    private var recipeToEdit: DetailedRecipeModel?
    
    // Initializer
    init(recipeToEdit: DetailedRecipeModel? = nil) {
        self.recipeToEdit = recipeToEdit
        
        if let recipe = recipeToEdit {
            loadRecipeData(from: recipe)
        }
    }
    
    // Laad data van bestaand recept
    private func loadRecipeData(from recipe: DetailedRecipeModel) {
        recipeName = recipe.wrappedName
        selectedType = RecipeType(rawValue: recipe.wrappedType) ?? .beer
        instructions = recipe.wrappedNotes
        
        // Laad ingrediënten
        ingredients = recipe.ingredientsArray.map { ingredient in
            IngredientModel(
                name: ingredient.wrappedName,
                amount: ingredient.wrappedAmount,
                type: ingredient.wrappedType,
                timing: ingredient.wrappedTiming
            )
        }
    }
    
    // Voeg een ingrediënt toe aan de lijst
    func addIngredient() {
        guard !newIngredientName.isEmpty else { return }
        
        let newIngredient = IngredientModel(
            name: newIngredientName,
            amount: newIngredientAmount,
            type: "Mout",
            timing: "Mashing"
        )
        
        ingredients.append(newIngredient)
        newIngredientName = ""
        newIngredientAmount = ""
    }
    
    // Verwijder een ingrediënt
    func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    // Sla het recept op in Core Data
    func saveRecipe(context: NSManagedObjectContext) throws {
        // Validation
        guard !recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RecipeError.emptyName
        }
        
        guard !ingredients.isEmpty else {
            throw RecipeError.noIngredients
        }
        
        let recipe: DetailedRecipeModel
        
        if let existingRecipe = recipeToEdit {
            // Update bestaand recept
            recipe = existingRecipe
            
            // Verwijder bestaande ingrediënten
            for ingredient in recipe.ingredientsArray {
                context.delete(ingredient)
            }
        } else {
            // Check for duplicate recipe names (alleen bij nieuwe recepten)
            let request: NSFetchRequest<DetailedRecipeModel> = DetailedRecipeModel.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", recipeName)
            
            if (try? context.fetch(request).first) != nil {
                throw RecipeError.duplicateName
            }
            
            // Maak nieuw recept
            recipe = DetailedRecipeModel(context: context)
            recipe.id = UUID()
            recipe.createdAt = Date()
        }
        
        // Update recept eigenschappen
        recipe.name = recipeName.trimmingCharacters(in: .whitespacesAndNewlines)
        recipe.type = selectedType.rawValue
        recipe.notes = instructions
        recipe.updatedAt = Date()
        
        // Voeg ingrediënten toe
        for ingredient in ingredients {
            let newIngredient = Ingredient(context: context)
            newIngredient.id = UUID()
            newIngredient.name = ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines)
            newIngredient.amount = ingredient.amount.trimmingCharacters(in: .whitespacesAndNewlines)
            newIngredient.type = ingredient.type
            newIngredient.timing = ingredient.timing
            newIngredient.recipe = recipe
        }
        
        try context.save()
    }
    
    // Reset het formulier na opslaan
    func resetForm() {
        recipeName = ""
        selectedType = .beer
        instructions = ""
        ingredients = []
        newIngredientName = ""
        newIngredientAmount = ""
    }
    
    func addDefaultIngredient() {
        let newIngredient = IngredientModel(
            name: "Nieuwe ingrediënt",
            amount: "0 kg",
            type: "Mout",
            timing: "Mashing"
        )
        ingredients.append(newIngredient)
    }
    
    func addIngredient(name: String, amount: String) {
        let newIngredient = IngredientModel(
            name: name,
            amount: amount,
            type: "Mout",
            timing: "Mashing"
        )
        ingredients.append(newIngredient)
    }
}


