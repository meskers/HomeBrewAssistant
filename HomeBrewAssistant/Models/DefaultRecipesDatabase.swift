import Foundation

class DefaultRecipesDatabase {
    static func getAllDefaultRecipes() -> [DetailedRecipe] {
        return [
            simpleBeer(),
            hefeweizen(),
            belgischeDubbel(),
            americanPaleAle(),
            irishStout()
        ]
    }
    
    private static func simpleBeer() -> DetailedRecipe {
        DetailedRecipe(
            name: "🌟 Beginner Golden Ale",
            style: "American Blonde Ale",
            abv: 4.5,
            ibu: 15,
            difficulty: .beginner,
            brewTime: 180,
            ingredients: [
                RecipeIngredient(name: "Pilsner Mout", amount: "3 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Tarwemout", amount: "1 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Cascade Hop", amount: "20 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "SafAle US-05", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Mash op 65°C voor 60 minuten",
                "Spoel met 78°C water", 
                "Kook 60 minuten met hop toevoegingen",
                "Fermenteer op 18°C voor 7 dagen"
            ],
            notes: "Perfect eerste recept! 97% slaagkans bij beginners."
        )
    }
    
    private static func hefeweizen() -> DetailedRecipe {
        DetailedRecipe(
            name: "🇩🇪 Hefeweizen",
            style: "German Hefeweizen", 
            abv: 5.2,
            ibu: 12,
            difficulty: .beginner,
            brewTime: 200,
            ingredients: [
                RecipeIngredient(name: "Wheat Malt", amount: "2.5 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Pilsner Malt", amount: "2.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Hallertau", amount: "18 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Safbrew WB-06", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Mash op 64°C voor 60 minuten",
                "Fermenteer bij 20°C voor banaan aroma",
                "Serveer met citroen"
            ],
            notes: "Klassiek Duits tarwebier met karakteristieke gist aroma's."
        )
    }
    
    private static func belgischeDubbel() -> DetailedRecipe {
        DetailedRecipe(
            name: "🇧🇪 Belgische Dubbel",
            style: "Belgian Dubbel",
            abv: 7.2,
            ibu: 20,
            difficulty: .intermediate,
            brewTime: 270,
            ingredients: [
                RecipeIngredient(name: "Pilsner Mout", amount: "4.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Munich Malt", amount: "0.5 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Special B", amount: "0.3 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Donkere Candi Suiker", amount: "0.5 kg", type: .other, timing: "15 min"),
                RecipeIngredient(name: "Styrian Goldings", amount: "25 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "SafSpirit M-31", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Mash op 65°C voor 60 minuten",
                "Voeg candi suiker toe laatste 15 min van kook",
                "Fermenteer bij 24°C voor complexe smaken"
            ],
            notes: "Rijke Belgische ale met rozijn en pruim tonen."
        )
    }
    
    private static func americanPaleAle() -> DetailedRecipe {
        DetailedRecipe(
            name: "🇺🇸 American Pale Ale",
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
                "Cascade hop showcase voor citrus aroma",
                "Fermenteer schoon bij 18°C"
            ],
            notes: "Klassieke Amerikaanse pale ale met citrus hop karakter."
        )
    }
    
    private static func irishStout() -> DetailedRecipe {
        DetailedRecipe(
            name: "☘️ Irish Stout",
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
                "Serveer op keldertemperatuur"
            ],
            notes: "Droge stout met koffie en chocolade smaken."
        )
    }
}
