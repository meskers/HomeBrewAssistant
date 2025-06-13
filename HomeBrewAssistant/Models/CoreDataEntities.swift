import Foundation
import CoreData

extension DetailedRecipeModel {
    var wrappedName: String {
        name ?? "Untitled Recipe"
    }
    
    var wrappedType: String {
        type ?? "Unknown Type"
    }
    
    var wrappedBrewer: String {
        brewer ?? "Unknown Brewer"
    }
    
    var wrappedNotes: String {
        notes ?? ""
    }
    
    var batchSize: Double {
        get { boilSize * 0.85 }
        set { boilSize = newValue / 0.85 }
    }
    
    var ingredientsArray: [Ingredient] {
        let set = ingredients as? Set<Ingredient> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
    
    var fermentationStepsArray: [FermentationStep] {
        let set = fermentationSteps as? Set<FermentationStep> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
    
    var mashStepsArray: [MashStep] {
        guard let mashProfile = mashProfile else { return [] }
        let set = mashProfile.steps as? Set<MashStep> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
}

extension Ingredient {
    var wrappedName: String {
        name ?? "Unknown Ingredient"
    }
    
    var wrappedType: String {
        type ?? "Unknown Type"
    }
    
    var wrappedAmount: String {
        amount ?? "0"
    }
    
    var wrappedTiming: String {
        timing ?? "Unknown"
    }
}

extension FermentationStep {
    var wrappedName: String {
        name ?? "Unknown Step"
    }
    
    var wrappedDescription: String {
        desc ?? ""
    }
    
    var stepDescription: String {
        get { desc ?? "" }
        set { desc = newValue }
    }
}

extension MashProfile {
    var wrappedName: String {
        name ?? "Unknown Mash Profile"
    }
    
    var wrappedNotes: String {
        notes ?? ""
    }
    
    var stepsArray: [MashStep] {
        let set = steps as? Set<MashStep> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
}

extension MashStep {
    var wrappedName: String {
        name ?? "Unknown Step"
    }
    
    var wrappedType: String {
        type ?? "Unknown Type"
    }
    
    var wrappedDescription: String {
        desc ?? ""
    }
} 