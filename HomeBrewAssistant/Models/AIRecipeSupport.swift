import Foundation

// MARK: - Missing Classes and Stubs

class IngredientDatabase {
    // Placeholder for ingredient database
    // This would contain comprehensive ingredient information
}

class HopScheduleCalculator {
    func calculateOptimalHopSchedule(
        targetIBU: Double,
        og: Double,
        batchSize: Double,
        style: BJCPStyle,
        complexity: RecipeComplexity
    ) async -> [HopAddition] {
        
        var hopSchedule: [HopAddition] = []
        
        switch complexity {
        case .beginner:
            // Simple single hop addition
            hopSchedule.append(HopAddition(
                hopVariety: selectHopForStyle(style, usage: .bittering),
                amount: calculateHopAmount(targetIBU: targetIBU, og: og, batchSize: batchSize, time: 60.0),
                time: 60.0,
                alphaAcid: 10.0,
                usage: .bittering,
                ibuContribution: targetIBU
            ))
            
        case .intermediate:
            // Bittering + flavor/aroma
            let bitteringIBU = targetIBU * 0.7
            let flavorIBU = targetIBU * 0.3
            
            hopSchedule.append(HopAddition(
                hopVariety: selectHopForStyle(style, usage: .bittering),
                amount: calculateHopAmount(targetIBU: bitteringIBU, og: og, batchSize: batchSize, time: 60.0),
                time: 60.0,
                alphaAcid: 10.0,
                usage: .bittering,
                ibuContribution: bitteringIBU
            ))
            
            hopSchedule.append(HopAddition(
                hopVariety: selectHopForStyle(style, usage: .flavor),
                amount: calculateHopAmount(targetIBU: flavorIBU, og: og, batchSize: batchSize, time: 15.0),
                time: 15.0,
                alphaAcid: 8.0,
                usage: .flavor,
                ibuContribution: flavorIBU
            ))
            
        case .advanced, .expert:
            // Complex hop schedule
            hopSchedule = generateComplexHopSchedule(targetIBU: targetIBU, og: og, batchSize: batchSize, style: style)
        }
        
        return hopSchedule
    }
    
    private func selectHopForStyle(_ style: BJCPStyle, usage: HopUsage) -> String {
        // Style-specific hop selection
        if style.flavorProfile.contains("Citrusy") || style.name.contains("IPA") {
            switch usage {
            case .bittering:
                return "Columbus"
            case .flavor, .aroma:
                return "Citra"
            case .whirlpool:
                return "Centennial"
            case .dryHop:
                return "Mosaic"
            }
        } else if style.category.contains("English") || style.category.contains("British") {
            switch usage {
            case .bittering:
                return "Target"
            case .flavor, .aroma:
                return "East Kent Goldings"
            case .whirlpool:
                return "Fuggle"
            case .dryHop:
                return "East Kent Goldings"
            }
        } else if style.category.contains("German") || style.category.contains("Czech") {
            switch usage {
            case .bittering:
                return "Magnum"
            case .flavor, .aroma:
                return "Saaz"
            case .whirlpool:
                return "Tettnang"
            case .dryHop:
                return "Hallertau"
            }
        } else if style.category.contains("Nederlandse") {
            // Nederlandse hop variëteiten
            switch usage {
            case .bittering:
                return "Challenger" // Nederlands bitterhop
            case .flavor, .aroma:
                return "Bramling Cross" // Nederlandse aromahop
            case .whirlpool:
                return "First Gold" // Voor late additions
            case .dryHop:
                return "Progress" // Voor dry hopping
            }
        } else {
            // American defaults
            switch usage {
            case .bittering:
                return "Warrior"
            case .flavor, .aroma:
                return "Cascade"
            case .whirlpool:
                return "Chinook"
            case .dryHop:
                return "Amarillo"
            }
        }
    }
    
    private func calculateHopAmount(targetIBU: Double, og: Double, batchSize: Double, time: Double) -> Double {
        // Simplified IBU calculation (Tinseth formula approximation)
        let utilization = getUtilization(time: time, og: og)
        let alphaAcid = 10.0 // Default alpha acid
        
        // IBU = (Weight in oz * Alpha Acid % * Utilization) / (Batch Size in gal * 74.89)
        let batchSizeGallons = batchSize * 0.264172 // Convert liters to gallons
        let weightOz = (targetIBU * batchSizeGallons * 74.89) / (alphaAcid * utilization)
        let weightGrams = weightOz * 28.3495 // Convert oz to grams
        
        // Reasonable limits for homebrew (prevent pricing errors)
        return min(max(weightGrams, 5.0), 200.0) // Between 5g and 200g
    }
    
    private func getUtilization(time: Double, og: Double) -> Double {
        // Tinseth utilization formula
        let bignessFactor = 1.65 * pow(0.000125, og - 1.0)
        let timeFactor = (1 - exp(-0.04 * time)) / 4.15
        return bignessFactor * timeFactor
    }
    
    private func generateComplexHopSchedule(targetIBU: Double, og: Double, batchSize: Double, style: BJCPStyle) -> [HopAddition] {
        var schedule: [HopAddition] = []
        
        // 60 min bittering (60%)
        schedule.append(HopAddition(
            hopVariety: selectHopForStyle(style, usage: .bittering),
            amount: calculateHopAmount(targetIBU: targetIBU * 0.6, og: og, batchSize: batchSize, time: 60.0),
            time: 60.0,
            alphaAcid: 12.0,
            usage: .bittering,
            ibuContribution: targetIBU * 0.6
        ))
        
        // 20 min flavor (25%)
        schedule.append(HopAddition(
            hopVariety: selectHopForStyle(style, usage: .flavor),
            amount: calculateHopAmount(targetIBU: targetIBU * 0.25, og: og, batchSize: batchSize, time: 20.0),
            time: 20.0,
            alphaAcid: 8.0,
            usage: .flavor,
            ibuContribution: targetIBU * 0.25
        ))
        
        // 5 min aroma (15%)
        schedule.append(HopAddition(
            hopVariety: selectHopForStyle(style, usage: .aroma),
            amount: calculateHopAmount(targetIBU: targetIBU * 0.15, og: og, batchSize: batchSize, time: 5.0),
            time: 5.0,
            alphaAcid: 6.0,
            usage: .aroma,
            ibuContribution: targetIBU * 0.15
        ))
        
        // Whirlpool/steeping for aroma styles
        if style.flavorProfile.contains("Hoppy") {
            schedule.append(HopAddition(
                hopVariety: selectHopForStyle(style, usage: .whirlpool),
                amount: 30.0, // 30g for whirlpool
                time: 0.0, // Whirlpool addition
                alphaAcid: 5.0,
                usage: .whirlpool,
                ibuContribution: 0.0
            ))
        }
        
        return schedule
    }
}

class YeastDatabase {
    func selectOptimalYeast(
        for style: BJCPStyle,
        targetAttenuation: Double,
        targetABV: Double
    ) -> YeastSelection {
        
        // Style-specific yeast selection
        if style.category.contains("German") || style.category.contains("Czech") {
            if style.name.contains("Lager") {
                return YeastSelection(
                    strain: "Saflager W-34/70",
                    type: .lager,
                    attenuation: 83.0,
                    temperatureRange: 12...15,
                    flavorProfile: ["Clean", "Crisp", "Neutral"]
                )
            } else {
                return YeastSelection(
                    strain: "Safale K-97",
                    type: .wheat,
                    attenuation: 80.0,
                    temperatureRange: 15...20,
                    flavorProfile: ["Fruity", "Estery", "Banana"]
                )
            }
        } else if style.category.contains("English") || style.category.contains("British") {
            return YeastSelection(
                strain: "Safale S-04",
                type: .ale,
                attenuation: 75.0,
                temperatureRange: 15...20,
                flavorProfile: ["Fruity", "Estery", "Traditional"]
            )
        } else if style.category.contains("Belgian") {
            return YeastSelection(
                strain: "Safale T-58",
                type: .specialty,
                attenuation: 76.0,
                temperatureRange: 15...25,
                flavorProfile: ["Spicy", "Phenolic", "Complex"]
            )
        } else if style.category.contains("Nederlandse") {
            // Nederlandse gist selecties
            if style.name.contains("Lager") || style.name.contains("Pilsner") || style.name.contains("bock") {
                return YeastSelection(
                    strain: "Wyeast 2124 - Bohemian Lager",
                    type: .lager,
                    attenuation: 79.0,
                    temperatureRange: 9...15,
                    flavorProfile: ["Clean", "Crisp", "Malty", "Nederlands"]
                )
            } else if style.name.contains("Witbier") {
                return YeastSelection(
                    strain: "Lallemand LalBrew Wit",
                    type: .wheat,
                    attenuation: 82.0,
                    temperatureRange: 18...24,
                    flavorProfile: ["Fruity", "Spicy", "Traditional", "Nederlands"]
                )
            } else if style.name.contains("Oud Bruin") {
                return YeastSelection(
                    strain: "Wyeast 3763 - Roeselare",
                    type: .specialty,
                    attenuation: 70.0,
                    temperatureRange: 18...24,
                    flavorProfile: ["Sour", "Complex", "Funky", "Traditional"]
                )
            } else {
                return YeastSelection(
                    strain: "Lallemand LalBrew Voss Kveik",
                    type: .ale,
                    attenuation: 78.0,
                    temperatureRange: 15...22,
                    flavorProfile: ["Fruity", "Traditional", "Fast", "Nederlands"]
                )
            }
        } else {
            // American default
            return YeastSelection(
                strain: "Safale US-05",
                type: .ale,
                attenuation: 81.0,
                temperatureRange: 15...24,
                flavorProfile: ["Clean", "Neutral", "Versatile"]
            )
        }
    }
}

class AdditionalIngredientsDatabase {
    func selectForStyle(_ style: BJCPStyle, complexity: RecipeComplexity) -> [AdditionalIngredient] {
        var additionals: [AdditionalIngredient] = []
        
        // Simple complexity - minimal additions
        if complexity == .beginner {
            return additionals
        }
        
        // Style-specific additions
        if style.name.contains("Oatmeal") {
            additionals.append(AdditionalIngredient(
                name: "Irish Moss",
                amount: 5.0,
                unit: "g",
                additionTime: "15 min",
                purpose: "Clarity/Fining"
            ))
        }
        
        if style.name.contains("Porter") || style.name.contains("Stout") {
            additionals.append(AdditionalIngredient(
                name: "Gypsum",
                amount: 2.0,
                unit: "g",
                additionTime: "Mash",
                purpose: "Water Treatment"
            ))
        }
        
        if style.category.contains("Belgian") && complexity >= .advanced {
            additionals.append(AdditionalIngredient(
                name: "Coriander",
                amount: 15.0,
                unit: "g",
                additionTime: "5 min",
                purpose: "Spice Character"
            ))
            
            additionals.append(AdditionalIngredient(
                name: "Orange Peel",
                amount: 20.0,
                unit: "g",
                additionTime: "5 min",
                purpose: "Citrus Character"
            ))
        }
        
        // Nederlandse stijl specifieke ingrediënten
        if style.category.contains("Nederlandse") {
            if style.name.contains("Witbier") {
                additionals.append(AdditionalIngredient(
                    name: "Koriander (geheel)",
                    amount: 12.0,
                    unit: "g",
                    additionTime: "10 min",
                    purpose: "Nederlandse Witbier Kruidigheid"
                ))
                
                additionals.append(AdditionalIngredient(
                    name: "Curaçao Sinaasappelschil",
                    amount: 18.0,
                    unit: "g",
                    additionTime: "5 min",
                    purpose: "Nederlandse Citrus Karakter"
                ))
            }
            
            if style.name.contains("Bokbier") || style.name.contains("bock") {
                additionals.append(AdditionalIngredient(
                    name: "Kandijsuiker Donker",
                    amount: 200.0,
                    unit: "g",
                    additionTime: "Kook",
                    purpose: "Nederlandse Bock Zoethed"
                ))
            }
            
            if style.name.contains("Oud Bruin") {
                additionals.append(AdditionalIngredient(
                    name: "Lactobacillus",
                    amount: 1.0,
                    unit: "pak",
                    additionTime: "Na koeling",
                    purpose: "Nederlandse Zuring"
                ))
            }
            
            // Algemene Nederlandse water behandeling
            if complexity >= .intermediate {
                additionals.append(AdditionalIngredient(
                    name: "Gips (CaSO4)",
                    amount: 3.0,
                    unit: "g",
                    additionTime: "Maischen",
                    purpose: "Nederlands Water Profiel"
                ))
            }
        }
        
        // Always add standard brewing salts for intermediate+
        if complexity >= .intermediate {
            additionals.append(AdditionalIngredient(
                name: "Yeast Nutrient",
                amount: 2.5,
                unit: "g",
                additionTime: "15 min",
                purpose: "Yeast Health"
            ))
        }
        
        return additionals
    }
}

class RecipeOptimizer {
    func optimize(
        grainBill: [GrainIngredient],
        hops: [HopAddition],
        yeast: YeastSelection,
        additionals: [AdditionalIngredient],
        targetSpecs: RecipeSpecifications,
        style: BJCPStyle
    ) -> DetailedRecipe {
        
        // Convert grain bill to recipe ingredients
        let grainIngredients = grainBill.map { grain in
            RecipeIngredient(
                name: grain.name,
                amount: "\(String(format: "%.1f", grain.amount)) kg",
                type: .grain,
                timing: "Maischen"
            )
        }
        
        // Convert hops to recipe ingredients
        let hopIngredients = hops.map { hop in
            RecipeIngredient(
                name: hop.hopVariety,
                amount: "\(String(format: "%.0f", hop.amount)) g",
                type: .hop,
                timing: hop.time == 0 ? "Dry hop" : "\(Int(hop.time)) min"
            )
        }
        
        // Add yeast
        let yeastIngredient = RecipeIngredient(
            name: yeast.strain,
            amount: "1 pak",
            type: .yeast,
            timing: "Primaire fermentatie"
        )
        
        // Create comprehensive instructions
        let instructions = generateInstructions(
            style: style,
            grainBill: grainBill,
            hops: hops,
            yeast: yeast,
            targetSpecs: targetSpecs
        )
        
        // Determine difficulty based on ingredient complexity
        let difficulty: RecipeDifficulty = grainBill.count <= 2 ? .beginner : grainBill.count <= 4 ? .intermediate : .advanced
        
        // Create DetailedRecipe
        let recipe = DetailedRecipe(
            name: "AI Generated \(style.name)",
            style: style.name,
            abv: targetSpecs.targetABV,
            ibu: Int(targetSpecs.targetIBU),
            difficulty: difficulty,
            brewTime: 300, // 5 hours standard
            ingredients: grainIngredients + hopIngredients + [yeastIngredient],
            instructions: instructions,
            notes: generateRecipeNotes(style: style, yeast: yeast, complexity: targetSpecs)
        )
        
        return recipe
    }
    
    private func generateInstructions(
        style: BJCPStyle,
        grainBill: [GrainIngredient],
        hops: [HopAddition],
        yeast: YeastSelection,
        targetSpecs: RecipeSpecifications
    ) -> [String] {
        var instructions: [String] = []
        
        // Mashing
        instructions.append("Verwarm \(String(format: "%.1f", targetSpecs.batchSize * 0.8))L water naar 67°C")
        instructions.append("Voeg gemalen mout toe en maisch 60 minuten bij constante temperatuur")
        
        // Sparging
        instructions.append("Spoel de mout met 78°C water tot \(String(format: "%.1f", targetSpecs.batchSize))L wort")
        
        // Boiling and hops
        instructions.append("Breng de wort aan de kook")
        
        for hop in hops.sorted(by: { $0.time > $1.time }) {
            if hop.time == 0 {
                instructions.append("Voeg \(String(format: "%.0f", hop.amount))g \(hop.hopVariety) toe voor dry hopping na primaire fermentatie")
            } else {
                instructions.append("Voeg \(String(format: "%.0f", hop.amount))g \(hop.hopVariety) toe bij \(Int(hop.time)) minuten voor einde kook")
            }
        }
        
        // Cooling and fermentation
        instructions.append("Koel de wort naar \(Int(yeast.temperatureRange.lowerBound))°C")
        instructions.append("Voeg \(yeast.strain) gist toe")
        instructions.append("Fermenteer 7-14 dagen bij \(Int(yeast.temperatureRange.lowerBound))-\(Int(yeast.temperatureRange.upperBound))°C")
        
        // Packaging
        if style.name.contains("Lager") {
            instructions.append("Lager 4-6 weken bij 2-4°C")
            instructions.append("Bottelen met 6g/L suiker voor carbonatie")
        } else {
            instructions.append("Bottelen met 7g/L suiker voor carbonatie")
            instructions.append("Rijp 2-3 weken bij kamertemperatuur")
        }
        
        return instructions
    }
    
    private func generateRecipeNotes(style: BJCPStyle, yeast: YeastSelection, complexity: RecipeSpecifications) -> String {
        var notes = "🤖 AI Generated Recipe\n\n"
        notes += "📋 Style: \(style.name) (\(style.id))\n"
        notes += "🎯 Target ABV: \(String(format: "%.1f", complexity.targetABV))%\n"
        notes += "🌾 Target OG: \(String(format: "%.3f", complexity.targetOG))\n"
        notes += "🍯 Target FG: \(String(format: "%.3f", complexity.targetFG))\n"
        notes += "🌿 Target IBU: \(Int(complexity.targetIBU))\n"
        notes += "🎨 Target SRM: \(Int(complexity.targetSRM))\n\n"
        
        notes += "🦠 Yeast: \(yeast.strain)\n"
        notes += "🌡️ Fermentation: \(Int(yeast.temperatureRange.lowerBound))-\(Int(yeast.temperatureRange.upperBound))°C\n"
        notes += "📊 Expected Attenuation: \(String(format: "%.0f", yeast.attenuation))%\n\n"
        
        notes += "📝 Style Notes:\n\(style.description)\n\n"
        
        notes += "🎨 Flavor Profile: \(style.flavorProfile.joined(separator: ", "))\n\n"
        
        notes += "💡 AI Recommendations:\n"
        notes += "• Monitor fermentation temperature closely\n"
        notes += "• Consider dry hopping for hop-forward styles\n"
        notes += "• Age \(style.name.contains("Lager") ? "cold" : "at cellar temperature") for optimal flavor\n"
        
        return notes
    }
} 