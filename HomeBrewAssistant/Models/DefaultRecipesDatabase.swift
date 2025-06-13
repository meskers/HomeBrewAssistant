import Foundation

struct DefaultRecipesDatabase {
    
    // MARK: - Public Interface
    static func getAllDefaultRecipes() -> [DetailedRecipe] {
        return [
            // Nederlandse Stijlen
            nederlandsePilsner(),
            nederlandseBokbier(),
            nederlandsWitbier(),
            
            // Klassieke Europese Stijlen
            deutschePilsner(),
            hefeweizen(),
            belgischeDubbel(),
            irishStout(),
            englishBitter(),
            
            // Amerikaanse Stijlen
            americanIPA(),
            americanPaleAle(),
            americanWheat(),
            
            // Seizoensstijlen
            oktoberfest(),
            saison(),
            
            // Donkere Stijlen
            porter(),
            schwarzbier(),
            
            // Lichte Stijlen
            kolsch(),
            czechPilsner()
        ]
    }
    
    // MARK: - Nederlandse Stijlen
    
    private static func nederlandsePilsner() -> DetailedRecipe {
        DetailedRecipe(
            name: "Nederlandse Pilsner",
            style: "Nederlandse Lager",
            abv: 5.1,
            ibu: 28,
            difficulty: .intermediate,
            brewTime: 240,
            ingredients: [
                RecipeIngredient(name: "Pilsner Mout", amount: "4.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Nederlandse Hop (Saaz type)", amount: "25 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Nederlandse Hop (Hallertau)", amount: "15 g", type: .hop, timing: "15 min"),
                RecipeIngredient(name: "SafLager W-34/70", amount: "1 pak", type: .yeast, timing: "Fermentatie"),
                RecipeIngredient(name: "Gypsum", amount: "2 g", type: .other, timing: "Mash")
            ],
            instructions: [
                "Verwarm 13L water tot 67°C",
                "Voeg gemalen mout toe, mash 60 minuten op 65°C",
                "Spoel met 15L water van 78°C",
                "Kook 60 minuten, voeg hop toe volgens schema",
                "Koel snel af tot 10°C",
                "Fermenteer 2 weken op 10°C",
                "Lager 4-6 weken op 2°C",
                "Flesrijping 2 weken"
            ],
            notes: "Authentieke Nederlandse pilsner met zachte hopbitterheid en frisse afdronk. Perfect voor de Nederlandse smaak."
        )
    }
    
    private static func nederlandseBokbier() -> DetailedRecipe {
        DetailedRecipe(
            name: "Nederlandse Bokbier",
            style: "Nederlandse Seizoensbier",
            abv: 6.8,
            ibu: 22,
            difficulty: .intermediate,
            brewTime: 300,
            ingredients: [
                RecipeIngredient(name: "Münchener Mout", amount: "3.8 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Crystal 60L", amount: "0.4 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Chocolate Mout", amount: "0.1 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Saaz Hop", amount: "20 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Hallertau Hop", amount: "10 g", type: .hop, timing: "30 min"),
                RecipeIngredient(name: "SafLager W-34/70", amount: "2 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Single infusion mash op 67°C gedurende 75 minuten",
                "Spoel met 78°C water",
                "Kook 90 minuten voor Maillard reacties",
                "Fermenteer 3 weken op 12°C",
                "Lager 6-8 weken op 3°C",
                "Traditioneel gerijpt voor de herfst"
            ],
            notes: "Traditioneel Nederlands seizoensbier met volle moutsmaak en amber kleur. Perfect voor de herfst- en wintermaanden."
        )
    }
    
    private static func nederlandsWitbier() -> DetailedRecipe {
        DetailedRecipe(
            name: "Nederlands Witbier",
            style: "Nederlandse Tarwebier",
            abv: 4.8,
            ibu: 12,
            difficulty: .advanced,
            brewTime: 270,
            ingredients: [
                RecipeIngredient(name: "Pilsner Mout", amount: "2.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Tarwemout", amount: "1.8 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Havervlokken", amount: "0.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Saaz Hop", amount: "12 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Koriander (gemalen)", amount: "15 g", type: .other, timing: "5 min"),
                RecipeIngredient(name: "Sinaasappelschil (gedroogd)", amount: "20 g", type: .other, timing: "5 min"),
                RecipeIngredient(name: "SafSpirit M-1", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Protein rest op 52°C gedurende 20 minuten",
                "Verhoog naar 65°C, mash 60 minuten",
                "Mash-out op 78°C",
                "Kook 60 minuten, voeg specerijen toe op 5 min",
                "Fermenteer 2 weken op 20°C",
                "Natuurlijke carbonatie met 6g/L suiker",
                "Rijp 3 weken bij kamertemperatuur"
            ],
            notes: "Licht, verfrissend tarwebier met subtiele koriander en citrus. Serveer met schijfje citroen."
        )
    }
    
    // MARK: - Klassieke Europese Stijlen
    
    private static func deutschePilsner() -> DetailedRecipe {
        DetailedRecipe(
            name: "Deutsche Pilsner",
            style: "German Lager",
            abv: 4.9,
            ibu: 35,
            difficulty: .intermediate,
            brewTime: 240,
            ingredients: [
                RecipeIngredient(name: "Pilsner Mout", amount: "4.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Saaz Hop", amount: "30 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Saaz Hop", amount: "20 g", type: .hop, timing: "15 min"),
                RecipeIngredient(name: "SafLager S-23", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Decoction mash of single infusion op 65°C",
                "Kook 90 minuten",
                "Fermenteer 2 weken op 9°C",
                "Lager 6 weken op 1°C"
            ],
            notes: "Klassieke Duitse pilsner met uitgesproken hop aroma en droge afdronk."
        )
    }
    
    private static func hefeweizen() -> DetailedRecipe {
        DetailedRecipe(
            name: "Hefeweizen",
            style: "Duitse Tarwebier",
            abv: 5.2,
            ibu: 15,
            difficulty: .intermediate,
            brewTime: 180,
            ingredients: [
                RecipeIngredient(name: "Tarwemout", amount: "2.8 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Pilsner Mout", amount: "1.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Hallertau Hop", amount: "15 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "SafSpirit M-20", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Protein rest 50°C - 15 min",
                "Saccharification rest 65°C - 60 min",
                "Fermenteer 18-22°C gedurende 1 week",
                "Flesrijping zonder filtering"
            ],
            notes: "Traditionele Beierse tarwebier met banaan en kruidnagel aroma's van de gist."
        )
    }
    
    private static func belgischeDubbel() -> DetailedRecipe {
        DetailedRecipe(
            name: "Belgische Dubbel",
            style: "Belgian Dark Ale",
            abv: 7.2,
            ibu: 20,
            difficulty: .advanced,
            brewTime: 300,
            ingredients: [
                RecipeIngredient(name: "Pilsner Mout", amount: "4.5 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Special B", amount: "0.3 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Crystal 80L", amount: "0.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Candi Suiker (donker)", amount: "0.5 kg", type: .other, timing: "15 min"),
                RecipeIngredient(name: "Saaz Hop", amount: "25 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "SafSpirit M-41", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Single infusion mash op 67°C",
                "Voeg candi suiker toe op 15 min voor einde kook",
                "Fermenteer 22°C gedurende 2 weken",
                "Rijp 4-6 weken op 15°C"
            ],
            notes: "Donkere Belgische ale met complexe fruitesters en kruidnagel fenolen."
        )
    }
    
    private static func irishStout() -> DetailedRecipe {
        DetailedRecipe(
            name: "Irish Stout",
            style: "Irish Stout",
            abv: 4.3,
            ibu: 42,
            difficulty: .intermediate,
            brewTime: 210,
            ingredients: [
                RecipeIngredient(name: "Maris Otter", amount: "3.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Geroosterde Gerst", amount: "0.3 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Crystal 60L", amount: "0.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "East Kent Goldings", amount: "35 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "SafAle S-04", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Mash op 67°C gedurende 60 minuten",
                "Kook 75 minuten",
                "Fermenteer op 18°C",
                "Serveer met stikstof voor romige schuimkraag"
            ],
            notes: "Droge, rokerige Ierse stout met koffie en chocolade tonen."
        )
    }
    
    private static func englishBitter() -> DetailedRecipe {
        DetailedRecipe(
            name: "English Bitter",
            style: "English Pale Ale",
            abv: 4.2,
            ibu: 35,
            difficulty: .beginner,
            brewTime: 180,
            ingredients: [
                RecipeIngredient(name: "Maris Otter", amount: "3.5 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Crystal 40L", amount: "0.3 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "East Kent Goldings", amount: "25 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Fuggles", amount: "20 g", type: .hop, timing: "15 min"),
                RecipeIngredient(name: "SafAle S-04", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Single infusion mash op 66°C",
                "Fermenteer op 19°C gedurende 1 week",
                "Lage carbonatie, cask conditioned stijl"
            ],
            notes: "Traditionele Engelse bitter met maltbalans en aardse hop karakters."
        )
    }
    
    // MARK: - Amerikaanse Stijlen
    
    private static func americanIPA() -> DetailedRecipe {
        DetailedRecipe(
            name: "American IPA",
            style: "American IPA",
            abv: 6.8,
            ibu: 65,
            difficulty: .intermediate,
            brewTime: 270,
            ingredients: [
                RecipeIngredient(name: "2-Row Pale Malt", amount: "4.8 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Crystal 60L", amount: "0.4 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Cascade", amount: "30 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Centennial", amount: "25 g", type: .hop, timing: "15 min"),
                RecipeIngredient(name: "Citra", amount: "30 g", type: .hop, timing: "Whirlpool"),
                RecipeIngredient(name: "Mosaic", amount: "40 g", type: .hop, timing: "Dry Hop"),
                RecipeIngredient(name: "SafAle US-05", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Mash op 65°C voor goede vergistbaarheid",
                "Whirlpool hop op 80°C gedurende 20 min",
                "Fermenteer op 18°C",
                "Dry hop 3 dagen tijdens fermentatie"
            ],
            notes: "Moderne American IPA met citrus en tropische hop aroma's."
        )
    }
    
    private static func americanPaleAle() -> DetailedRecipe {
        DetailedRecipe(
            name: "American Pale Ale",
            style: "American Pale Ale", 
            abv: 5.4,
            ibu: 42,
            difficulty: .beginner,
            brewTime: 210,
            ingredients: [
                RecipeIngredient(name: "2-Row Pale Malt", amount: "4.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Crystal 40L", amount: "0.3 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Cascade", amount: "25 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Cascade", amount: "20 g", type: .hop, timing: "15 min"),
                RecipeIngredient(name: "Cascade", amount: "15 g", type: .hop, timing: "5 min"),
                RecipeIngredient(name: "SafAle US-05", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Single infusion mash op 66°C",
                "Klassieke Amerikaanse hop schedule",
                "Fermenteer op 18°C"
            ],
            notes: "Toegankelijke American Pale Ale perfect voor beginners. Klassieke Cascade hop karakter."
        )
    }
    
    private static func americanWheat() -> DetailedRecipe {
        DetailedRecipe(
            name: "American Wheat",
            style: "American Wheat Beer",
            abv: 4.8,
            ibu: 18,
            difficulty: .beginner,
            brewTime: 180,
            ingredients: [
                RecipeIngredient(name: "Wheat Malt", amount: "2.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "2-Row Pale Malt", amount: "1.8 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Willamette", amount: "15 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Willamette", amount: "10 g", type: .hop, timing: "5 min"),
                RecipeIngredient(name: "SafAle US-05", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Protein rest 50°C - 15 min (optioneel)",
                "Saccharification 65°C - 60 min",
                "Fermenteer schoon op 19°C"
            ],
            notes: "Schone Amerikaanse tarwebier zonder specerijen. Perfect voor fruit toevoegingen."
        )
    }
    
    // MARK: - Seizoensstijlen
    
    private static func oktoberfest() -> DetailedRecipe {
        DetailedRecipe(
            name: "Oktoberfest",
            style: "Marzen",
            abv: 5.6,
            ibu: 24,
            difficulty: .intermediate,
            brewTime: 300,
            ingredients: [
                RecipeIngredient(name: "Munich Malt", amount: "3.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Vienna Malt", amount: "1.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Crystal 60L", amount: "0.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Hallertau", amount: "25 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Hallertau", amount: "15 g", type: .hop, timing: "30 min"),
                RecipeIngredient(name: "SafLager W-34/70", amount: "2 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Decoction mash traditioneel",
                "Of single infusion op 67°C",
                "Fermenteer 2 weken op 10°C",
                "Lager 6-8 weken"
            ],
            notes: "Klassieke Duitse Oktoberfest met maltbalans en amber kleur."
        )
    }
    
    private static func saison() -> DetailedRecipe {
        DetailedRecipe(
            name: "Saison", 
            style: "Belgian Saison",
            abv: 6.2,
            ibu: 32,
            difficulty: .advanced,
            brewTime: 240,
            ingredients: [
                RecipeIngredient(name: "Pilsner Malt", amount: "4.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Vienna Malt", amount: "0.5 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "East Kent Goldings", amount: "25 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Saaz", amount: "20 g", type: .hop, timing: "15 min"),
                RecipeIngredient(name: "SafSpirit T-58", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Mash laag voor droge afdronk (63°C)",
                "Fermenteer warm (24-26°C) voor esters",
                "Rijp 2-3 maanden voor complexiteit"
            ],
            notes: "Traditionele Belgische boerderijale met complexe gist karakters."
        )
    }
    
    // MARK: - Donkere Stijlen
    
    private static func porter() -> DetailedRecipe {
        DetailedRecipe(
            name: "Porter",
            style: "English Porter",
            abv: 5.8,
            ibu: 32,
            difficulty: .intermediate,
            brewTime: 210,
            ingredients: [
                RecipeIngredient(name: "Maris Otter", amount: "3.8 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Crystal 80L", amount: "0.3 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Chocolate Malt", amount: "0.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Black Patent", amount: "0.1 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "East Kent Goldings", amount: "30 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Fuggles", amount: "15 g", type: .hop, timing: "15 min"),
                RecipeIngredient(name: "SafAle S-04", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Mash op 67°C voor body",
                "Fermenteer op 18°C",
                "Rijp 4-6 weken voor mouthfeel"
            ],
            notes: "Historische Londense porter met balans tussen malt en roast."
        )
    }
    
    private static func schwarzbier() -> DetailedRecipe {
        DetailedRecipe(
            name: "Schwarzbier",
            style: "German Dark Lager",
            abv: 4.9,
            ibu: 25,
            difficulty: .intermediate,
            brewTime: 270,
            ingredients: [
                RecipeIngredient(name: "Munich Malt", amount: "3.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Pilsner Malt", amount: "0.8 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Carafa II", amount: "0.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Hallertau", amount: "22 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Tettnang", amount: "12 g", type: .hop, timing: "20 min"),
                RecipeIngredient(name: "SafLager W-34/70", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Single infusion mash op 66°C",
                "Fermenteer koel op 10°C",
                "Lager 6-8 weken",
                "Zeer donker maar mild van smaak"
            ],
            notes: "Duitse zwarte lager - donker van kleur maar licht van smaak."
        )
    }
    
    // MARK: - Lichte Stijlen
    
    private static func kolsch() -> DetailedRecipe {
        DetailedRecipe(
            name: "Kölsch",
            style: "German Light Ale",
            abv: 4.6,
            ibu: 22,
            difficulty: .intermediate,
            brewTime: 210,
            ingredients: [
                RecipeIngredient(name: "Pilsner Malt", amount: "3.8 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Vienna Malt", amount: "0.2 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Hallertau", amount: "20 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Tettnang", amount: "10 g", type: .hop, timing: "20 min"),
                RecipeIngredient(name: "SafAle K-97", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Single infusion mash op 64°C",
                "Fermenteer op 16°C (koel voor ale)",
                "Lager 4 weken op 3°C",
                "Serveer in traditionele 0.2L glazen"
            ],
            notes: "Delicate Kölner specialiteit - ale gist, lager conditioned."
        )
    }
    
    private static func czechPilsner() -> DetailedRecipe {
        DetailedRecipe(
            name: "Czech Premium Pale Lager",
            style: "Czech Pilsner",
            abv: 4.4,
            ibu: 42,
            difficulty: .advanced,
            brewTime: 300,
            ingredients: [
                RecipeIngredient(name: "Bohemian Pilsner Malt", amount: "4.0 kg", type: .grain, timing: "Mash"),
                RecipeIngredient(name: "Saaz Hops", amount: "40 g", type: .hop, timing: "60 min"),
                RecipeIngredient(name: "Saaz Hops", amount: "25 g", type: .hop, timing: "30 min"),
                RecipeIngredient(name: "Saaz Hops", amount: "15 g", type: .hop, timing: "5 min"),
                RecipeIngredient(name: "SafLager W-34/70", amount: "1 pak", type: .yeast, timing: "Fermentatie")
            ],
            instructions: [
                "Triple decoction mash traditioneel",
                "Of step mash: 50°C-63°C-72°C",
                "Kook 90 minuten",
                "Fermenteer 3 weken op 9°C",
                "Lager 6-8 weken op 1°C"
            ],
            notes: "Originele pilsner van Pilsen met zachte Saaz hop karakter."
        )
    }
} 