//
//  BeerXMLManager.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 11/06/2025.
//

import Foundation
import CoreData

class BeerXMLManager: NSObject, XMLParserDelegate {
    
    // MARK: - Models for BeerXML
    struct BeerXMLRecipe {
        let name: String
        let type: String
        let brewer: String
        let asst_brewer: String
        let batchSize: Double // Liters
        let boilSize: Double // Liters
        let boilTime: Int // Minutes
        let efficiency: Double // Percentage
        let og: Double // Original Gravity
        let fg: Double // Final Gravity
        let abv: Double
        let ibu: Double
        let srm: Double
        let notes: String
        let ingredients: BeerXMLIngredients
        var mashProfile: BeerXMLMash?
        var fermentationSteps: [BeerXMLFermentation]
    }
    
    struct BeerXMLIngredients {
        var grains: [BeerXMLGrain]
        var hops: [BeerXMLHop]
        var yeasts: [BeerXMLYeast]
        var miscs: [BeerXMLMisc]
    }
    
    struct BeerXMLGrain {
        let name: String
        let amount: Double // kg
        let color: Double // SRM
        let type: String
        let origin: String
        let supplier: String
        let notes: String
        let coarseFineDiff: Double
        let moisture: Double
        let diastaticPower: Double
        let protein: Double
        let maxInBatch: Double
    }
    
    struct BeerXMLHop {
        let name: String
        let amount: Double // kg
        let alpha: Double // Alpha acid percentage
        let use: String // Boil, Dry Hop, First Wort, Aroma, Whirlpool
        let time: Int // Minutes
        let notes: String
        let type: String // Bittering, Aroma, Both
        let form: String // Pellet, Plug, Leaf
        let beta: Double
        let hsi: Double
        let origin: String
        let substitutes: String
        let humulene: Double
        let caryophyllene: Double
        let cohumulone: Double
        let myrcene: Double
    }
    
    struct BeerXMLYeast {
        let name: String
        let type: String // Ale, Lager, Wheat, Wine, Champagne
        let form: String // Liquid, Dry, Slant, Culture
        let amount: Double
        let laboratory: String
        let productId: String
        let minTemperature: Double
        let maxTemperature: Double
        let flocculation: String // Low, Medium, High, Very High
        let attenuation: Double
        let notes: String
        let bestFor: String
        let maxReuse: Int
        let addToSecondary: Bool
    }
    
    struct BeerXMLMisc {
        let name: String
        let type: String // Spice, Fining, Water Agent, Herb, Flavor, Other
        let use: String // Boil, Mash, Primary, Secondary, Bottling
        let time: Int // Minutes
        let amount: Double
        let notes: String
        let useFor: String
    }
    
    struct BeerXMLMash {
        let name: String
        let grainTemp: Double
        let tunTemp: Double
        let spargeTemp: Double
        let ph: Double
        let tunWeight: Double
        let tunSpecificHeat: Double
        let equipAdjust: Bool
        let notes: String
        let mashSteps: [BeerXMLMashStep]
    }
    
    struct BeerXMLMashStep {
        let name: String
        let type: String // Infusion, Temperature, Decoction
        let infuseAmount: Double
        let stepTemp: Double
        let stepTime: Int
        let rampTime: Int
        let endTemp: Double
        let desc: String
        let waterGrainRatio: Double
        let decoctionAmt: String
    }
    
    struct BeerXMLFermentation {
        let name: String
        let age: Int // Days
        let temp: Double
        let desc: String
    }
    
    // MARK: - Properties
    private var currentElement = ""
    private var currentValue = ""
    private var currentRecipe: BeerXMLRecipe?
    private var currentIngredients = BeerXMLIngredients(grains: [], hops: [], yeasts: [], miscs: [])
    private var currentGrain: BeerXMLGrain?
    private var currentHop: BeerXMLHop?
    private var currentYeast: BeerXMLYeast?
    private var currentMisc: BeerXMLMisc?
    private var currentMash: BeerXMLMash?
    private var currentFermentation: BeerXMLFermentation?
    private var parsedRecipes: [BeerXMLRecipe] = []
    
    // Progress tracking
    private var totalBytes: Int64 = 0
    private var processedBytes: Int64 = 0
    private var progressHandler: ((Double) -> Void)?
    
    // MARK: - Public Methods
    
    func parseXMLFile(at url: URL, progressHandler: @escaping (Double) -> Void) async throws -> [BeerXMLRecipe] {
        self.progressHandler = progressHandler
        self.parsedRecipes = []
        
        // Get file size for progress tracking
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        totalBytes = fileAttributes[.size] as? Int64 ?? 0
        processedBytes = 0
        
        // Create stream parser
        let stream = InputStream(url: url)!
        stream.open()
        defer { stream.close() }
        
        let parser = XMLParser(stream: stream)
        parser.delegate = self
        
        // Parse in chunks
        let chunkSize = 1024 * 32 // 32KB chunks
        var buffer = [UInt8](repeating: 0, count: chunkSize)
        
        while stream.hasBytesAvailable {
            let bytesRead = stream.read(&buffer, maxLength: chunkSize)
            if bytesRead < 0 {
                throw XMLError.streamError(stream.streamError)
            }
            if bytesRead == 0 {
                break
            }
            
            processedBytes += Int64(bytesRead)
            let progress = Double(processedBytes) / Double(totalBytes)
            await MainActor.run {
                progressHandler(progress)
            }
            
            if !parser.parse() {
                throw XMLError.parseError(parser.parserError)
            }
        }
        
        return parsedRecipes
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentValue = ""
        
        switch elementName {
        case "RECIPE":
            // Start new recipe
            currentRecipe = nil
            currentIngredients = BeerXMLIngredients(grains: [], hops: [], yeasts: [], miscs: [])
        case "FERMENTABLE":
            currentGrain = nil
        case "HOP":
            currentHop = nil
        case "YEAST":
            currentYeast = nil
        case "MISC":
            currentMisc = nil
        case "MASH":
            currentMash = nil
        case "FERMENTATION_STEP":
            currentFermentation = nil
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "RECIPE":
            if let recipe = currentRecipe {
                parsedRecipes.append(recipe)
            }
        case "FERMENTABLE":
            if let grain = currentGrain {
                var ingredients = currentIngredients
                ingredients.grains.append(grain)
                currentIngredients = ingredients
            }
        case "HOP":
            if let hop = currentHop {
                var ingredients = currentIngredients
                ingredients.hops.append(hop)
                currentIngredients = ingredients
            }
        case "YEAST":
            if let yeast = currentYeast {
                var ingredients = currentIngredients
                ingredients.yeasts.append(yeast)
                currentIngredients = ingredients
            }
        case "MISC":
            if let misc = currentMisc {
                var ingredients = currentIngredients
                ingredients.miscs.append(misc)
                currentIngredients = ingredients
            }
        case "MASH":
            if let mash = currentMash {
                // Update current recipe with mash profile
                if var recipe = currentRecipe {
                    recipe.mashProfile = mash
                    currentRecipe = recipe
                }
            }
        case "FERMENTATION_STEP":
            if let fermentation = currentFermentation {
                // Update current recipe with fermentation step
                if var recipe = currentRecipe {
                    var steps = recipe.fermentationSteps
                    steps.append(fermentation)
                    recipe.fermentationSteps = steps
                    currentRecipe = recipe
                }
            }
        default:
            parseValue(for: elementName)
        }
    }
    
    // MARK: - Error Handling
    
    enum XMLError: Error {
        case streamError(Error?)
        case parseError(Error?)
        case invalidFormat(String)
    }
    
    private func parseValue(for element: String) {
        let value = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle different elements based on context
        switch element {
        case "NAME":
            if currentRecipe == nil {
                // This is the recipe name
                currentRecipe = BeerXMLRecipe(
                    name: value,
                    type: "",
                    brewer: "",
                    asst_brewer: "",
                    batchSize: 0,
                    boilSize: 0,
                    boilTime: 0,
                    efficiency: 0,
                    og: 0,
                    fg: 0,
                    abv: 0,
                    ibu: 0,
                    srm: 0,
                    notes: "",
                    ingredients: currentIngredients,
                    mashProfile: nil,
                    fermentationSteps: []
                )
            }
        // Add more cases for other elements
        default:
            break
        }
    }
    
    // MARK: - Export to BeerXML
    static func exportRecipe(_ recipe: DetailedRecipeModel) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <RECIPES>
            <RECIPE>
                <n>\(recipe.wrappedName.xmlEscaped)</n>
                <TYPE>All Grain</TYPE>
                <BREWER>\(recipe.wrappedBrewer.xmlEscaped)</BREWER>
                <BATCH_SIZE>\(String(format: "%.2f", recipe.batchSize))</BATCH_SIZE>
                <BOIL_SIZE>\(String(format: "%.2f", recipe.boilSize))</BOIL_SIZE>
                <BOIL_TIME>\(recipe.boilTime)</BOIL_TIME>
                <EFFICIENCY>\(String(format: "%.1f", recipe.efficiency))</EFFICIENCY>
                <OG>\(String(format: "%.3f", recipe.originalGravity))</OG>
                <FG>\(String(format: "%.3f", recipe.finalGravity))</FG>
                <ABV>\(String(format: "%.2f", recipe.abv))</ABV>
                <IBU>\(String(format: "%.1f", recipe.bitterness))</IBU>
                <SRM>\(String(format: "%.1f", recipe.color))</SRM>
                <STYLE>
                    <n>\(recipe.wrappedType.xmlEscaped)</n>
                    <CATEGORY>Custom</CATEGORY>
                    <VERSION>1</VERSION>
                    <CATEGORY_NUMBER>99</CATEGORY_NUMBER>
                    <STYLE_LETTER>A</STYLE_LETTER>
                    <STYLE_GUIDE>Custom</STYLE_GUIDE>
                    <TYPE>Ale</TYPE>
                    <OG_MIN>1.040</OG_MIN>
                    <OG_MAX>1.060</OG_MAX>
                    <FG_MIN>1.008</FG_MIN>
                    <FG_MAX>1.016</FG_MAX>
                    <IBU_MIN>20</IBU_MIN>
                    <IBU_MAX>40</IBU_MAX>
                    <SRM_MIN>4</SRM_MIN>
                    <SRM_MAX>12</SRM_MAX>
                    <CARB_MIN>2.2</CARB_MIN>
                    <CARB_MAX>2.8</CARB_MAX>
                    <ABV_MIN>4.0</ABV_MIN>
                    <ABV_MAX>6.0</ABV_MAX>
                    <NOTES>\(recipe.wrappedType.xmlEscaped)</NOTES>
                </STYLE>
                <NOTES>\(recipe.wrappedNotes.xmlEscaped)</NOTES>
        """
        
        // Add ingredients
        xml += """
        
                <HOPS>
        """
        
        let hops = recipe.ingredientsArray.filter { $0.wrappedType == "hop" }
        for hop in hops {
            xml += """
            
                    <HOP>
                        <n>\(hop.wrappedName.xmlEscaped)</n>
                        <VERSION>1</VERSION>
                        <ALPHA>5.0</ALPHA>
                        <AMOUNT>\(String(format: "%.3f", extractWeight(from: hop.wrappedAmount)))</AMOUNT>
                        <USE>Boil</USE>
                        <TIME>60</TIME>
                        <NOTES>\(hop.wrappedTiming.xmlEscaped)</NOTES>
                        <TYPE>Both</TYPE>
                        <FORM>Pellet</FORM>
                        <BETA>4.0</BETA>
                        <HSI>35</HSI>
                        <ORIGIN>Unknown</ORIGIN>
                    </HOP>
            """
        }
        
        xml += """
        
                </HOPS>
                <FERMENTABLES>
        """
        
        let grains = recipe.ingredientsArray.filter { $0.wrappedType == "grain" }
        for grain in grains {
            xml += """
            
                    <FERMENTABLE>
                        <n>\(grain.wrappedName.xmlEscaped)</n>
                        <VERSION>1</VERSION>
                        <TYPE>Grain</TYPE>
                        <AMOUNT>\(String(format: "%.3f", extractWeight(from: grain.wrappedAmount)))</AMOUNT>
                        <YIELD>80.0</YIELD>
                        <COLOR>2.0</COLOR>
                        <ADD_AFTER_BOIL>FALSE</ADD_AFTER_BOIL>
                        <ORIGIN>Unknown</ORIGIN>
                        <SUPPLIER>Unknown</SUPPLIER>
                        <NOTES>\(grain.wrappedTiming.xmlEscaped)</NOTES>
                        <COARSE_FINE_DIFF>1.5</COARSE_FINE_DIFF>
                        <MOISTURE>4.0</MOISTURE>
                        <DIASTATIC_POWER>0.0</DIASTATIC_POWER>
                        <PROTEIN>11.0</PROTEIN>
                        <MAX_IN_BATCH>100.0</MAX_IN_BATCH>
                    </FERMENTABLE>
            """
        }
        
        xml += """
        
                </FERMENTABLES>
                <YEASTS>
        """
        
        let yeasts = recipe.ingredientsArray.filter { $0.wrappedType == "yeast" }
        for yeast in yeasts {
            xml += """
            
                    <YEAST>
                        <n>\(yeast.wrappedName.xmlEscaped)</n>
                        <VERSION>1</VERSION>
                        <TYPE>Ale</TYPE>
                        <FORM>Liquid</FORM>
                        <AMOUNT>0.1</AMOUNT>
                        <AMOUNT_IS_WEIGHT>FALSE</AMOUNT_IS_WEIGHT>
                        <LABORATORY>Unknown</LABORATORY>
                        <PRODUCT_ID>Unknown</PRODUCT_ID>
                        <MIN_TEMPERATURE>18.0</MIN_TEMPERATURE>
                        <MAX_TEMPERATURE>22.0</MAX_TEMPERATURE>
                        <FLOCCULATION>Medium</FLOCCULATION>
                        <ATTENUATION>75.0</ATTENUATION>
                        <NOTES>\(yeast.wrappedTiming.xmlEscaped)</NOTES>
                        <BEST_FOR>Ales</BEST_FOR>
                        <MAX_REUSE>5</MAX_REUSE>
                        <ADD_TO_SECONDARY>FALSE</ADD_TO_SECONDARY>
                    </YEAST>
            """
        }
        
        xml += """
        
                </YEASTS>
                <MISCS>
        """
        
        let miscs = recipe.ingredientsArray.filter { $0.wrappedType == "other" }
        for misc in miscs {
            xml += """
            
                    <MISC>
                        <n>\(misc.wrappedName.xmlEscaped)</n>
                        <VERSION>1</VERSION>
                        <TYPE>Other</TYPE>
                        <USE>Boil</USE>
                        <TIME>15</TIME>
                        <AMOUNT>\(String(format: "%.3f", extractWeight(from: misc.wrappedAmount)))</AMOUNT>
                        <NOTES>\(misc.wrappedTiming.xmlEscaped)</NOTES>
                        <USE_FOR>Flavor</USE_FOR>
                    </MISC>
            """
        }
        
        xml += """
        
                </MISCS>
                <EQUIPMENT>
                    <n>Standard Equipment</n>
                    <VERSION>1</VERSION>
                    <BOIL_SIZE>27.0</BOIL_SIZE>
                    <BATCH_SIZE>23.0</BATCH_SIZE>
                    <TUN_VOLUME>30.0</TUN_VOLUME>
                    <TUN_WEIGHT>5.0</TUN_WEIGHT>
                    <TUN_SPECIFIC_HEAT>0.3</TUN_SPECIFIC_HEAT>
                    <TOP_UP_WATER>0.0</TOP_UP_WATER>
                    <TRUB_CHILLER_LOSS>1.0</TRUB_CHILLER_LOSS>
                    <EVAP_RATE>10.0</EVAP_RATE>
                    <BOIL_TIME>60</BOIL_TIME>
                    <CALC_BOIL_VOLUME>TRUE</CALC_BOIL_VOLUME>
                    <LAUTER_DEADSPACE>1.0</LAUTER_DEADSPACE>
                    <TOP_UP_KETTLE>0.0</TOP_UP_KETTLE>
                    <HOP_UTILIZATION>100.0</HOP_UTILIZATION>
                    <NOTES>Standard home brewing equipment</NOTES>
                </EQUIPMENT>
            </RECIPE>
        </RECIPES>
        """
        
        return xml
    }
    
    // MARK: - Import from BeerXML
    static func importRecipes(from xmlData: Data) -> [DetailedRecipeModel] {
        let manager = BeerXMLManager()
        let parser = XMLParser(data: xmlData)
        parser.delegate = manager
        
        if parser.parse() {
            print("✅ XML parsing successful. Found \(manager.parsedRecipes.count) recipes")
            return manager.parsedRecipes.compactMap { convertToDetailedRecipe($0) }
        } else {
            print("❌ XML parsing failed")
            if let error = parser.parserError {
                print("Parser error: \(error.localizedDescription)")
            }
            
            // Try to parse as simple text format or fallback
            let xmlString = String(data: xmlData, encoding: .utf8) ?? ""
            print("XML content preview: \(String(xmlString.prefix(200)))")
            
            // Return empty array if parsing fails
            return []
        }
    }
    
    // MARK: - Conversion Helpers
    private static func convertToDetailedRecipe(_ beerXMLRecipe: BeerXMLRecipe) -> DetailedRecipeModel? {
        let viewContext = PersistenceController.shared.container.viewContext
        let recipe = DetailedRecipeModel(context: viewContext)
        
        // Basic recipe info
        recipe.id = UUID()
        recipe.name = beerXMLRecipe.name
        recipe.type = beerXMLRecipe.type
        recipe.brewer = beerXMLRecipe.brewer
        recipe.batchSize = beerXMLRecipe.batchSize
        recipe.boilSize = beerXMLRecipe.boilSize
        recipe.boilTime = Int16(beerXMLRecipe.boilTime)
        recipe.efficiency = beerXMLRecipe.efficiency
        recipe.originalGravity = beerXMLRecipe.og
        recipe.finalGravity = beerXMLRecipe.fg
        recipe.abv = beerXMLRecipe.abv
        recipe.bitterness = beerXMLRecipe.ibu
        recipe.color = beerXMLRecipe.srm
        recipe.notes = beerXMLRecipe.notes
        recipe.createdAt = Date()
        recipe.updatedAt = Date()
        
        // Convert ingredients
        let ingredients = convertIngredients(beerXMLRecipe.ingredients, for: recipe, in: viewContext)
        recipe.addToIngredients(NSSet(array: ingredients))
        
        // Convert fermentation steps
        let fermentationSteps = beerXMLRecipe.fermentationSteps.map { step in
            convertFermentationStep(step, for: recipe, in: viewContext)
        }
        recipe.addToFermentationSteps(NSSet(array: fermentationSteps))
        
        return recipe
    }
    
    private static func convertIngredients(_ beerXMLIngredients: BeerXMLIngredients, for recipe: DetailedRecipeModel, in context: NSManagedObjectContext) -> [Ingredient] {
        var ingredients: [Ingredient] = []
        
        // Convert grains
        ingredients += beerXMLIngredients.grains.map { grain in
            let ingredient = Ingredient(context: context)
            ingredient.id = UUID()
            ingredient.name = grain.name
            ingredient.type = "grain"
            ingredient.amount = String(grain.amount)
            ingredient.timing = grain.notes
            ingredient.recipe = recipe
            return ingredient
        }
        
        // Convert hops
        ingredients += beerXMLIngredients.hops.map { hop in
            let ingredient = Ingredient(context: context)
            ingredient.id = UUID()
            ingredient.name = hop.name
            ingredient.type = "hop"
            ingredient.amount = String(hop.amount)
            ingredient.timing = "\(hop.time) minutes (\(hop.use))"
            ingredient.recipe = recipe
            return ingredient
        }
        
        // Convert yeasts
        ingredients += beerXMLIngredients.yeasts.map { yeast in
            let ingredient = Ingredient(context: context)
            ingredient.id = UUID()
            ingredient.name = yeast.name
            ingredient.type = "yeast"
            ingredient.amount = String(yeast.amount)
            ingredient.timing = yeast.notes
            ingredient.recipe = recipe
            return ingredient
        }
        
        // Convert misc ingredients
        ingredients += beerXMLIngredients.miscs.map { misc in
            let ingredient = Ingredient(context: context)
            ingredient.id = UUID()
            ingredient.name = misc.name
            ingredient.type = "other"
            ingredient.amount = String(misc.amount)
            ingredient.timing = "\(misc.time) minutes (\(misc.use))"
            ingredient.recipe = recipe
            return ingredient
        }
        
        return ingredients
    }
    
    private static func convertFermentationStep(_ beerXMLFermentation: BeerXMLFermentation, for recipe: DetailedRecipeModel, in context: NSManagedObjectContext) -> FermentationStep {
        let step = FermentationStep(context: context)
        step.id = UUID()
        step.name = beerXMLFermentation.name
        step.duration = Int16(beerXMLFermentation.age)
        step.temperature = beerXMLFermentation.temp
        step.stepDescription = beerXMLFermentation.desc
        step.recipe = recipe
        return step
    }
    
    // MARK: - Helper functions
    private static func extractWeight(from amountString: String) -> Double {
        let components = amountString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let numbers = components.compactMap { Double($0) }
        return numbers.first ?? 0.0
    }
}

// MARK: - String Extension for XML Escaping
extension String {
    var xmlEscaped: String {
        return self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "'", with: "&apos;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
} 