import Foundation
import SwiftUI

// MARK: - BJCP Style Database
struct BJCPStyle {
    let id: String
    let name: String
    let category: String
    let abvRange: ClosedRange<Double>
    let ibuRange: ClosedRange<Double>
    let srmRange: ClosedRange<Double>
    let ogRange: ClosedRange<Double>
    let fgRange: ClosedRange<Double>
    let description: String
    let characteristicIngredients: [String]
    let flavorProfile: [String]
    let complexity: RecipeComplexity
}

enum RecipeComplexity: String, CaseIterable, Comparable {
    case beginner = "Beginner"
    case intermediate = "Intermediate" 
    case advanced = "Advanced"
    case expert = "Expert"
    
    static func < (lhs: RecipeComplexity, rhs: RecipeComplexity) -> Bool {
        let order: [RecipeComplexity] = [.beginner, .intermediate, .advanced, .expert]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

// MARK: - AI Recipe Generator
class AIRecipeGenerator: ObservableObject {
    @Published var generatedRecipe: DetailedRecipe?
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    @Published var styleRecommendations: [BJCPStyle] = []
    
    private let bjcpDatabase = BJCPDatabase()
    private let ingredientDatabase = IngredientDatabase()
    private let recipeOptimizer = RecipeOptimizer()
    
    // MARK: - Main Generation Function
    func generateRecipe(for style: BJCPStyle, complexity: RecipeComplexity = .intermediate, batchSize: Double = 20.0) async {
        await MainActor.run {
            isGenerating = true
            generationProgress = 0.0
        }
        
        // Step 1: Calculate base specifications (20%)
        await updateProgress(0.2)
        let baseSpecs = calculateBaseSpecifications(style: style, batchSize: batchSize)
        
        // Step 2: Select grain bill (40%)
        await updateProgress(0.4)
        let grainBill = await generateGrainBill(for: style, specs: baseSpecs, complexity: complexity)
        
        // Step 3: Calculate hop schedule (60%)
        await updateProgress(0.6)
        let hopSchedule = await generateHopSchedule(for: style, specs: baseSpecs, complexity: complexity)
        
        // Step 4: Select yeast and other ingredients (80%)
        await updateProgress(0.8)
        let yeastSelection = selectYeast(for: style, specs: baseSpecs)
        let additionalIngredients = selectAdditionalIngredients(for: style, complexity: complexity)
        
        // Step 5: Optimize and finalize (100%)
        await updateProgress(1.0)
        let optimizedRecipe = recipeOptimizer.optimize(
            grainBill: grainBill,
            hops: hopSchedule,
            yeast: yeastSelection,
            additionals: additionalIngredients,
            targetSpecs: baseSpecs,
            style: style
        )
        
        await MainActor.run {
            self.generatedRecipe = optimizedRecipe
            self.isGenerating = false
        }
    }
    
    // MARK: - Style Recommendation Engine
    func recommendStyles(basedOn preferences: BrewerPreferences) -> [BJCPStyle] {
        var scores: [(BJCPStyle, Double)] = []
        
        for style in bjcpDatabase.allStyles {
            var score = 0.0
            
            // Complexity preference
            if style.complexity == preferences.preferredComplexity {
                score += 3.0
            }
            
            // ABV preference
            if style.abvRange.contains(preferences.preferredABV) {
                score += 2.0
            }
            
            // Flavor preferences
            for flavor in preferences.preferredFlavors {
                if style.flavorProfile.contains(flavor) {
                    score += 1.5
                }
            }
            
            // Ingredient familiarity
            for ingredient in preferences.familiarIngredients {
                if style.characteristicIngredients.contains(ingredient) {
                    score += 1.0
                }
            }
            
            scores.append((style, score))
        }
        
        return scores.sorted { $0.1 > $1.1 }.prefix(5).map { $0.0 }
    }
    
    // MARK: - Private Helper Functions
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            self.generationProgress = progress
        }
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 second delay for UX
    }
    
    private func calculateBaseSpecifications(style: BJCPStyle, batchSize: Double) -> RecipeSpecifications {
        let targetOG = (style.ogRange.lowerBound + style.ogRange.upperBound) / 2
        let targetFG = (style.fgRange.lowerBound + style.fgRange.upperBound) / 2
        let targetABV = (style.abvRange.lowerBound + style.abvRange.upperBound) / 2
        let targetIBU = (style.ibuRange.lowerBound + style.ibuRange.upperBound) / 2
        let targetSRM = (style.srmRange.lowerBound + style.srmRange.upperBound) / 2
        
        return RecipeSpecifications(
            batchSize: batchSize,
            targetOG: targetOG,
            targetFG: targetFG,
            targetABV: targetABV,
            targetIBU: targetIBU,
            targetSRM: targetSRM,
            efficiency: 75.0 // Default homebrew efficiency
        )
    }
    
    private func generateGrainBill(for style: BJCPStyle, specs: RecipeSpecifications, complexity: RecipeComplexity) async -> [GrainIngredient] {
        let grainCalculator = GrainBillCalculator()
        return await grainCalculator.calculateOptimalGrainBill(
            targetOG: specs.targetOG,
            targetSRM: specs.targetSRM,
            batchSize: specs.batchSize,
            style: style,
            complexity: complexity
        )
    }
    
    private func generateHopSchedule(for style: BJCPStyle, specs: RecipeSpecifications, complexity: RecipeComplexity) async -> [HopAddition] {
        let hopCalculator = HopScheduleCalculator()
        return await hopCalculator.calculateOptimalHopSchedule(
            targetIBU: specs.targetIBU,
            og: specs.targetOG,
            batchSize: specs.batchSize,
            style: style,
            complexity: complexity
        )
    }
    
    private func selectYeast(for style: BJCPStyle, specs: RecipeSpecifications) -> YeastSelection {
        let yeastDatabase = YeastDatabase()
        return yeastDatabase.selectOptimalYeast(
            for: style,
            targetAttenuation: (specs.targetOG - specs.targetFG) / (specs.targetOG - 1.0),
            targetABV: specs.targetABV
        )
    }
    
    private func selectAdditionalIngredients(for style: BJCPStyle, complexity: RecipeComplexity) -> [AdditionalIngredient] {
        let additionalDB = AdditionalIngredientsDatabase()
        return additionalDB.selectForStyle(style, complexity: complexity)
    }
}

// MARK: - Supporting Data Structures
struct RecipeSpecifications {
    let batchSize: Double
    let targetOG: Double
    let targetFG: Double
    let targetABV: Double
    let targetIBU: Double
    let targetSRM: Double
    let efficiency: Double
}

struct BrewerPreferences {
    let preferredComplexity: RecipeComplexity
    let preferredABV: Double
    let preferredFlavors: [String]
    let familiarIngredients: [String]
    let experienceLevel: Int // 1-10
    let equipmentCapabilities: [String]
}

struct GrainIngredient {
    let name: String
    let type: GrainType
    let percentage: Double
    let amount: Double // kg
    let potential: Double
    let lovibond: Double
}

struct HopAddition: Identifiable {
    let id: UUID
    let hopVariety: String
    let amount: Double // grams
    let time: Double // minutes
    let alphaAcid: Double
    let usage: HopUsage
    let ibuContribution: Double
    
    // Computed properties for MainTabView compatibility
    var alphaAcidString: String {
        return String(format: "%.1f", alphaAcid)
    }
    
    var weight: String {
        return String(format: "%.0f", amount)
    }
    
    var boilTime: String {
        return String(format: "%.0f", time)
    }
    
    // Initializer for MainTabView compatibility
    init() {
        self.id = UUID()
        self.hopVariety = ""
        self.amount = 0.0
        self.time = 60.0
        self.alphaAcid = 5.0
        self.usage = .bittering
        self.ibuContribution = 0.0
    }
    
    // Full initializer for AI generation
    init(hopVariety: String, amount: Double, time: Double, alphaAcid: Double, usage: HopUsage, ibuContribution: Double) {
        self.id = UUID()
        self.hopVariety = hopVariety
        self.amount = amount
        self.time = time
        self.alphaAcid = alphaAcid
        self.usage = usage
        self.ibuContribution = ibuContribution
    }
}

struct YeastSelection {
    let strain: String
    let type: YeastType
    let attenuation: Double
    let temperatureRange: ClosedRange<Double>
    let flavorProfile: [String]
}

struct AdditionalIngredient {
    let name: String
    let amount: Double
    let unit: String
    let additionTime: String
    let purpose: String
}

enum GrainType: String, CaseIterable {
    case base = "Base Malt"
    case crystal = "Crystal/Caramel"
    case roasted = "Roasted"
    case specialty = "Specialty"
    case adjunct = "Adjunct"
}

enum HopUsage: String, CaseIterable {
    case bittering = "Bittering"
    case flavor = "Flavor"
    case aroma = "Aroma"
    case whirlpool = "Whirlpool"
    case dryHop = "Dry Hop"
}

enum YeastType: String, CaseIterable {
    case ale = "Ale"
    case lager = "Lager"
    case wheat = "Wheat"
    case wild = "Wild/Brett"
    case specialty = "Specialty"
} 