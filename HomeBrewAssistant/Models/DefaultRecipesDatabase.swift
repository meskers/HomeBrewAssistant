import Foundation

class DefaultRecipesDatabase {
    static func getAllDefaultRecipes() -> [DetailedRecipe] {
        return [
            simpleBeer(),
            hefeweizen(),
            belgischeDubbel(),
            irishStout(),
            americanPaleAle(),
            oktoberfest(),
            porter(),
            kolsch()
        ]
    }
    
    private static func simpleBeer() -> DetailedRecipe {
        DetailedRecipe(
            name: "Eenvoudig Bier",
            style: "American Wheat", 
            abv: 4.5,
            ibu: 15,
            difficulty: .beginner,
            brewTime: 180,
            ingredients: [
                RecipeIngredient(name: "Tarwemout", amount: "2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Pilsner Mout", amount: "2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Hallertau Hop", amount: "20 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "SafBrew WB-06", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Mash op 64°C voor 60 minuten",
                "Spoel met 78°C water", 
                "Kook 60 minuten",
                "Fermenteer op 20°C"
            ],
            notes: "🌟 Perfect voor beginners. Licht, verfrissend tarwebier met 97% slaagkans!"
        )
    }
    
    private static func hefeweizen() -> DetailedRecipe {
        DetailedRecipe(
            name: "Hefeweizen",
            style: "German Hefeweizen",
            abv: 5.2,
            ibu: 12,
            difficulty: .beginner,
            brewTime: 200,
            ingredients: [
                RecipeIngredient(name: "Wheat Malt", amount: "2.5 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Pilsner Malt", amount: "2.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Hallertau Blanc", amount: "18 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Safbrew WB-06", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Infusion mash op 64°C",
                "Decoction optioneel voor traditie",
                "Fermenteer warm voor esters"
            ],
            notes: "Klassieke Duitse tarwebier met banaan en kruidnagel aroma's."
        )
    }
    
    private static func belgischeDubbel() -> DetailedRecipe {
        DetailedRecipe(
            name: "Belgische Dubbel",
            style: "Belgian Dubbel",
            abv: 7.2,
            ibu: 20,
            difficulty: .intermediate,
            brewTime: 270,
            ingredients: [
                RecipeIngredient(name: "Pilsner Mout", amount: "4.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Munich Malt", amount: "0.5 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Special B", amount: "0.3 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Candi Suiker (donker)", amount: "0.5 kg", type: .other, timing: "15 min"),
                RecipeIngredient(name: "Styrian Goldings", amount: "25 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "SafSpirit M-31", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Single infusion mash op 65°C",
                "Voeg candi suiker toe laatste 15 min kook",
                "Fermenteer bij 24°C voor complexiteit"
            ],
            notes: "Rijke, donkere Belgische ale met rozijn en pruimentonen."
        )
    }
    
    private static func irishStout() -> DetailedRecipe {
        DetailedRecipe(
            name: "Irish Stout",
            style: "Irish Dry Stout",
            abv: 4.3,
            ibu: 45,
            difficulty: .intermediate,
            brewTime: 210,
            ingredients: [
                RecipeIngredient(name: "Pale Ale Malt", amount: "3.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Roasted Barley", amount: "0.4 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Flaked Barley", amount: "0.3 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "East Kent Goldings", amount: "30 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Fuggle", amount: "15 g", type: .hop, timing: "30 min"),
                RecipeIngredient(name: "SafAle S-04", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Mash op 67°C voor meer body",
                "Gebruik stikstof voor cremige schuimkraag",
                "Serveer op temperatuur van de kelder"
            ],
            notes: "Klassieke droge stout met koffie en chocolade tonen."
        )
    }
    
    private static func americanPaleAle() -> DetailedRecipe {
        DetailedRecipe(
            name: "American Pale Ale",
            style: "American Pale Ale",
            abv: 5.8,
            ibu: 35,
            difficulty: .intermediate,
            brewTime: 210,
            ingredients: [
                RecipeIngredient(name: "2-Row Pale Malt", amount: "4.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Crystal 40L", amount: "0.3 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Cascade", amount: "25 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Cascade", amount: "20 g", type: .hop, timing: "15 min"),
                RecipeIngredient(name: "Centennial", amount: "15 g", type: .hop, timing: "0 min"),
                RecipeIngredient(name: "SafAle US-05", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Mash op 65°C voor droge afdronk",
                "Amerikaanse hop showcase",
                "Fermenteer schoon bij 18°C"
            ],
            notes: "Klassieke Amerikaanse pale ale met citrus hop karakter."
        )
    }
    
    private static func oktoberfest() -> DetailedRecipe {
        DetailedRecipe(
            name: "Oktoberfest",
            style: "Märzen",
            abv: 5.7,
            ibu: 25,
            difficulty: .intermediate,
            brewTime: 300,
            ingredients: [
                RecipeIngredient(name: "Munich Malt", amount: "3.5 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Vienna Malt", amount: "1.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Hallertau", amount: "30 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "SafLager W-34/70", amount: "2 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Decoction mash voor traditie",
                "Lange koude fermentatie",
                "Lager minimum 6 weken"
            ],
            notes: "Traditionele Beierse herfst lager met rijke malt smaak."
        )
    }
    
    private static func porter() -> DetailedRecipe {
        DetailedRecipe(
            name: "Robust Porter",
            style: "Robust Porter",
            abv: 5.8,
            ibu: 32,
            difficulty: .intermediate,
            brewTime: 240,
            ingredients: [
                RecipeIngredient(name: "Maris Otter", amount: "3.5 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Munich Malt", amount: "0.5 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Crystal 80L", amount: "0.3 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Chocolate Malt", amount: "0.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "East Kent Goldings", amount: "35 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Fuggle", amount: "15 g", type: .hop, timing: "15 min"),
                RecipeIngredient(name: "SafAle S-04", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Mash op 67°C voor body",
                "Donkere mout voorzichtig toevoegen",
                "Rijp 4 weken voor beste smaak"
            ],
            notes: "Engelse donkere ale met chocolade en koffie tonen."
        )
    }
    
    private static func kolsch() -> DetailedRecipe {
        DetailedRecipe(
            name: "Kölsch",
            style: "Kölsch",
            abv: 4.7,
            ibu: 22,
            difficulty: .advanced,
            brewTime: 300,
            ingredients: [
                RecipeIngredient(name: "German Pilsner Malt", amount: "3.8 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Wheat Malt", amount: "0.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Hallertau", amount: "25 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Spalt", amount: "10 g", type: .hop, timing: "20 min"),
                RecipeIngredient(name: "SafAle K-97", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Step mash voor delicate smaak",
                "Fermenteer op ale temperatuur",
                "Lager 4 weken op koude temperatuur"
            ],
            notes: "Delicate Keulse specialiteit, gebrouwen als ale, gelagerd als lager."
        )
    }
}
