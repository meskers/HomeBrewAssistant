import SwiftUI

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
                            .font(.body.weight(.bold))
                        
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

#Preview {
    HydrometerCalculatorView()
} 