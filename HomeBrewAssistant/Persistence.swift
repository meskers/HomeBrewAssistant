import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()
    
    // Preview controller met testdata
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Voeg testrecepten toe
        for i in 1...3 {
            let newRecipe = DetailedRecipeModel(context: context)
            newRecipe.id = UUID()
            newRecipe.name = "Test Recept \(i)"
            newRecipe.type = i % 2 == 0 ? "Bier" : "Wijn"
            newRecipe.notes = "Dit is een testinstructie voor recept \(i)"
            newRecipe.createdAt = Date()
            newRecipe.updatedAt = Date()
            
            // Voeg test-ingrediënten toe
            for j in 1...2 {
                let ingredient = Ingredient(context: context)
                ingredient.id = UUID()
                ingredient.name = "Ingrediënt \(j)"
                ingredient.amount = "\(j * 100) g"
                ingredient.recipe = newRecipe
            }
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Fout bij preview data: \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()

    let container: NSPersistentContainer
    
    // Background context for heavy operations
    private(set) lazy var backgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HomeBrewAssistant")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Configure automatic merging
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Configure view context to prevent blocking
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.name = "viewContext"
        
        // Add persistent store
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Fout bij laden Core Data: \(error), \(error.userInfo)")
            }
        }
    }
    
    // Save context with error handling
    func save(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                throw error
            }
        }
    }
    
    // Perform operation on background context
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = backgroundContext
        context.perform {
            block(context)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Error saving background context: \(error)")
                    context.rollback()
                }
            }
        }
    }
    
    // Batch delete with error handling
    func batchDelete(fetchRequest: NSFetchRequest<NSFetchRequestResult>) throws {
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDelete.resultType = .resultTypeObjectIDs
        
        do {
            let result = try backgroundContext.execute(batchDelete) as? NSBatchDeleteResult
            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        } catch {
            print("Error performing batch delete: \(error)")
            throw error
        }
    }
}
