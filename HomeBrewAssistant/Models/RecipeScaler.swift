import Foundation

// MARK: - Recipe Scaling Model
class RecipeScaler: ObservableObject {
    
    // MARK: - Scaling Functions
    
    /// Schaalt een volledig recept naar een nieuwe batch size
    static func scaleRecipe(_ recipe: DetailedRecipe, from originalBatchSize: Double, to newBatchSize: Double) -> DetailedRecipe {
        let scaleFactor = newBatchSize / originalBatchSize
        
        let scaledIngredients = recipe.ingredients.map { ingredient in
            scaleIngredient(ingredient, by: scaleFactor)
        }
        
        let scaledInstructions = recipe.instructions.map { instruction in
            scaleInstruction(instruction, by: scaleFactor)
        }
        
        return DetailedRecipe(
            name: "\(recipe.name) (\(formatBatchSize(newBatchSize))L)",
            style: recipe.style,
            abv: recipe.abv, // ABV blijft hetzelfde
            ibu: recipe.ibu, // IBU blijft hetzelfde bij proportionele scaling
            difficulty: recipe.difficulty,
            brewTime: recipe.brewTime,
            ingredients: scaledIngredients,
            instructions: scaledInstructions,
            notes: "\(recipe.notes)\n\nGeschaald van \(formatBatchSize(originalBatchSize))L naar \(formatBatchSize(newBatchSize))L (factor: \(String(format: "%.2f", scaleFactor)))"
        )
    }
    
    /// Schaalt een individueel ingrediënt
    static func scaleIngredient(_ ingredient: RecipeIngredient, by factor: Double) -> RecipeIngredient {
        let scaledAmount = scaleAmount(ingredient.amount, by: factor, for: ingredient.type)
        
        return RecipeIngredient(
            name: ingredient.name,
            amount: scaledAmount,
            type: ingredient.type,
            timing: ingredient.timing
        )
    }
    
    /// Schaalt hoeveelheden met intelligente eenheid handling
    static func scaleAmount(_ amount: String, by factor: Double, for type: IngredientType) -> String {
        // Extract nummer en eenheid uit de string
        let result = parseAmount(amount)
        guard let value = result.value else {
            return amount // Kon niet parsen, return origineel
        }
        
        let scaledValue = value * factor
        let unit = result.unit
        
        // Voor gist: rond af naar hele pakjes of grammen
        if type == .yeast {
            if unit.lowercased().contains("pak") {
                let roundedPacks = max(1, round(scaledValue))
                return "\(Int(roundedPacks)) \(roundedPacks == 1 ? "pak" : "paks")"
            }
        }
        
        // Format het geschaalde nummer
        let formattedValue = formatScaledValue(scaledValue)
        
        return "\(formattedValue) \(unit)"
    }
    
    /// Schaalt instructies met volume en tijdsaanpassingen
    static func scaleInstruction(_ instruction: String, by factor: Double) -> String {
        var scaledInstruction = instruction
        
        // Schaalt volumes (L, ml, liter)
        let volumePattern = #"(\d+(?:\.\d+)?)\s*(L|l|liter|ml|milliliter)"#
        if let regex = try? NSRegularExpression(pattern: volumePattern) {
            let nsString = scaledInstruction as NSString
            var offset = 0
            regex.enumerateMatches(in: scaledInstruction, options: [], range: NSRange(location: 0, length: scaledInstruction.utf16.count)) { match, _, _ in
                guard let match = match else { return }
                let matchRange = NSRange(location: match.range.location + offset, length: match.range.length)
                let matchString = nsString.substring(with: NSRange(location: match.range.location, length: match.range.length))
                let components = matchString.components(separatedBy: CharacterSet.whitespaces)
                if let value = Double(components[0]), components.count > 1 {
                    let unit = components.suffix(from: 1).joined(separator: " ")
                    let scaledValue = value * factor
                    let replacement = "\(formatScaledValue(scaledValue)) \(unit)"
                    scaledInstruction = (scaledInstruction as NSString).replacingCharacters(in: matchRange, with: replacement)
                    offset += replacement.count - match.range.length
                }
            }
        }
        
        // Schaalt gewichten in instructies (kg, g, gram)
        let weightPattern = #"(\d+(?:\.\d+)?)\s*(kg|g|gram)"#
        if let regex = try? NSRegularExpression(pattern: weightPattern) {
            let nsString = scaledInstruction as NSString
            var offset = 0
            regex.enumerateMatches(in: scaledInstruction, options: [], range: NSRange(location: 0, length: scaledInstruction.utf16.count)) { match, _, _ in
                guard let match = match else { return }
                let matchRange = NSRange(location: match.range.location + offset, length: match.range.length)
                let matchString = nsString.substring(with: NSRange(location: match.range.location, length: match.range.length))
                let components = matchString.components(separatedBy: CharacterSet.whitespaces)
                if let value = Double(components[0]), components.count > 1 {
                    let unit = components.suffix(from: 1).joined(separator: " ")
                    let scaledValue = value * factor
                    let replacement = "\(formatScaledValue(scaledValue)) \(unit)"
                    scaledInstruction = (scaledInstruction as NSString).replacingCharacters(in: matchRange, with: replacement)
                    offset += replacement.count - match.range.length
                }
            }
        }
        
        return scaledInstruction
    }
    
    // MARK: - Helper Functions
    
    /// Parst een hoeveelheid string naar nummer en eenheid
    static func parseAmount(_ amount: String) -> (value: Double?, unit: String) {
        let trimmed = amount.trimmingCharacters(in: .whitespaces)
        
        // Regex om nummer en eenheid te extraheren
        let pattern = #"^(\d+(?:\.\d+)?|\d+,\d+)\s*(.*)$"#
        
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) {
            
            let valueRange = Range(match.range(at: 1), in: trimmed)!
            let unitRange = Range(match.range(at: 2), in: trimmed)!
            
            var valueString = String(trimmed[valueRange])
            valueString = valueString.replacingOccurrences(of: ",", with: ".") // Nederlands naar Engels decimaal
            
            let value = Double(valueString)
            let unit = String(trimmed[unitRange]).trimmingCharacters(in: .whitespaces)
            
            return (value, unit.isEmpty ? "stuks" : unit)
        }
        
        return (nil, trimmed)
    }
    
    /// Formatteert een geschaalde waarde naar een leesbaar getal
    static func formatScaledValue(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1f", value)
        } else if value >= 100 {
            return String(format: "%.0f", value)
        } else if value >= 10 {
            return String(format: "%.1f", value)
        } else if value >= 1 {
            return String(format: "%.1f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
    
    /// Formatteert batch size voor display
    static func formatBatchSize(_ size: Double) -> String {
        if size == floor(size) {
            return String(Int(size))
        } else {
            return String(format: "%.1f", size)
        }
    }
    
    // MARK: - Predefined Batch Sizes
    
    static let commonBatchSizes: [Double] = [5, 10, 15, 20, 23, 25, 30, 40, 50]
    
    static func suggestedBatchSizes(for originalSize: Double) -> [Double] {
        var suggestions = commonBatchSizes.filter { $0 != originalSize }
        
        // Voeg 2x en 0.5x toe als die niet al in de lijst staan
        let doubleSize = originalSize * 2
        let halfSize = originalSize * 0.5
        
        if !suggestions.contains(doubleSize) && doubleSize <= 50 {
            suggestions.append(doubleSize)
        }
        
        if !suggestions.contains(halfSize) && halfSize >= 5 {
            suggestions.append(halfSize)
        }
        
        return suggestions.sorted()
    }
}

// MARK: - Extensions
extension String {
    var nilIfEmpty: String? {
        return self.isEmpty ? nil : self
    }
}

// MARK: - Batch Size Presets
struct BatchSizePreset {
    let name: String
    let size: Double
    let description: String
    
    static let presets: [BatchSizePreset] = [
        BatchSizePreset(name: "Mini Batch", size: 5, description: "Klein proefbrouwsel"),
        BatchSizePreset(name: "Test Batch", size: 10, description: "Experimenteel brouwen"),
        BatchSizePreset(name: "Small Batch", size: 15, description: "Kleine hoeveelheid"),
        BatchSizePreset(name: "Home Batch", size: 20, description: "Standaard thuisbrouw"),
        BatchSizePreset(name: "Standard", size: 23, description: "Klassieke batch size"),
        BatchSizePreset(name: "Large Batch", size: 25, description: "Grote hoeveelheid"),
        BatchSizePreset(name: "Party Batch", size: 30, description: "Voor feesten"),
        BatchSizePreset(name: "Commercial", size: 50, description: "Semi-commercieel")
    ]
} 