import SwiftUI

struct IBUCalculatorView: View {
    @State private var batchSize: String = "20.0"
    @State private var boilGravity: String = "1.050"
    @State private var hopAdditions: [HopAddition] = []
    @State private var showingAddHop = false
    @State private var calculatedIBU: Double = 0
    @State private var utilizationMethod: UtilizationMethod = .tinseth
    @Environment(\.presentationMode) var presentationMode
    
    enum UtilizationMethod: String, CaseIterable {
        case tinseth = "Tinseth"
        case rager = "Rager"
        case garetz = "Garetz"
        
        var description: String {
            switch self {
            case .tinseth: return "Most commonly used formula"
            case .rager: return "Traditional formula, conservative"
            case .garetz: return "Advanced formula with hop form factors"
            }
        }
    }
    
    struct HopAddition: Identifiable, Codable {
        let id: UUID
        var name: String
        var alphaAcids: Double
        var amount: Double // grams
        var time: Double // minutes
        var form: HopForm
        
        init(name: String, alphaAcids: Double, amount: Double, time: Double, form: HopForm) {
            self.id = UUID()
            self.name = name
            self.alphaAcids = alphaAcids
            self.amount = amount
            self.time = time
            self.form = form
        }
        
        enum HopForm: String, CaseIterable, Codable {
            case pellet = "Pellet"
            case whole = "Whole"
            case plug = "Plug"
            
            var utilizationFactor: Double {
                switch self {
                case .pellet: return 1.0
                case .whole: return 0.85
                case .plug: return 0.90
                }
            }
        }
        
        func calculateIBU(batchSize: Double, gravity: Double, method: UtilizationMethod) -> Double {
            let utilization = calculateUtilization(gravity: gravity, time: time, method: method)
            let ibu = (alphaAcids * amount * utilization * form.utilizationFactor) / (batchSize * 10)
            return max(0, ibu)
        }
        
        private func calculateUtilization(gravity: Double, time: Double, method: UtilizationMethod) -> Double {
            switch method {
            case .tinseth:
                return calculateTinsethUtilization(gravity: gravity, time: time)
            case .rager:
                return calculateRagerUtilization(gravity: gravity, time: time)
            case .garetz:
                return calculateGaretzUtilization(gravity: gravity, time: time)
            }
        }
        
        private func calculateTinsethUtilization(gravity: Double, time: Double) -> Double {
            let bignessFactor = 1.65 * pow(0.000125, gravity - 1.0)
            let boilTimeFactor = (1 - exp(-0.04 * time)) / 4.15
            return bignessFactor * boilTimeFactor
        }
        
        private func calculateRagerUtilization(gravity: Double, time: Double) -> Double {
            let gravityFactor = (gravity > 1.050) ? (gravity - 1.050) / 0.2 : 0
            let utilization = (18.11 + 13.86 * tanh((time - 31.32) / 18.27)) / 100
            return max(0, utilization - gravityFactor)
        }
        
        private func calculateGaretzUtilization(gravity: Double, time: Double) -> Double {
            // Simplified Garetz formula
            let baseUtilization = calculateTinsethUtilization(gravity: gravity, time: time)
            let concentrationFactor = (gravity > 1.050) ? 1 + (gravity - 1.050) / 0.2 * 0.2 : 1
            return baseUtilization / concentrationFactor
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.hopGreen)
                            .accessibilityHidden(true)
                        
                        Text("IBU Calculator")
                            .font(.largeTitle)
                            .font(.body.weight(.bold))
                            .accessibilityLabel("International Bitterness Units Calculator")
                        
                        Text("Calculate hop bitterness for your brew")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Batch Parameters
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Batch Parameters")
                            .font(.headline)
                            .accessibilityLabel("Batch parameters section")
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Batch Size")
                                    .font(.caption)
                                    .font(.body.weight(.medium))
                                
                                HStack {
                                    TextField("20.0", text: $batchSize)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .accessibilityLabel("Batch size input")
                                        .accessibilityHint("Enter batch size in liters")
                                    
                                    Text("L")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Boil Gravity")
                                    .font(.caption)
                                    .font(.body.weight(.medium))
                                
                                TextField("1.050", text: $boilGravity)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .accessibilityLabel("Boil gravity input")
                                    .accessibilityHint("Enter specific gravity during boil")
                            }
                        }
                        
                        // Utilization Method
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Utilization Formula")
                                .font(.caption)
                                .font(.body.weight(.medium))
                            
                            Picker("Method", selection: $utilizationMethod) {
                                ForEach(UtilizationMethod.allCases, id: \.self) { method in
                                    Text(method.rawValue).tag(method)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .accessibilityLabel("Utilization method picker")
                            
                            Text(utilizationMethod.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Hop Additions
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Hop Additions")
                                .font(.headline)
                                .accessibilityLabel("Hop additions section")
                            
                            Spacer()
                            
                            Button(action: { showingAddHop = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                    Text("Add Hop")
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.hopGreen)
                                .cornerRadius(8)
                            }
                            .accessibilityLabel("Add new hop addition")
                        }
                        
                        if hopAdditions.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "leaf")
                                    .font(.system(size: 40))
                                    .foregroundColor(.hopGreen.opacity(0.5))
                                
                                Text("No hop additions yet")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Add your first hop to calculate IBU")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .accessibilityLabel("No hop additions, tap add hop to get started")
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(hopAdditions) { hop in
                                    HopAdditionCard(
                                        hop: hop,
                                        batchSize: Double(batchSize) ?? 20.0,
                                        gravity: Double(boilGravity) ?? 1.050,
                                        method: utilizationMethod,
                                        onDelete: { deleteHop(hop) }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calculate Button & Results
                    VStack(spacing: 16) {
                        Button(action: calculateIBU) {
                            HStack {
                                Image(systemName: "function")
                                Text("Calculate IBU")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hopAdditions.isEmpty ? Color.gray : Color.hopGreen)
                            .cornerRadius(12)
                        }
                        .disabled(hopAdditions.isEmpty)
                        .padding(.horizontal)
                        .accessibilityLabel("Calculate total IBU")
                        .accessibilityHint("Calculate bitterness from all hop additions")
                        
                        if calculatedIBU > 0 {
                            IBUResultsView(
                                totalIBU: calculatedIBU,
                                hopAdditions: hopAdditions,
                                batchSize: Double(batchSize) ?? 20.0,
                                gravity: Double(boilGravity) ?? 1.050,
                                method: utilizationMethod
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
            }
            .navigationTitle("IBU Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingAddHop) {
                AddHopView { hop in
                    hopAdditions.append(hop)
                    calculateIBU()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: calculatedIBU)
        .animation(.easeInOut(duration: 0.3), value: hopAdditions.count)
    }
    
    private func calculateIBU() {
        let batchSizeDouble = Double(batchSize) ?? 20.0
        let gravityDouble = Double(boilGravity) ?? 1.050
        
        calculatedIBU = hopAdditions.reduce(0) { total, hop in
            total + hop.calculateIBU(batchSize: batchSizeDouble, gravity: gravityDouble, method: utilizationMethod)
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func deleteHop(_ hop: HopAddition) {
        if let index = hopAdditions.firstIndex(where: { $0.id == hop.id }) {
            hopAdditions.remove(at: index)
            calculateIBU()
        }
    }
}

struct HopAdditionCard: View {
    let hop: IBUCalculatorView.HopAddition
    let batchSize: Double
    let gravity: Double
    let method: IBUCalculatorView.UtilizationMethod
    let onDelete: () -> Void
    
    private var individualIBU: Double {
        hop.calculateIBU(batchSize: batchSize, gravity: gravity, method: method)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(hop.name)
                        .font(.headline)
                        .font(.body.weight(.semibold))
                        .accessibilityLabel("Hop name: \(hop.name)")
                    
                    Text("\(hop.alphaAcids, specifier: "%.1f")% AA • \(hop.form.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(individualIBU, specifier: "%.1f")")
                        .font(.title2)
                        .font(.body.weight(.bold))
                        .foregroundColor(.hopGreen)
                    
                    Text("IBU")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("\(individualIBU, specifier: "%.1f") IBU contribution")
            }
            
            HStack {
                Label("\(hop.amount, specifier: "%.0f")g", systemImage: "scalemass")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label("\(hop.time, specifier: "%.0f") min", systemImage: "timer")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Spacer()
                
                Button(action: onDelete) {
                    Text("Delete")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibilityElement(children: .combine)
    }
}

struct IBUResultsView: View {
    let totalIBU: Double
    let hopAdditions: [IBUCalculatorView.HopAddition]
    let batchSize: Double
    let gravity: Double
    let method: IBUCalculatorView.UtilizationMethod
    
    private var bitterness: (String, Color, String) {
        switch totalIBU {
        case 0..<10:
            return ("Very Low", .green, "Subtle bitterness")
        case 10..<20:
            return ("Low", .yellow, "Mild bitterness")
        case 20..<40:
            return ("Moderate", .orange, "Balanced bitterness")
        case 40..<60:
            return ("High", .red, "Pronounced bitterness")
        case 60..<100:
            return ("Very High", .purple, "Intense bitterness")
        default:
            return ("Extreme", .black, "Extremely bitter")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Total IBU Display
            HStack {
                VStack(alignment: .leading) {
                    Text("Total IBU")
                        .font(.headline)
                        .accessibilityLabel("Total bitterness")
                    
                    Text("\(totalIBU, specifier: "%.1f")")
                        .font(.largeTitle)
                        .font(.body.weight(.bold))
                        .foregroundColor(.hopGreen)
                        .accessibilityLabel("\(totalIBU, specifier: "%.1f") International Bitterness Units")
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(bitterness.0)
                        .font(.headline)
                        .font(.body.weight(.bold))
                        .foregroundColor(bitterness.1)
                    
                    Text(bitterness.2)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                .accessibilityLabel("Bitterness level: \(bitterness.0), \(bitterness.2)")
            }
            
            // Individual Contributions
            if hopAdditions.count > 1 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Individual Contributions")
                        .font(.subheadline)
                        .font(.body.weight(.medium))
                    
                    ForEach(hopAdditions) { hop in
                        let individualIBU = hop.calculateIBU(batchSize: batchSize, gravity: gravity, method: method)
                        let percentage = (individualIBU / totalIBU) * 100
                        
                        HStack {
                            Text(hop.name)
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("\(individualIBU, specifier: "%.1f") IBU (\(percentage, specifier: "%.0f")%)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .accessibilityLabel("\(hop.name): \(individualIBU, specifier: "%.1f") IBU, \(percentage, specifier: "%.0f") percent of total")
                    }
                }
            }
            
            // Method Info
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .accessibilityHidden(true)
                
                Text("Calculated using \(method.rawValue) formula")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct AddHopView: View {
    @State private var hopName: String = ""
    @State private var alphaAcids: String = ""
    @State private var amount: String = ""
    @State private var time: String = ""
    @State private var form: IBUCalculatorView.HopAddition.HopForm = .pellet
    @Environment(\.presentationMode) var presentationMode
    
    let onAdd: (IBUCalculatorView.HopAddition) -> Void
    
    // Common hop varieties with typical AA ranges
    private let commonHops = [
        ("Cascade", "4.5-7.0%"),
        ("Centennial", "9.5-11.5%"),
        ("Chinook", "12.0-14.0%"),
        ("Citra", "11.0-13.0%"),
        ("Columbus", "14.0-18.0%"),
        ("Fuggle", "4.0-5.5%")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.hopGreen)
                        
                        Text("Add Hop Addition")
                            .font(.title2)
                            .font(.body.weight(.bold))
                    }
                    .padding(.top)
                    
                    // Hop Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Hop Variety")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Enter hop name", text: $hopName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .accessibilityLabel("Hop variety name")
                            
                            Text("Common Varieties:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(commonHops, id: \.0) { hop in
                                    Button(action: { 
                                        hopName = hop.0
                                        // Set typical AA range midpoint
                                        if let range = parseAARange(hop.1) {
                                            alphaAcids = String(format: "%.1f", range)
                                        }
                                    }) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(hop.0)
                                                .font(.caption)
                                                .font(.body.weight(.medium))
                                            Text(hop.1)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(6)
                                    }
                                    .foregroundColor(.primary)
                                    .accessibilityLabel("Select \(hop.0) hop")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Hop Parameters
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Hop Parameters")
                            .font(.headline)
                        
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Alpha Acids (%)")
                                        .font(.caption)
                                        .font(.body.weight(.medium))
                                    
                                    TextField("6.0", text: $alphaAcids)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .accessibilityLabel("Alpha acids percentage")
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Amount (g)")
                                        .font(.caption)
                                        .font(.body.weight(.medium))
                                    
                                    TextField("25", text: $amount)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .accessibilityLabel("Hop amount in grams")
                                }
                            }
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Boil Time (min)")
                                        .font(.caption)
                                        .font(.body.weight(.medium))
                                    
                                    TextField("60", text: $time)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .accessibilityLabel("Boil time in minutes")
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Hop Form")
                                        .font(.caption)
                                        .font(.body.weight(.medium))
                                    
                                    Picker("Form", selection: $form) {
                                        ForEach(IBUCalculatorView.HopAddition.HopForm.allCases, id: \.self) { hopForm in
                                            Text(hopForm.rawValue).tag(hopForm)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .accessibilityLabel("Hop form picker")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Add Button
                    Button(action: addHop) {
                        Text("Add Hop Addition")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValidInput ? Color.hopGreen : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isValidInput)
                    .padding(.horizontal)
                    .accessibilityLabel("Add hop addition to recipe")
                }
            }
            .navigationTitle("Add Hop")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private var isValidInput: Bool {
        !hopName.isEmpty &&
        !alphaAcids.isEmpty && Double(alphaAcids) != nil &&
        !amount.isEmpty && Double(amount) != nil &&
        !time.isEmpty && Double(time) != nil
    }
    
    private func addHop() {
        guard isValidInput,
              let aa = Double(alphaAcids),
              let amt = Double(amount),
              let tm = Double(time) else { return }
        
        let hop = IBUCalculatorView.HopAddition(
            name: hopName,
            alphaAcids: aa,
            amount: amt,
            time: tm,
            form: form
        )
        
        onAdd(hop)
        presentationMode.wrappedValue.dismiss()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func parseAARange(_ range: String) -> Double? {
        let components = range.replacingOccurrences(of: "%", with: "").split(separator: "-")
        guard components.count == 2,
              let min = Double(components[0]),
              let max = Double(components[1]) else { return nil }
        return (min + max) / 2
    }
}

// Preview
struct IBUCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        IBUCalculatorView()
    }
} 