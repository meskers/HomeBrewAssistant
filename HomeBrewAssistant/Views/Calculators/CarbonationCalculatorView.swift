import SwiftUI

struct CarbonationCalculatorView: View {
    @State private var batchSize: String = "20.0"
    @State private var beerTemperature: String = "20.0"
    @State private var targetCO2: String = "2.4"
    @State private var primingSugarType: PrimingSugarType = .dextrose
    @State private var calculatedSugar: Double = 0
    @State private var selectedBeerStyle: BeerStyle = .ale
    @Environment(\.presentationMode) var presentationMode
    
    enum PrimingSugarType: String, CaseIterable {
        case dextrose = "Dextrose (Corn Sugar)"
        case sucrose = "Sucrose (Table Sugar)"
        case dme = "Dry Malt Extract"
        case honey = "Honey"
        
        var conversionFactor: Double {
            switch self {
            case .dextrose: return 1.0
            case .sucrose: return 0.90
            case .dme: return 1.33
            case .honey: return 0.75
            }
        }
    }
    
    enum BeerStyle: String, CaseIterable {
        case lager = "Lager"
        case ale = "Ale"
        case wheat = "Wheat Beer"
        case belgian = "Belgian"
        case stout = "Stout"
        case ipa = "IPA"
        
        var recommendedCO2: Double {
            switch self {
            case .lager: return 2.6
            case .ale: return 2.2
            case .wheat: return 3.2
            case .belgian: return 2.8
            case .stout: return 1.8
            case .ipa: return 2.4
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "bubbles.and.sparkles")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("CO₂ Calculator")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Calculate priming sugar for carbonation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Beer Style Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Beer Style")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(BeerStyle.allCases, id: \.self) { style in
                                    Button(action: {
                                        selectedBeerStyle = style
                                        targetCO2 = String(format: "%.1f", style.recommendedCO2)
                                    }) {
                                        VStack(spacing: 4) {
                                            Text(style.rawValue)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                            Text("\(style.recommendedCO2, specifier: "%.1f") vol")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedBeerStyle == style ?
                                            Color.blue : Color(.systemGray6)
                                        )
                                        .foregroundColor(
                                            selectedBeerStyle == style ?
                                            .white : .primary
                                        )
                                        .cornerRadius(8)
                                    }
                                    .accessibilityLabel("Select \(style.rawValue) style")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Parameters
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Beer Parameters")
                            .font(.headline)
                        
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Batch Size")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    HStack {
                                        TextField("20.0", text: $batchSize)
                                            .keyboardType(.decimalPad)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        
                                        Text("L")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Temperature")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    HStack {
                                        TextField("20.0", text: $beerTemperature)
                                            .keyboardType(.decimalPad)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        
                                        Text("°C")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Target CO₂")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    TextField("2.4", text: $targetCO2)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Text("volumes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Priming Sugar Type
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Priming Sugar Type")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            ForEach(PrimingSugarType.allCases, id: \.self) { sugar in
                                Button(action: {
                                    primingSugarType = sugar
                                }) {
                                    HStack {
                                        Text(sugar.rawValue)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        if primingSugarType == sugar {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                    .shadow(radius: 1)
                                }
                                .foregroundColor(.primary)
                                .accessibilityLabel("Select \(sugar.rawValue)")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calculate Button & Results
                    VStack(spacing: 16) {
                        Button("Calculate Priming Sugar") {
                            calculatePrimingSugar()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        if calculatedSugar > 0 {
                            VStack(spacing: 12) {
                                Text("Priming Sugar Required")
                                    .font(.headline)
                                
                                Text("\(calculatedSugar, specifier: "%.1f") g")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Text("of \(primingSugarType.rawValue)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("For \(batchSize) L batch at \(beerTemperature)°C")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // Additional info
                                VStack(spacing: 4) {
                                    Text("Instructions:")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    
                                    Text("• Dissolve sugar in small amount of boiling water")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Text("• Cool to room temperature before adding to beer")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Text("• Mix gently and bottle immediately")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 8)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("CO₂ Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func calculatePrimingSugar() {
        let batchSizeDouble = Double(batchSize) ?? 20.0
        let tempDouble = Double(beerTemperature) ?? 20.0
        let targetCO2Double = Double(targetCO2) ?? 2.4
        
        // Calculate existing CO2 based on temperature
        let existingCO2 = 3.0378 - (0.050062 * tempDouble) + (0.00026555 * tempDouble * tempDouble)
        
        // Calculate CO2 needed
        let co2Needed = max(0, targetCO2Double - existingCO2)
        
        // Base priming sugar calculation (for dextrose)
        let baseSugar = co2Needed * 4.0 * batchSizeDouble
        
        // Adjust for sugar type
        calculatedSugar = baseSugar * primingSugarType.conversionFactor
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

struct CarbonationCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CarbonationCalculatorView()
    }
} 