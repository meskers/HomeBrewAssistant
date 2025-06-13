import Foundation

class BJCPDatabase {
    
    var allStyles: [BJCPStyle] {
        return popularStyles + allGrainStyles + extractStyles + dutchStyles
    }
    
    // MARK: - Popular Homebrew Styles
    private let popularStyles: [BJCPStyle] = [
        // 10A - American IPA
        BJCPStyle(
            id: "10A",
            name: "American IPA",
            category: "American Ale",
            abvRange: 5.5...7.5,
            ibuRange: 40...70,
            srmRange: 6...14,
            ogRange: 1.056...1.070,
            fgRange: 1.008...1.014,
            description: "A decidedly hoppy and bitter, moderately strong American pale ale, showcasing modern American or New World hop varieties.",
            characteristicIngredients: ["Pale Malt", "American Hops", "American Ale Yeast", "Crystal Malt"],
            flavorProfile: ["Hoppy", "Bitter", "Citrusy", "Piney", "Floral", "Clean"],
            complexity: .intermediate
        ),
        
        // 11A - Ordinary Bitter
        BJCPStyle(
            id: "11A",
            name: "Ordinary Bitter",
            category: "British Bitter",
            abvRange: 3.2...3.8,
            ibuRange: 25...35,
            srmRange: 4...14,
            ogRange: 1.030...1.039,
            fgRange: 1.007...1.011,
            description: "Low gravity, alcohol, and carbonation make this an easy-drinking session beer.",
            characteristicIngredients: ["Pale Malt", "English Hops", "English Ale Yeast", "Crystal Malt"],
            flavorProfile: ["Malty", "Hoppy", "Balanced", "Session", "Traditional"],
            complexity: .beginner
        ),
        
        // 1B - American Light Lager  
        BJCPStyle(
            id: "1B",
            name: "American Light Lager",
            category: "Standard American Beer",
            abvRange: 2.8...4.2,
            ibuRange: 8...12,
            srmRange: 2...3,
            ogRange: 1.028...1.040,
            fgRange: 1.003...1.008,
            description: "Highly carbonated, very light-bodied, nearly flavorless lager.",
            characteristicIngredients: ["6-row Pale Malt", "Rice", "Corn", "American Lager Yeast"],
            flavorProfile: ["Light", "Clean", "Crisp", "Neutral", "Refreshing"],
            complexity: .beginner
        ),
        
        // 19B - California Common
        BJCPStyle(
            id: "19B",
            name: "California Common",
            category: "Amber and Brown American Beer",
            abvRange: 4.5...5.5,
            ibuRange: 30...45,
            srmRange: 10...14,
            ogRange: 1.048...1.054,
            fgRange: 1.011...1.014,
            description: "A lightly fruity beer with firm, grainy maltiness, interesting toasty and caramel flavors.",
            characteristicIngredients: ["Pale Malt", "Crystal Malt", "Northern Brewer Hops", "California Lager Yeast"],
            flavorProfile: ["Toasty", "Caramel", "Fruity", "Woody", "Unique"],
            complexity: .intermediate
        ),
        
        // 20A - American Porter
        BJCPStyle(
            id: "20A",
            name: "American Porter",
            category: "American Porter and Stout",
            abvRange: 4.8...6.5,
            ibuRange: 25...50,
            srmRange: 22...40,
            ogRange: 1.050...1.070,
            fgRange: 1.012...1.018,
            description: "A substantial, malty dark beer with a complex and flavorful dark malt character.",
            characteristicIngredients: ["Pale Malt", "Crystal Malt", "Chocolate Malt", "Black Patent", "American Hops"],
            flavorProfile: ["Roasted", "Chocolate", "Coffee", "Dark", "Complex"],
            complexity: .intermediate
        )
    ]
    
    // MARK: - All Grain Advanced Styles
    private let allGrainStyles: [BJCPStyle] = [
        // 3B - Czech Premium Pale Lager
        BJCPStyle(
            id: "3B",
            name: "Czech Premium Pale Lager",
            category: "Czech Lager",
            abvRange: 4.2...5.8,
            ibuRange: 30...45,
            srmRange: 3.5...6,
            ogRange: 1.044...1.060,
            fgRange: 1.013...1.017,
            description: "Rich, characterful, pale Czech lager, with considerable malt and hop character.",
            characteristicIngredients: ["Pilsner Malt", "Saaz Hops", "Czech Lager Yeast", "Soft Water"],
            flavorProfile: ["Spicy", "Floral", "Bready", "Complex", "Traditional"],
            complexity: .advanced
        ),
        
        // 16B - Oatmeal Stout
        BJCPStyle(
            id: "16B",
            name: "Oatmeal Stout",
            category: "Sweet Stout",
            abvRange: 4.2...5.9,
            ibuRange: 25...40,
            srmRange: 22...40,
            ogRange: 1.045...1.065,
            fgRange: 1.010...1.018,
            description: "A very dark, full-bodied, roasty, malty ale with a complementary oatmeal flavor.",
            characteristicIngredients: ["Pale Malt", "Oats", "Roasted Barley", "Crystal Malt", "English Hops"],
            flavorProfile: ["Smooth", "Creamy", "Roasted", "Nutty", "Full-bodied"],
            complexity: .advanced
        ),
        
        // 25B - Saison
        BJCPStyle(
            id: "25B",
            name: "Saison",
            category: "Belgian Ale",
            abvRange: 5.0...7.0,
            ibuRange: 20...35,
            srmRange: 5...14,
            ogRange: 1.048...1.065,
            fgRange: 1.002...1.012,
            description: "Most commonly a golden-colored ale with a distinctive yeast character.",
            characteristicIngredients: ["Pilsner Malt", "European Hops", "Saison Yeast", "Spices"],
            flavorProfile: ["Spicy", "Fruity", "Peppery", "Dry", "Complex"],
            complexity: .expert
        )
    ]
    
    // MARK: - Extract-Friendly Beginner Styles
    private let extractStyles: [BJCPStyle] = [
        // 5B - Kölsch
        BJCPStyle(
            id: "5B",
            name: "Kölsch",
            category: "Pale Bitter European Beer",
            abvRange: 4.4...5.2,
            ibuRange: 18...30,
            srmRange: 3.5...5,
            ogRange: 1.044...1.050,
            fgRange: 1.007...1.011,
            description: "A clean, crisp, delicately-balanced beer usually with a very subtle fruit flavor.",
            characteristicIngredients: ["Pilsner Malt", "German Hops", "Kölsch Yeast", "Wheat"],
            flavorProfile: ["Clean", "Crisp", "Subtle", "Delicate", "Refreshing"],
            complexity: .beginner
        ),
        
        // 18A - Blonde Ale
        BJCPStyle(
            id: "18A",
            name: "Blonde Ale",
            category: "Pale American Ale",
            abvRange: 3.8...5.5,
            ibuRange: 15...28,
            srmRange: 3...6,
            ogRange: 1.038...1.054,
            fgRange: 1.008...1.013,
            description: "Easy-drinking, approachable, malt-oriented American craft beer.",
            characteristicIngredients: ["Pale Malt", "American Hops", "American Ale Yeast", "Crystal Malt"],
            flavorProfile: ["Malty", "Smooth", "Easy-drinking", "Approachable", "Clean"],
            complexity: .beginner
        ),
        
        // 1A - American Light Lager (Extract Version)
        BJCPStyle(
            id: "1A-Extract",
            name: "American Lager (Extract)",
            category: "Standard American Beer",
            abvRange: 4.2...5.3,
            ibuRange: 8...18,
            srmRange: 2...4,
            ogRange: 1.040...1.050,
            fgRange: 1.004...1.010,
            description: "A very pale, highly-carbonated, light-bodied, well-attenuated lager.",
            characteristicIngredients: ["Light Malt Extract", "Rice Extract", "American Hops", "Lager Yeast"],
            flavorProfile: ["Clean", "Crisp", "Light", "Refreshing", "Neutral"],
            complexity: .beginner
        )
    ]
    
    // MARK: - Nederlandse Bier Keurmeestersgilde Styles
    private let dutchStyles: [BJCPStyle] = [
        // Nederlandse Pilsner
        BJCPStyle(
            id: "NL-1",
            name: "Nederlandse Pilsner",
            category: "Nederlandse Lager",
            abvRange: 4.8...5.5,
            ibuRange: 25...35,
            srmRange: 3...6,
            ogRange: 1.044...1.052,
            fgRange: 1.008...1.014,
            description: "Een heldere, goudkleurige lager met een uitgesproken hopkarakter en frisse afdronk, kenmerkend voor Nederlandse brouwtradities.",
            characteristicIngredients: ["Pilsner Malt", "Nederlandse Hop", "Lager Gist", "Zacht Water"],
            flavorProfile: ["Hop", "Fris", "Droog", "Helder", "Traditioneel"],
            complexity: .intermediate
        ),
        
        // Bokbier
        BJCPStyle(
            id: "NL-2",
            name: "Bokbier",
            category: "Nederlandse Seizoensbieren",
            abvRange: 6.0...7.5,
            ibuRange: 15...25,
            srmRange: 12...25,
            ogRange: 1.060...1.074,
            fgRange: 1.012...1.020,
            description: "Een amber tot donkerbruin seizoensbier, traditioneel gebrouwen in de herfst met volle moutsmaak en zachte afdronk.",
            characteristicIngredients: ["Munich Malt", "Crystal Malt", "Nederlandse Hop", "Ale Gist"],
            flavorProfile: ["Moutig", "Zoet", "Karamel", "Seizoens", "Vol"],
            complexity: .intermediate
        ),
        
        // Nederlands Witbier
        BJCPStyle(
            id: "NL-3",
            name: "Nederlands Witbier",
            category: "Nederlandse Tarwebieren",
            abvRange: 4.5...5.5,
            ibuRange: 10...20,
            srmRange: 2...4,
            ogRange: 1.044...1.052,
            fgRange: 1.008...1.014,
            description: "Een licht, verfrissend tarwebier met subtiele kruiden en citrustoetsen, eigen aan de Nederlandse brouwtraditie.",
            characteristicIngredients: ["Tarwemout", "Pilsner Malt", "Koriander", "Sinaasappelschil", "Witbier Gist"],
            flavorProfile: ["Fris", "Kruidig", "Citrus", "Zacht", "Verfrissend"],
            complexity: .beginner
        ),
        
        // Nederlandse IPA
        BJCPStyle(
            id: "NL-4",
            name: "Nederlandse IPA",
            category: "Nederlandse Craft Beer",
            abvRange: 5.5...7.0,
            ibuRange: 40...65,
            srmRange: 6...12,
            ogRange: 1.055...1.068,
            fgRange: 1.010...1.016,
            description: "Een moderne Nederlandse interpretatie van IPA met lokale hop variëteiten en eigen karakter.",
            characteristicIngredients: ["Pale Malt", "Nederlandse Hop", "Crystal Malt", "Ale Gist"],
            flavorProfile: ["Hoppy", "Fruitig", "Bitter", "Lokaal", "Modern"],
            complexity: .advanced
        ),
        
        // Dubbelbock
        BJCPStyle(
            id: "NL-5",
            name: "Dubbelbock",
            category: "Nederlandse Sterke Bieren",
            abvRange: 7.0...9.0,
            ibuRange: 16...26,
            srmRange: 18...35,
            ogRange: 1.072...1.092,
            fgRange: 1.016...1.024,
            description: "Een donker, sterk lager met rijke moutsmaak en warme alcohol sensatie, perfect voor koude Nederlandse winters.",
            characteristicIngredients: ["Munich Malt", "Chocolate Malt", "Crystal Malt", "Lager Gist"],
            flavorProfile: ["Rijk", "Moutig", "Warm", "Donker", "Stevig"],
            complexity: .expert
        ),
        
        // Meibock
        BJCPStyle(
            id: "NL-6",
            name: "Meibock",
            category: "Nederlandse Seizoensbieren",
            abvRange: 6.3...7.4,
            ibuRange: 23...35,
            srmRange: 6...11,
            ogRange: 1.064...1.072,
            fgRange: 1.011...1.018,
            description: "Een goudkleurige, sterke lager gebrouwen voor de lente, met meer hop dan traditionele bockbieren.",
            characteristicIngredients: ["Pilsner Malt", "Munich Malt", "Nederlandse Hop", "Lager Gist"],
            flavorProfile: ["Goudkleurig", "Lente", "Hoppy", "Stevig", "Fris"],
            complexity: .advanced
        ),
        
        // Oud Bruin
        BJCPStyle(
            id: "NL-7",
            name: "Oud Bruin",
            category: "Nederlandse Traditionele Bieren",
            abvRange: 4.0...5.5,
            ibuRange: 15...25,
            srmRange: 15...25,
            ogRange: 1.042...1.055,
            fgRange: 1.008...1.014,
            description: "Een donkerbruin ale met milde zuurheid en complexe gist karakters, een traditionele Nederlandse stijl.",
            characteristicIngredients: ["Munich Malt", "Crystal Malt", "Zure Gist", "Gemengde Gisting"],
            flavorProfile: ["Zuur", "Complex", "Donker", "Traditioneel", "Mild"],
            complexity: .expert
        ),
        
        // Herfstbok
        BJCPStyle(
            id: "NL-8",
            name: "Herfstbok",
            category: "Nederlandse Seizoensbieren",
            abvRange: 6.0...7.0,
            ibuRange: 20...28,
            srmRange: 14...22,
            ogRange: 1.058...1.068,
            fgRange: 1.012...1.018,
            description: "Een amber-kleurig seizoensbier voor de herfst, met rijke moutsmaak en subtiele hop aroma's.",
            characteristicIngredients: ["Munich Malt", "Crystal Malt", "Chocolate Malt", "Nederlandse Hop"],
            flavorProfile: ["Amber", "Herfst", "Moutig", "Warm", "Gekruid"],
            complexity: .intermediate
        )
    ]
    
    // MARK: - Helper Functions
    func getStyle(by id: String) -> BJCPStyle? {
        return allStyles.first { $0.id == id }
    }
    
    func getStylesByCategory(_ category: String) -> [BJCPStyle] {
        return allStyles.filter { $0.category == category }
    }
    
    func getStylesByComplexity(_ complexity: RecipeComplexity) -> [BJCPStyle] {
        return allStyles.filter { $0.complexity == complexity }
    }
    
    func searchStyles(query: String) -> [BJCPStyle] {
        let lowercaseQuery = query.lowercased()
        return allStyles.filter { style in
            style.name.lowercased().contains(lowercaseQuery) ||
            style.category.lowercased().contains(lowercaseQuery) ||
            style.flavorProfile.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }
    
    var categories: [String] {
        return Array(Set(allStyles.map { $0.category })).sorted()
    }
    
    var beginnerFriendlyStyles: [BJCPStyle] {
        return allStyles.filter { $0.complexity == .beginner }
    }
    
    var intermediateStyles: [BJCPStyle] {
        return allStyles.filter { $0.complexity == .intermediate }
    }
    
    var advancedStyles: [BJCPStyle] {
        return allStyles.filter { $0.complexity == .advanced || $0.complexity == .expert }
    }
} 