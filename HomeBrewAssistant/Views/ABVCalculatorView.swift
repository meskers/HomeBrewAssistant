//
//  ABVCalculatorView.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 09/06/2025.
//

import SwiftUI

struct ABVCalculatorView: View {
    @State private var originalGravity = ""
    @State private var finalGravity = ""
    @State private var calculatedABV = 0.0
    @State private var showingResult = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "percent")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("ABV Calculator")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Bereken het alcoholpercentage van je brouwsel")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Input Fields
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Oorspronkelijke Dichtheid (OG)", systemImage: "drop.fill")
                                .font(.headline)
                            
                            TextField("Bijv. 1.050", text: $originalGravity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            
                            Text("Meet voor de fermentatie begint")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Eind Dichtheid (FG)", systemImage: "drop")
                                .font(.headline)
                            
                            TextField("Bijv. 1.010", text: $finalGravity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($isInputFocused)
                            
                            Text("Meet na de fermentatie")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calculate Button
                    Button(action: calculateABV) {
                        HStack {
                            Image(systemName: "function")
                            Text("Bereken ABV")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(canCalculate ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!canCalculate)
                    .padding(.horizontal)
                    
                    // Result Section
                    if showingResult {
                        VStack(spacing: 15) {
                            Divider()
                            
                            VStack(spacing: 8) {
                                Text("Resultaat")
                                    .font(.headline)
                                
                                Text("\(calculatedABV, specifier: "%.2f")%")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                                
                                Text("Alcohol by Volume")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Additional Info
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Attenuation:")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("\(calculateAttenuation(), specifier: "%.1f")%")
                                }
                                
                                HStack {
                                    Text("Alcohol Yield:")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("\(calculateAlcoholYield(), specifier: "%.2f") g/L")
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Info Section
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Gebruikstips", systemImage: "info.circle")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("• Gebruik een hydrometer of refractometer voor nauwkeurige metingen")
                            Text("• OG moet altijd hoger zijn dan FG")
                            Text("• Typische waarden: OG 1.040-1.080, FG 1.008-1.020")
                            Text("• Formule: ABV = (OG - FG) × 131.25")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("ABV Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        resetCalculator()
                    }
                    .disabled(originalGravity.isEmpty && finalGravity.isEmpty)
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
        !originalGravity.isEmpty && !finalGravity.isEmpty &&
        Double(originalGravity) != nil && Double(finalGravity) != nil
    }
    
    private func calculateABV() {
        guard let og = Double(originalGravity),
              let fg = Double(finalGravity),
              og > fg else { return }
        
        // Standard ABV formula: (OG - FG) × 131.25
        calculatedABV = (og - fg) * 131.25
        showingResult = true
        
        // Hide keyboard
        isInputFocused = false
    }
    
    private func calculateAttenuation() -> Double {
        guard let og = Double(originalGravity),
              let fg = Double(finalGravity) else { return 0 }
        
        return ((og - fg) / (og - 1.0)) * 100
    }
    
    private func calculateAlcoholYield() -> Double {
        guard let og = Double(originalGravity),
              let fg = Double(finalGravity) else { return 0 }
        
        // Approximate alcohol yield in grams per liter
        return (og - fg) * 1000 * 0.789
    }
    
    private func resetCalculator() {
        originalGravity = ""
        finalGravity = ""
        calculatedABV = 0.0
        showingResult = false
    }
}

#Preview {
    ABVCalculatorView()
}
