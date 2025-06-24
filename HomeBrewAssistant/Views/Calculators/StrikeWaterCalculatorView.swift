import SwiftUI

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

#Preview {
    StrikeWaterCalculatorView()
} 