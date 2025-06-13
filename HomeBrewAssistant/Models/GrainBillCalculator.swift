import Foundation

class GrainBillCalculator {
    
    private let grainDatabase = GrainDatabase()
    
    func calculateOptimalGrainBill(
        targetOG: Double,
        targetSRM: Double,
        batchSize: Double,
        style: BJCPStyle,
        complexity: RecipeComplexity
    ) async -> [GrainIngredient] {
        
        let totalGrainWeight = calculateTotalGrainWeight(targetOG: targetOG, batchSize: batchSize)
        
        switch complexity {
        case .beginner:
            return generateBeginnerGrainBill(
                totalWeight: totalGrainWeight,
                targetSRM: targetSRM,
                style: style
            )
        case .intermediate:
            return generateIntermediateGrainBill(
                totalWeight: totalGrainWeight,
                targetSRM: targetSRM,
                style: style
            )
        case .advanced, .expert:
            return generateAdvancedGrainBill(
                totalWeight: totalGrainWeight,
                targetSRM: targetSRM,
                style: style
            )
        }
    }
    
    // MARK: - Beginner Grain Bills (2-3 malts)
    private func generateBeginnerGrainBill(totalWeight: Double, targetSRM: Double, style: BJCPStyle) -> [GrainIngredient] {
        var grainBill: [GrainIngredient] = []
        
        // Base malt (85-95%)
        let baseMalt = selectBaseMalt(for: style)
        let baseMaltPercentage = 0.90
        grainBill.append(GrainIngredient(
            name: baseMalt.name,
            type: baseMalt.type,
            percentage: baseMaltPercentage * 100,
            amount: totalWeight * baseMaltPercentage,
            potential: baseMalt.potential,
            lovibond: baseMalt.lovibond
        ))
        
        // Crystal malt for color and flavor (5-15%)
        if targetSRM > 4 {
            let crystalMalt = selectCrystalMalt(targetSRM: targetSRM)
            let crystalPercentage = 0.10
            grainBill.append(GrainIngredient(
                name: crystalMalt.name,
                type: crystalMalt.type,
                percentage: crystalPercentage * 100,
                amount: totalWeight * crystalPercentage,
                potential: crystalMalt.potential,
                lovibond: crystalMalt.lovibond
            ))
        }
        
        return grainBill
    }
    
    // MARK: - Intermediate Grain Bills (3-5 malts)
    private func generateIntermediateGrainBill(totalWeight: Double, targetSRM: Double, style: BJCPStyle) -> [GrainIngredient] {
        var grainBill: [GrainIngredient] = []
        var remainingWeight = totalWeight
        
        // Base malt (70-85%)
        let baseMalt = selectBaseMalt(for: style)
        let baseMaltPercentage = 0.75
        let baseMaltAmount = totalWeight * baseMaltPercentage
        grainBill.append(GrainIngredient(
            name: baseMalt.name,
            type: baseMalt.type,
            percentage: baseMaltPercentage * 100,
            amount: baseMaltAmount,
            potential: baseMalt.potential,
            lovibond: baseMalt.lovibond
        ))
        remainingWeight -= baseMaltAmount
        
        // Crystal malts for complexity (10-20%)
        if targetSRM > 3 {
            let primaryCrystal = selectCrystalMalt(targetSRM: targetSRM)
            let crystalAmount = totalWeight * 0.15
            grainBill.append(GrainIngredient(
                name: primaryCrystal.name,
                type: primaryCrystal.type,
                percentage: 15.0,
                amount: crystalAmount,
                potential: primaryCrystal.potential,
                lovibond: primaryCrystal.lovibond
            ))
            remainingWeight -= crystalAmount
        }
        
        // Specialty malts for style character (5-10%)
        let specialtyMalts = selectSpecialtyMalts(for: style, targetSRM: targetSRM)
        for specialtyMalt in specialtyMalts.prefix(2) {
            let specialtyAmount = totalWeight * 0.05
            if remainingWeight >= specialtyAmount {
                grainBill.append(GrainIngredient(
                    name: specialtyMalt.name,
                    type: specialtyMalt.type,
                    percentage: 5.0,
                    amount: specialtyAmount,
                    potential: specialtyMalt.potential,
                    lovibond: specialtyMalt.lovibond
                ))
                remainingWeight -= specialtyAmount
            }
        }
        
        return normalizeGrainBillPercentages(grainBill)
    }
    
    // MARK: - Advanced Grain Bills (4-8 malts)
    private func generateAdvancedGrainBill(totalWeight: Double, targetSRM: Double, style: BJCPStyle) -> [GrainIngredient] {
        var grainBill: [GrainIngredient] = []
        
        // Complex grain bill with multiple base malts
        if style.name.contains("Czech") || style.name.contains("German") {
            // European styles with Pilsner malt base
            grainBill.append(GrainIngredient(
                name: "Pilsner Malt",
                type: .base,
                percentage: 80.0,
                amount: totalWeight * 0.80,
                potential: 1.037,
                lovibond: 1.6
            ))
            
            grainBill.append(GrainIngredient(
                name: "Munich Malt",
                type: .base,
                percentage: 10.0,
                amount: totalWeight * 0.10,
                potential: 1.035,
                lovibond: 8.0
            ))
            
        } else {
            // American styles with 2-row base
            grainBill.append(GrainIngredient(
                name: "2-row Pale Malt",
                type: .base,
                percentage: 70.0,
                amount: totalWeight * 0.70,
                potential: 1.037,
                lovibond: 2.0
            ))
            
            grainBill.append(GrainIngredient(
                name: "Munich Malt",
                type: .base,
                percentage: 15.0,
                amount: totalWeight * 0.15,
                potential: 1.035,
                lovibond: 8.0
            ))
        }
        
        // Add complexity based on style
        let complexityMalts = generateComplexityMalts(for: style, targetSRM: targetSRM, totalWeight: totalWeight)
        grainBill.append(contentsOf: complexityMalts)
        
        return normalizeGrainBillPercentages(grainBill)
    }
    
    // MARK: - Helper Functions
    private func calculateTotalGrainWeight(targetOG: Double, batchSize: Double) -> Double {
        let efficiency = 0.75 // 75% brewhouse efficiency
        let gravityPoints = (targetOG - 1.0) * 1000 // Convert to gravity points
        let totalPoints = gravityPoints * batchSize
        let poundsPerPoint = 1.0 / 37.0 // Typical 2-row potential
        return (totalPoints * poundsPerPoint) / efficiency * 0.453592 // Convert lbs to kg
    }
    
    private func selectBaseMalt(for style: BJCPStyle) -> GrainDatabase.Grain {
        if style.category.contains("German") || style.category.contains("Czech") {
            return grainDatabase.pilsnerMalt
        } else if style.category.contains("English") || style.category.contains("British") {
            return grainDatabase.marsMalt
        } else {
            return grainDatabase.twoRowPale
        }
    }
    
    private func selectCrystalMalt(targetSRM: Double) -> GrainDatabase.Grain {
        switch targetSRM {
        case 0...6:
            return grainDatabase.crystal40
        case 6...12:
            return grainDatabase.crystal60
        case 12...20:
            return grainDatabase.crystal80
        default:
            return grainDatabase.crystal120
        }
    }
    
    private func selectSpecialtyMalts(for style: BJCPStyle, targetSRM: Double) -> [GrainDatabase.Grain] {
        var specialtyMalts: [GrainDatabase.Grain] = []
        
        // Style-specific specialty malts
        if style.flavorProfile.contains("Roasted") {
            specialtyMalts.append(grainDatabase.chocolateMalt)
        }
        
        if style.flavorProfile.contains("Coffee") {
            specialtyMalts.append(grainDatabase.blackPatent)
        }
        
        if style.flavorProfile.contains("Bready") {
            specialtyMalts.append(grainDatabase.munichMalt)
        }
        
        if style.flavorProfile.contains("Nutty") {
            specialtyMalts.append(grainDatabase.biscuitMalt)
        }
        
        return specialtyMalts
    }
    
    private func generateComplexityMalts(for style: BJCPStyle, targetSRM: Double, totalWeight: Double) -> [GrainIngredient] {
        var complexityMalts: [GrainIngredient] = []
        
        // Oatmeal Stout specific
        if style.name.contains("Oatmeal") {
            complexityMalts.append(GrainIngredient(
                name: "Flaked Oats",
                type: .adjunct,
                percentage: 5.0,
                amount: totalWeight * 0.05,
                potential: 1.033,
                lovibond: 1.0
            ))
        }
        
        // Porter/Stout roasted malts
        if style.flavorProfile.contains("Roasted") {
            complexityMalts.append(GrainIngredient(
                name: "Roasted Barley",
                type: .roasted,
                percentage: 3.0,
                amount: totalWeight * 0.03,
                potential: 1.025,
                lovibond: 300.0
            ))
            
            complexityMalts.append(GrainIngredient(
                name: "Chocolate Malt",
                type: .roasted,
                percentage: 5.0,
                amount: totalWeight * 0.05,
                potential: 1.028,
                lovibond: 350.0
            ))
        }
        
        // IPA specialty malts
        if style.name.contains("IPA") {
            complexityMalts.append(GrainIngredient(
                name: "Crystal 40L",
                type: .crystal,
                percentage: 5.0,
                amount: totalWeight * 0.05,
                potential: 1.034,
                lovibond: 40.0
            ))
            
            complexityMalts.append(GrainIngredient(
                name: "Victory Malt",
                type: .specialty,
                percentage: 2.0,
                amount: totalWeight * 0.02,
                potential: 1.034,
                lovibond: 25.0
            ))
        }
        
        return complexityMalts
    }
    
    private func normalizeGrainBillPercentages(_ grainBill: [GrainIngredient]) -> [GrainIngredient] {
        let totalPercentage = grainBill.reduce(0) { $0 + $1.percentage }
        
        return grainBill.map { grain in
            let normalizedPercentage = (grain.percentage / totalPercentage) * 100
            return GrainIngredient(
                name: grain.name,
                type: grain.type,
                percentage: normalizedPercentage,
                amount: grain.amount,
                potential: grain.potential,
                lovibond: grain.lovibond
            )
        }
    }
}

// MARK: - Grain Database
class GrainDatabase {
    struct Grain {
        let name: String
        let type: GrainType
        let potential: Double
        let lovibond: Double
        let description: String
    }
    
    let twoRowPale = Grain(name: "2-row Pale Malt", type: .base, potential: 1.037, lovibond: 2.0, description: "Standard American base malt")
    let pilsnerMalt = Grain(name: "Pilsner Malt", type: .base, potential: 1.037, lovibond: 1.6, description: "Light continental base malt")
    let marsMalt = Grain(name: "Maris Otter", type: .base, potential: 1.037, lovibond: 3.0, description: "English base malt")
    let munichMalt = Grain(name: "Munich Malt", type: .base, potential: 1.035, lovibond: 8.0, description: "Adds malty character")
    
    let crystal40 = Grain(name: "Crystal 40L", type: .crystal, potential: 1.034, lovibond: 40.0, description: "Light caramel flavors")
    let crystal60 = Grain(name: "Crystal 60L", type: .crystal, potential: 1.034, lovibond: 60.0, description: "Medium caramel flavors")
    let crystal80 = Grain(name: "Crystal 80L", type: .crystal, potential: 1.034, lovibond: 80.0, description: "Dark caramel flavors")
    let crystal120 = Grain(name: "Crystal 120L", type: .crystal, potential: 1.033, lovibond: 120.0, description: "Deep caramel/raisin flavors")
    
    let chocolateMalt = Grain(name: "Chocolate Malt", type: .roasted, potential: 1.028, lovibond: 350.0, description: "Chocolate flavors")
    let blackPatent = Grain(name: "Black Patent", type: .roasted, potential: 1.025, lovibond: 500.0, description: "Coffee/bitter flavors")
    let biscuitMalt = Grain(name: "Biscuit Malt", type: .specialty, potential: 1.035, lovibond: 23.0, description: "Bready/nutty flavors")
} 