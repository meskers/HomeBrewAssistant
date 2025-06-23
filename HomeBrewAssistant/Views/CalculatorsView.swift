import SwiftUI

struct CalculatorsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedCalculator: CalculatorType? = nil
    
    enum CalculatorType: String, CaseIterable {
        case abv = "ABV"
        case ibu = "IBU" 
        case srm = "SRM"
        case carbonation = "CO₂"
        case water = "Water"
        case waterChemistry = "Water Chemistry"
        case hydrometer = "Hydrometer"
        case strikeWater = "Strike Water"
        case yeastPitch = "Yeast Pitch"
        case brewTimer = "Brew Timer"
        
        var title: String {
            switch self {
            case .abv: return "calculator.abv.title".localized
            case .ibu: return "calculator.ibu.title".localized
            case .srm: return "calculator.srm.title".localized
            case .carbonation: return "calculator.co2.title".localized
            case .water: return "calculator.water.title".localized
            case .waterChemistry: return "Water Chemistry"
            case .hydrometer: return "Hydrometer Correctie"
            case .strikeWater: return "Strike Water"
            case .yeastPitch: return "Gist Pitch Rate"
            case .brewTimer: return "Brouw Timer"
            }
        }
        
        var icon: String {
            switch self {
            case .abv: return "percent"
            case .ibu: return "drop.fill"
            case .srm: return "paintpalette.fill"
            case .carbonation: return "bubbles.and.sparkles"
            case .water: return "drop.triangle"
            case .waterChemistry: return "flask.fill"
            case .hydrometer: return "thermometer"
            case .strikeWater: return "flame"
            case .yeastPitch: return "microbe"
            case .brewTimer: return "timer"
            }
        }
        
        var description: String {
            switch self {
            case .abv: return "calculator.abv.description".localized
            case .ibu: return "calculator.ibu.description".localized
            case .srm: return "calculator.srm.description".localized
            case .carbonation: return "calculator.co2.description".localized
            case .water: return "calculator.water.description".localized
            case .waterChemistry: return "Optimize brewing water mineral profile"
            case .hydrometer: return "Corrigeer gravity voor temperatuur"
            case .strikeWater: return "Bereken water temperatuur voor mashing"
            case .yeastPitch: return "Bereken hoeveel gist nodig is"
            case .brewTimer: return "Multi-timer voor brouwprocessen"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "function")
                                .font(.title2)
                                .foregroundColor(.brewTheme)
                            
                            VStack(alignment: .leading) {
                                Text("calculators.title".localized)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("calculators.subtitle".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                        ForEach(CalculatorType.allCases, id: \.rawValue) { calculator in
                            CalculatorCard(calculator: calculator)
                                .onTapGesture {
                                    selectedCalculator = calculator
                                }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("calculators.title".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $selectedCalculator) { calculator in
            calculatorView(for: calculator)
        }
    }
    
    @ViewBuilder
    private func calculatorView(for calculator: CalculatorType) -> some View {
        switch calculator {
        case .abv:
            ABVCalculatorView()
        case .ibu:
            // TODO: Implement IBUCalculatorView
            Text("IBU Calculator - Coming Soon")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
        case .srm:
            // TODO: Implement SRMCalculatorView
            Text("SRM Calculator - Coming Soon")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
        case .carbonation:
            // TODO: Implement CarbonationCalculatorView
            Text("Carbonation Calculator - Coming Soon")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
        case .water:
            // TODO: Implement WaterCalculatorView
            Text("Water Calculator - Coming Soon")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
        case .waterChemistry:
            WaterChemistryCalculatorView()
        case .hydrometer:
            HydrometerCalculatorView()
        case .strikeWater:
            StrikeWaterCalculatorView()
        case .yeastPitch:
            YeastPitchCalculatorView()
        case .brewTimer:
            BrewTimerCalculatorView()
        }
    }
}

struct CalculatorCard: View {
    let calculator: CalculatorsView.CalculatorType
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: calculator.icon)
                .font(.system(size: 30))
                .foregroundColor(.brewTheme)
            
            // Title
            Text(calculator.title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // Description
            Text(calculator.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .padding()
        .background(Color.primaryCard)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

extension CalculatorsView.CalculatorType: Identifiable {
    var id: String { rawValue }
}

#Preview {
    CalculatorsView()
}

// MARK: - Advanced Calculator Views v1.1

// MARK: - Hydrometer Temperature Correction Calculator
struct HydrometerCalculatorView: View {
    @State private var observedGravity = ""
    @State private var actualTemperature = ""
    @State private var calibrationTemperature = "20" // Default 20°C
    @State private var correctedGravity = 0.0
    @State private var showResult = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "thermometer")
                            .font(.system(size: 50))
                            .foregroundColor(.brewTheme)
                        
                        Text("Hydrometer Correctie")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Corrigeer gravity metingen voor temperatuur")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Input Section
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Gemeten Gravity", systemImage: "drop.fill")
                                .font(.headline)
                            
                            TextField("Bijv. 1.050", text: $observedGravity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            
                            Text("Waarde afgelezen van hydrometer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Sample Temperatuur (°C)", systemImage: "thermometer")
                                .font(.headline)
                            
                            TextField("Bijv. 25", text: $actualTemperature)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            
                            Text("Temperatuur van de sample tijdens meting")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Calibratie Temperatuur (°C)", systemImage: "gear")
                                .font(.headline)
                            
                            TextField("20", text: $calibrationTemperature)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            
                            Text("Temperatuur waarvoor hydrometer gekalibreerd is (meestal 20°C)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calculate Button
                    Button("🧮 Bereken Correctie") {
                        calculateCorrection()
                        isInputFocused = false
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(canCalculate ? Color.brewTheme : Color.gray)
                    .cornerRadius(12)
                    .disabled(!canCalculate)
                    .padding(.horizontal)
                    
                    // Result Section
                    if showResult {
                        VStack(spacing: 16) {
                            Divider()
                            
                            VStack(spacing: 12) {
                                Text("Gecorrigeerde Gravity")
                                    .font(.headline)
                                
                                Text(String(format: "%.3f", correctedGravity))
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.brewTheme)
                                
                                let difference = correctedGravity - (Double(observedGravity) ?? 0.0)
                                Text("Correctie: \(difference > 0 ? "+" : "")\(String(format: "%.3f", difference))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.brewTheme.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Additional Info
                            VStack(alignment: .leading, spacing: 8) {
                                Text("💡 Temperatuur Correctie Info")
                                    .font(.headline)
                                
                                Text("• Warme samples lezen lager dan werkelijke gravity")
                                Text("• Koude samples lezen hoger dan werkelijke gravity")
                                Text("• Grootste nauwkeurigheid bij kalibratie temperatuur")
                                Text("• Automatische compensatie voor thermische uitzetting")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Hydrometer Correctie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        resetCalculator()
                    }
                    .disabled(!showResult)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Klaar") {
                        isInputFocused = false
                    }
                }
            }
        }
    }
    
    private var canCalculate: Bool {
        !observedGravity.isEmpty && !actualTemperature.isEmpty && !calibrationTemperature.isEmpty &&
        Double(observedGravity) != nil && Double(actualTemperature) != nil && Double(calibrationTemperature) != nil
    }
    
    private func calculateCorrection() {
        guard let observed = Double(observedGravity),
              let actualTemp = Double(actualTemperature),
              let calibTemp = Double(calibrationTemperature) else { return }
        
        // Temperature correction formula for hydrometers
        // CG = OG * ((1.00130346 - 0.000134722124 * T + 0.00000204052596 * T² - 0.00000000232820948 * T³) / 
        //            (1.00130346 - 0.000134722124 * CT + 0.00000204052596 * CT² - 0.00000000232820948 * CT³))
        
        let actualTempCoeff = 1.00130346 - 0.000134722124 * actualTemp + 0.00000204052596 * pow(actualTemp, 2) - 0.00000000232820948 * pow(actualTemp, 3)
        let calibTempCoeff = 1.00130346 - 0.000134722124 * calibTemp + 0.00000204052596 * pow(calibTemp, 2) - 0.00000000232820948 * pow(calibTemp, 3)
        
        correctedGravity = observed * (actualTempCoeff / calibTempCoeff)
        showResult = true
    }
    
    private func resetCalculator() {
        observedGravity = ""
        actualTemperature = ""
        calibrationTemperature = "20"
        correctedGravity = 0.0
        showResult = false
    }
}

// MARK: - Strike Water Temperature Calculator
struct StrikeWaterCalculatorView: View {
    @State private var grainWeight = ""
    @State private var waterVolume = ""
    @State private var grainTemperature = "20"
    @State private var targetMashTemperature = "66"
    @State private var calculatedStrikeTemp = 0.0
    @State private var showResult = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "flame")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Strike Water Calculator")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Bereken de juiste water temperatuur voor je mash")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Input Section
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Mout Gewicht (kg)", systemImage: "scalemass")
                                .font(.headline)
                            
                            TextField("Bijv. 5.0", text: $grainWeight)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Water Volume (L)", systemImage: "drop")
                                .font(.headline)
                            
                            TextField("Bijv. 15.0", text: $waterVolume)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Mout Temperatuur (°C)", systemImage: "thermometer.snow")
                                .font(.headline)
                            
                            TextField("20", text: $grainTemperature)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            
                            Text("Temperatuur van de mout (meestal kamertemperatuur)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Doel Mash Temperatuur (°C)", systemImage: "target")
                                .font(.headline)
                            
                            TextField("66", text: $targetMashTemperature)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            
                            Text("Gewenste temperatuur na mengen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calculate Button
                    Button("🔥 Bereken Strike Water Temp") {
                        calculateStrikeWater()
                        isInputFocused = false
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(canCalculate ? Color.orange : Color.gray)
                    .cornerRadius(12)
                    .disabled(!canCalculate)
                    .padding(.horizontal)
                    
                    // Result Section
                    if showResult {
                        VStack(spacing: 16) {
                            Divider()
                            
                            VStack(spacing: 12) {
                                Text("Strike Water Temperatuur")
                                    .font(.headline)
                                
                                Text("\(Int(calculatedStrikeTemp))°C")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                                
                                Text("Verwarm je water tot deze temperatuur")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Temperature guide
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🌡️ Mash Temperatuur Gids")
                                    .font(.headline)
                                
                                Text("• 63-65°C: Droge, vergistbare bieren")
                                Text("• 65-67°C: Gebalanceerde body en vergisting")
                                Text("• 67-69°C: Meer body, minder vergistbaar")
                                Text("• 69-72°C: Volle body, zoete bieren")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Strike Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        resetCalculator()
                    }
                    .disabled(!showResult)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Klaar") {
                        isInputFocused = false
                    }
                }
            }
        }
    }
    
    private var canCalculate: Bool {
        !grainWeight.isEmpty && !waterVolume.isEmpty && !grainTemperature.isEmpty && !targetMashTemperature.isEmpty &&
        Double(grainWeight) != nil && Double(waterVolume) != nil && Double(grainTemperature) != nil && Double(targetMashTemperature) != nil
    }
    
    private func calculateStrikeWater() {
        guard let grain = Double(grainWeight),
              let water = Double(waterVolume),
              let grainTemp = Double(grainTemperature),
              let targetTemp = Double(targetMashTemperature) else { return }
        
        // Palmer's formula: Strike Water Temp = (0.2 / R) * (T2 - T1) + T2
        // Where R = water to grain ratio, T1 = grain temp, T2 = target mash temp
        let ratio = water / grain
        let tempRise = targetTemp - grainTemp
        
        // Adjusted formula for metric units
        calculatedStrikeTemp = targetTemp + (tempRise * 0.4) / ratio
        
        showResult = true
    }
    
    private func resetCalculator() {
        grainWeight = ""
        waterVolume = ""
        grainTemperature = "20"
        targetMashTemperature = "66"
        calculatedStrikeTemp = 0.0
        showResult = false
    }
}

// MARK: - Yeast Pitch Rate Calculator
struct YeastPitchCalculatorView: View {
    @State private var batchSize = ""
    @State private var originalGravity = ""
    @State private var selectedYeastType = YeastType.ale
    @State private var selectedBeerType = BeerTypeForYeast.standard
    @State private var calculatedCells = 0.0
    @State private var packetsNeeded = 0.0
    @State private var starterSize = 0.0
    @State private var showResult = false
    @FocusState private var isInputFocused: Bool
    
    enum YeastType: String, CaseIterable {
        case ale = "Ale Gist"
        case lager = "Lager Gist"
        case wild = "Wild Gist"
        
        var pitchRate: Double {
            switch self {
            case .ale: return 0.75      // Million cells per mL per °Plato
            case .lager: return 1.5     // Million cells per mL per °Plato
            case .wild: return 0.5      // Million cells per mL per °Plato
            }
        }
    }
    
    enum BeerTypeForYeast: String, CaseIterable {
        case standard = "Standaard (< 1.060)"
        case high = "Hoge Gravity (1.060-1.080)"
        case extreme = "Extreme (> 1.080)"
        
        var multiplier: Double {
            switch self {
            case .standard: return 1.0
            case .high: return 1.25
            case .extreme: return 1.5
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "microbe")
                            .font(.system(size: 50))
                            .foregroundColor(.brewTheme)
                        
                        Text("Yeast Pitch Rate Calculator")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Bereken hoeveel gist je nodig hebt voor optimale fermentatie")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Input Section
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Batch Grootte (L)", systemImage: "cylinder")
                                .font(.headline)
                            
                            TextField("Bijv. 20", text: $batchSize)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Original Gravity", systemImage: "drop.fill")
                                .font(.headline)
                            
                            TextField("Bijv. 1.050", text: $originalGravity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Gist Type", systemImage: "microbe")
                                .font(.headline)
                            
                            Picker("Gist Type", selection: $selectedYeastType) {
                                ForEach(YeastType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Bier Sterkte", systemImage: "chart.bar")
                                .font(.headline)
                            
                            Picker("Bier Type", selection: $selectedBeerType) {
                                ForEach(BeerTypeForYeast.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calculate Button
                    Button("🦠 Bereken Gist Behoefte") {
                        calculateYeastPitch()
                        isInputFocused = false
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(canCalculate ? Color.brewTheme : Color.gray)
                    .cornerRadius(12)
                    .disabled(!canCalculate)
                    .padding(.horizontal)
                    
                    // Result Section
                    if showResult {
                        VStack(spacing: 16) {
                            Divider()
                            
                            VStack(spacing: 20) {
                                // Total cells needed
                                VStack(spacing: 12) {
                                    Text("Totaal Gist Cellen Nodig")
                                        .font(.headline)
                                    
                                    Text("\(String(format: "%.0f", calculatedCells)) miljard")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.brewTheme)
                                }
                                .padding()
                                .background(Color.brewTheme.opacity(0.1))
                                .cornerRadius(12)
                                
                                // Options
                                HStack(spacing: 15) {
                                    VStack(spacing: 8) {
                                        Text("Dry Yeast Pakjes")
                                            .font(.headline)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("\(String(format: "%.1f", packetsNeeded))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                        
                                        Text("≈ \(Int(ceil(packetsNeeded))) pakjes")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                                    
                                    VStack(spacing: 8) {
                                        Text("Starter Volume")
                                            .font(.headline)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("\(String(format: "%.1f", starterSize))L")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.orange)
                                        
                                        Text("met 1 pakje gist")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Pitch rate info
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📊 Pitch Rate Informatie")
                                    .font(.headline)
                                
                                Text("• Ale gist: 0.75M cellen/mL/°P")
                                Text("• Lager gist: 1.5M cellen/mL/°P (dubbele pitch rate)")
                                Text("• Onderpitching → trage start, stress flavors")
                                Text("• Overpitching → minder ester productie")
                                Text("• 1 pakje dry yeast ≈ 200 miljard cellen")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Yeast Pitch Rate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        resetCalculator()
                    }
                    .disabled(!showResult)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Klaar") {
                        isInputFocused = false
                    }
                }
            }
        }
    }
    
    private var canCalculate: Bool {
        !batchSize.isEmpty && !originalGravity.isEmpty &&
        Double(batchSize) != nil && Double(originalGravity) != nil
    }
    
    private func calculateYeastPitch() {
        guard let batch = Double(batchSize),
              let og = Double(originalGravity) else { return }
        
        // Convert OG to Plato
        let plato = 250 * (og - 1.0)
        
        // Calculate cells needed: Volume (mL) × Plato × Pitch Rate × Beer Type Multiplier
        let volumeMl = batch * 1000
        let baseCells = volumeMl * plato * selectedYeastType.pitchRate * selectedBeerType.multiplier
        
        // Convert to billions
        calculatedCells = baseCells / 1000
        
        // Calculate packets needed (assuming 200 billion cells per packet)
        packetsNeeded = calculatedCells / 200
        
        // Calculate starter size needed with 1 packet
        // Rough estimate: 1L starter can grow to ~200 billion additional cells
        if packetsNeeded > 1 {
            starterSize = (calculatedCells - 200) / 200
        } else {
            starterSize = 0
        }
        
        showResult = true
    }
    
    private func resetCalculator() {
        batchSize = ""
        originalGravity = ""
        selectedYeastType = .ale
        selectedBeerType = .standard
        calculatedCells = 0.0
        packetsNeeded = 0.0
        starterSize = 0.0
        showResult = false
    }
}

// MARK: - Brew Timer Calculator (Simplified)
struct BrewTimerCalculatorView: View {
    @State private var showingAddTimer = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "timer")
                        .font(.system(size: 50))
                        .foregroundColor(.brewTheme)
                    
                    Text("Brouw Timers")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Multi-timer voor brouwprocessen")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                Spacer()
                
                // Coming Soon Message
                VStack(spacing: 12) {
                    Text("🚧 Binnenkort Beschikbaar")
                        .font(.headline)
                        .foregroundColor(.brewTheme)
                    
                    Text("De geavanceerde timer functionaliteit komt beschikbaar in een toekomstige update.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Text("Voor nu kunt u de standaard timer van uw telefoon gebruiken.")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Brew Timers")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Water Chemistry Calculator
struct WaterChemistryCalculatorView: View {
    @State private var sourceWaterProfile = WaterProfile()
    @State private var targetWaterProfile = WaterProfile()
    @State private var batchSize: Double = 20.0
    @State private var selectedTargetProfile: WaterProfileType = .balanced
    @State private var showingResults = false
    @State private var calculatedAdditions = MineralAdditions()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Water Chemistry Calculator")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        Text("Optimize your brewing water for perfect beer styles")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Batch Size
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Batch Size")
                            .font(.headline)
                        
                        HStack {
                            TextField("Batch Size", value: $batchSize, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            Text("L")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.primaryCard)
                    .cornerRadius(10)
                    
                    // Target Water Profile Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Target Water Profile")
                            .font(.headline)
                        
                        Picker("Water Profile", selection: $selectedTargetProfile) {
                            ForEach(WaterProfileType.allCases, id: \.self) { profile in
                                Text(profile.displayName).tag(profile)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedTargetProfile) { _, newProfile in
                            targetWaterProfile = newProfile.profile
                        }
                        
                        // Profile Description
                        Text(selectedTargetProfile.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.primaryCard)
                    .cornerRadius(10)
                    
                    // Source Water Profile Input
                    WaterProfileInputView(
                        title: "Source Water Profile",
                        subtitle: "Enter your tap water analysis",
                        profile: $sourceWaterProfile
                    )
                    
                    // Target Water Profile Display
                    WaterProfileDisplayView(
                        title: "Target Profile: \(selectedTargetProfile.displayName)",
                        profile: targetWaterProfile
                    )
                    
                    // Calculate Button
                    Button(action: calculateMineralAdditions) {
                        HStack {
                            Image(systemName: "flask.fill")
                            Text("Calculate Mineral Additions")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brewTheme)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    // Results
                    if showingResults {
                        MineralAdditionsResultView(
                            additions: calculatedAdditions,
                            batchSize: batchSize
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Water Chemistry")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            targetWaterProfile = selectedTargetProfile.profile
        }
    }
    
    private func calculateMineralAdditions() {
        calculatedAdditions = WaterChemistryCalculator.calculateAdditions(
            source: sourceWaterProfile,
            target: targetWaterProfile,
            batchSize: batchSize
        )
        showingResults = true
    }
}

// MARK: - Water Profile Models
struct WaterProfile {
    var calcium: Double = 0      // Ca²⁺ (ppm)
    var magnesium: Double = 0    // Mg²⁺ (ppm)
    var sodium: Double = 0       // Na⁺ (ppm)
    var chloride: Double = 0     // Cl⁻ (ppm)
    var sulfate: Double = 0      // SO₄²⁻ (ppm)
    var bicarbonate: Double = 0  // HCO₃⁻ (ppm)
    var ph: Double = 7.0         // pH
}

enum WaterProfileType: CaseIterable {
    case balanced, pale, hoppy, dark, pilsner, burton
    
    var displayName: String {
        switch self {
        case .balanced: return "Balanced"
        case .pale: return "Pale Ales"
        case .hoppy: return "Hoppy Beers"
        case .dark: return "Dark Beers"
        case .pilsner: return "Pilsner"
        case .burton: return "Burton-on-Trent"
        }
    }
    
    var description: String {
        switch self {
        case .balanced: return "Versatile profile for most beer styles"
        case .pale: return "Ideal for pale ales and amber beers"
        case .hoppy: return "High sulfate for hop-forward beers"
        case .dark: return "Lower mineral content for stouts and porters"
        case .pilsner: return "Soft water profile for delicate lagers"
        case .burton: return "Classic English bitter water profile"
        }
    }
    
    var profile: WaterProfile {
        switch self {
        case .balanced:
            return WaterProfile(calcium: 150, magnesium: 10, sodium: 10, chloride: 50, sulfate: 150, bicarbonate: 50, ph: 7.0)
        case .pale:
            return WaterProfile(calcium: 100, magnesium: 5, sodium: 10, chloride: 50, sulfate: 100, bicarbonate: 50, ph: 7.2)
        case .hoppy:
            return WaterProfile(calcium: 200, magnesium: 15, sodium: 15, chloride: 50, sulfate: 300, bicarbonate: 50, ph: 7.0)
        case .dark:
            return WaterProfile(calcium: 50, magnesium: 5, sodium: 5, chloride: 25, sulfate: 50, bicarbonate: 100, ph: 7.4)
        case .pilsner:
            return WaterProfile(calcium: 30, magnesium: 3, sodium: 2, chloride: 5, sulfate: 10, bicarbonate: 15, ph: 7.0)
        case .burton:
            return WaterProfile(calcium: 295, magnesium: 45, sodium: 25, chloride: 25, sulfate: 725, bicarbonate: 300, ph: 7.8)
        }
    }
}

struct MineralAdditions {
    var calciumChloride: Double = 0    // CaCl₂ (grams)
    var calciumSulfate: Double = 0     // CaSO₄ (grams)
    var magnesiumSulfate: Double = 0   // MgSO₄ (grams)
    var sodiumChloride: Double = 0     // NaCl (grams)
    var bakingSoda: Double = 0         // NaHCO₃ (grams)
    var chalkCaCO3: Double = 0         // CaCO₃ (grams)
    
    var totalAdditions: Double {
        calciumChloride + calciumSulfate + magnesiumSulfate + sodiumChloride + bakingSoda + chalkCaCO3
    }
}

// MARK: - Water Chemistry Calculator Logic
struct WaterChemistryCalculator {
    static func calculateAdditions(source: WaterProfile, target: WaterProfile, batchSize: Double) -> MineralAdditions {
        var additions = MineralAdditions()
        
        // Calculate differences
        let caDiff = max(0, target.calcium - source.calcium)
        let mgDiff = max(0, target.magnesium - source.magnesium)
        let clDiff = max(0, target.chloride - source.chloride)
        let so4Diff = max(0, target.sulfate - source.sulfate)
        let hco3Diff = max(0, target.bicarbonate - source.bicarbonate)
        
        // Calculate mineral additions (simplified calculations)
        // CaCl₂ provides Ca²⁺ and Cl⁻
        let caCl2ForCa = min(caDiff, clDiff * 0.72) // Stoichiometric ratio
        additions.calciumChloride = caCl2ForCa * batchSize * 0.147 // Conversion factor
        
        // CaSO₄ provides Ca²⁺ and SO₄²⁻
        let remainingCa = caDiff - caCl2ForCa
        let caSO4ForCa = min(remainingCa, so4Diff * 0.42)
        additions.calciumSulfate = caSO4ForCa * batchSize * 0.172
        
        // MgSO₄ provides Mg²⁺ and SO₄²⁻
        let remainingSO4 = so4Diff - (caSO4ForCa / 0.42)
        additions.magnesiumSulfate = min(mgDiff, remainingSO4 * 0.25) * batchSize * 0.246
        
        // NaHCO₃ for bicarbonate
        additions.bakingSoda = hco3Diff * batchSize * 0.137
        
        return additions
    }
    
    static func calculatePH(profile: WaterProfile, grainBill: Double) -> Double {
        // Simplified pH calculation based on alkalinity and grain bill
        let alkalinity = profile.bicarbonate * 0.82 // Convert to alkalinity as CaCO₃
        let grainAcidity = grainBill * 0.1 // Estimated acid contribution per kg grain
        
        let adjustedPH = profile.ph - (alkalinity / 100) + (grainAcidity / 10)
        return max(4.0, min(8.0, adjustedPH))
    }
}

// MARK: - Supporting Views
struct WaterProfileInputView: View {
    let title: String
    let subtitle: String
    @Binding var profile: WaterProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                WaterParameterInput(label: "Calcium (Ca²⁺)", value: $profile.calcium, unit: "ppm")
                WaterParameterInput(label: "Magnesium (Mg²⁺)", value: $profile.magnesium, unit: "ppm")
                WaterParameterInput(label: "Sodium (Na⁺)", value: $profile.sodium, unit: "ppm")
                WaterParameterInput(label: "Chloride (Cl⁻)", value: $profile.chloride, unit: "ppm")
                WaterParameterInput(label: "Sulfate (SO₄²⁻)", value: $profile.sulfate, unit: "ppm")
                WaterParameterInput(label: "Bicarbonate (HCO₃⁻)", value: $profile.bicarbonate, unit: "ppm")
            }
            
            WaterParameterInput(label: "pH", value: $profile.ph, unit: "", range: 4.0...9.0)
        }
        .padding()
        .background(Color.primaryCard)
        .cornerRadius(10)
    }
}

struct WaterProfileDisplayView: View {
    let title: String
    let profile: WaterProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                WaterParameterDisplay(label: "Calcium", value: profile.calcium, unit: "ppm")
                WaterParameterDisplay(label: "Magnesium", value: profile.magnesium, unit: "ppm")
                WaterParameterDisplay(label: "Sodium", value: profile.sodium, unit: "ppm")
                WaterParameterDisplay(label: "Chloride", value: profile.chloride, unit: "ppm")
                WaterParameterDisplay(label: "Sulfate", value: profile.sulfate, unit: "ppm")
                WaterParameterDisplay(label: "Bicarbonate", value: profile.bicarbonate, unit: "ppm")
            }
            
            HStack {
                Text("pH: \(profile.ph, specifier: "%.1f")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("Cl⁻/SO₄²⁻ Ratio: \(profile.chloride / max(1, profile.sulfate), specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondaryCard)
        .cornerRadius(10)
    }
}

struct WaterParameterInput: View {
    let label: String
    @Binding var value: Double
    let unit: String
    var range: ClosedRange<Double> = 0...1000
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("0", value: $value, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct WaterParameterDisplay: View {
    let label: String
    let value: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("\(value, specifier: "%.1f")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

struct MineralAdditionsResultView: View {
    let additions: MineralAdditions
    let batchSize: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Mineral Additions Required")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                if additions.calciumChloride > 0 {
                    MineralAdditionRow(
                        name: "Calcium Chloride (CaCl₂)",
                        amount: additions.calciumChloride,
                        description: "Adds calcium and chloride"
                    )
                }
                
                if additions.calciumSulfate > 0 {
                    MineralAdditionRow(
                        name: "Gypsum (CaSO₄)",
                        amount: additions.calciumSulfate,
                        description: "Adds calcium and sulfate"
                    )
                }
                
                if additions.magnesiumSulfate > 0 {
                    MineralAdditionRow(
                        name: "Epsom Salt (MgSO₄)",
                        amount: additions.magnesiumSulfate,
                        description: "Adds magnesium and sulfate"
                    )
                }
                
                if additions.bakingSoda > 0 {
                    MineralAdditionRow(
                        name: "Baking Soda (NaHCO₃)",
                        amount: additions.bakingSoda,
                        description: "Raises alkalinity and pH"
                    )
                }
            }
            
            Divider()
            
            HStack {
                Text("Total Additions:")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(additions.totalAdditions, specifier: "%.2f") g")
                    .fontWeight(.bold)
                    .foregroundColor(.brewTheme)
            }
            
            Text("💡 Add minerals to your mash water before heating. Dissolve salts in a small amount of water first.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(Color.primaryCard)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}

struct MineralAdditionRow: View {
    let name: String
    let amount: Double
    let description: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(amount, specifier: "%.2f") g")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.brewTheme)
        }
        .padding(.vertical, 4)
    }
} 