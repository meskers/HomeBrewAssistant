import SwiftUI
import Foundation

// MARK: - Enhanced Brewing View with Simple and Advanced Modes

enum BrewingViewMode: String, CaseIterable {
    case simple = "🎯 Eenvoudig"
    case advanced = "🔥 Geavanceerd"
    
    var description: String {
        switch self {
        case .simple:
            return "Stap-voor-stap brouwproces met één timer tegelijk - perfect voor beginners"
        case .advanced: 
            return "Professionele monitoring met meerdere parallelle timers - voor ervaren brouwers"
        }
    }
    
    var icon: String {
        switch self {
        case .simple:
            return "timer.circle"
        case .advanced:
            return "gauge.high"
        }
    }
}

struct BrewStep {
    let name: String
    let duration: Int // in minutes, 0 means no timer needed
    let description: String
    let tips: String
    let requiresTemperature: Bool
    let targetTemperature: String
}

struct EnhancedBrewingView: View {
    let selectedRecipe: DetailedRecipe?
    @State private var brewingMode: BrewingViewMode = .simple
    @StateObject private var inventoryManager = SmartInventoryManager()
    @State private var showingInventoryCheck = false
    @State private var inventoryRequirements: [RecipeRequirement] = []
    @State private var inventoryCheckCompleted = false
    
    var inventoryStatus: (available: Int, total: Int, allAvailable: Bool) {
        guard !inventoryRequirements.isEmpty else { return (0, 0, false) }
        let available = inventoryRequirements.filter { $0.isAvailable }.count
        let total = inventoryRequirements.count
        return (available, total, available == total)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Mode Selector Header
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text("🍺 Brouwassistent")
                                .font(.title2)
                                .font(.body.weight(.bold))
                            Text("brewing.choose.experience".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let recipe = selectedRecipe {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("📖 \(recipe.name)")
                                    .font(.caption)
                                    .font(.body.weight(.medium))
                                    .lineLimit(1)
                                Text("✅ Recept actief")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        } else {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("⚠️ Geen recept")
                                    .font(.caption)
                                    .font(.body.weight(.medium))
                                Text("Ga naar Recepten tab")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    // Inventory Status Banner (if recipe selected)
                    if let recipe = selectedRecipe {
                        HStack {
                            Image(systemName: inventoryStatus.allAvailable ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(inventoryStatus.allAvailable ? .green : .orange)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("📋 Voorraadstatus")
                                    .font(.subheadline)
                                    .font(.body.weight(.medium))
                                Text("\(inventoryStatus.available)/\(inventoryStatus.total) ingrediënten beschikbaar")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Controleer") {
                                showingInventoryCheck = true
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(inventoryStatus.allAvailable ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                            .foregroundColor(inventoryStatus.allAvailable ? .green : .orange)
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(inventoryStatus.allAvailable ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(inventoryStatus.allAvailable ? Color.green.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Mode Selector
                    Picker("Brouwmodus", selection: $brewingMode) {
                        ForEach(BrewingViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Mode Description
                    HStack {
                        Image(systemName: brewingMode.icon)
                            .foregroundColor(.brewTheme)
                        Text(brewingMode.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                
                // Content based on selected mode
                Group {
                    switch brewingMode {
                    case .simple:
                        SimpleBrewingModeView(selectedRecipe: selectedRecipe, inventoryStatus: inventoryStatus)
                    case .advanced:
                        AdvancedBrewingModeView(selectedRecipe: selectedRecipe, inventoryStatus: inventoryStatus)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                checkInventoryIfNeeded()
            }
            .onChange(of: selectedRecipe) { _ in
                checkInventoryIfNeeded()
            }
            .sheet(isPresented: $showingInventoryCheck) {
                if let recipe = selectedRecipe {
                    InventoryCheckView(recipe: recipe)
                }
            }
        }
    }
    
    private func checkInventoryIfNeeded() {
        guard let recipe = selectedRecipe else {
            inventoryRequirements = []
            inventoryCheckCompleted = false
            return
        }
        
        // Automatically check inventory when recipe changes
        inventoryRequirements = inventoryManager.checkRecipeRequirements(recipe)
        inventoryCheckCompleted = true
    }
}

// MARK: - Simple Brewing Mode

struct SimpleBrewingModeView: View {
    let selectedRecipe: DetailedRecipe?
    let inventoryStatus: (available: Int, total: Int, allAvailable: Bool)
    @State private var currentStep = 0
    @State private var isTimerRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var stepTimer: Timer?
    @State private var isBrewingActive = false
    @State private var brewingStartTime: Date?
    @State private var showingStepDetail = false
    @State private var currentTemperature = ""
    @State private var currentNotes = ""
    @State private var showingEndBrewAlert = false
    @State private var showingInventoryWarning = false
    
    private var brewingSteps: [BrewStep] {
        if let recipe = selectedRecipe {
            return generateBrewingSteps(from: recipe)
        } else {
            return defaultBrewingSteps
        }
    }
    
    private let defaultBrewingSteps = [
        BrewStep(name: "Voorbereiding", duration: 15, description: "Maak alle apparatuur schoon en bereid ingrediënten voor", tips: "Sanitatie is cruciaal", requiresTemperature: false, targetTemperature: ""),
        BrewStep(name: "Water verwarmen", duration: 30, description: "Verwarm water tot maisch temperatuur", tips: "Gebruik een thermometer", requiresTemperature: true, targetTemperature: "65-68°C"),
        BrewStep(name: "Maischen", duration: 60, description: "Meng mout met warm water", tips: "Roer regelmatig", requiresTemperature: true, targetTemperature: "65°C"),
        BrewStep(name: "Spoelen", duration: 45, description: "Spoel het graan met 78°C water", tips: "Langzaam spoelen", requiresTemperature: true, targetTemperature: "78°C"),
        BrewStep(name: "Koken", duration: 60, description: "Kook de wort en voeg hop toe", tips: "Let op overkoken", requiresTemperature: false, targetTemperature: ""),
        BrewStep(name: "Koelen", duration: 30, description: "Koel wort tot fermentatie temperatuur", tips: "Snel koelen", requiresTemperature: true, targetTemperature: "18-22°C"),
        BrewStep(name: "Gist toevoegen", duration: 10, description: "Voeg gist toe aan gekoelde wort", tips: "Zuurstof toevoeren", requiresTemperature: false, targetTemperature: "")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isBrewingActive {
                    activeBrewingView
                } else {
                    inactiveBrewingView
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingStepDetail) {
            StepDetailView(step: brewingSteps[currentStep])
        }
        .alert("Brouwen beëindigen?", isPresented: $showingEndBrewAlert) {
            Button("Ja") { endBrewing() }
            Button("Annuleer", role: .cancel) { }
        } message: {
            Text("Weet je zeker dat je de brouwsessie wilt beëindigen?")
        }
        .alert("Ontbrekende Ingrediënten", isPresented: $showingInventoryWarning) {
            Button("Toch Doorgaan") { startBrewing() }
            Button("Annuleer", role: .cancel) { }
        } message: {
            Text("Je hebt niet alle ingrediënten op voorraad. Wil je toch doorgaan met brouwen?")
        }
    }
    
    private var activeBrewingView: some View {
        VStack(spacing: 20) {
            // Current Step Card
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    Text("Stap \(currentStep + 1) van \(brewingSteps.count)")
                        .font(.headline)
                        .font(.body.weight(.bold))
                    
                    Spacer()
                    
                    if brewingSteps[currentStep].duration > 0 {
                        Text(formatTime(elapsedTime))
                            .font(.title2)
                            .font(.body.weight(.bold))
                            .foregroundColor(elapsedTime >= TimeInterval(brewingSteps[currentStep].duration * 60) ? .red : .primary)
                    }
                }
                
                Text(brewingSteps[currentStep].name)
                    .font(.title)
                    .font(.body.weight(.bold))
                
                Text(brewingSteps[currentStep].description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if brewingSteps[currentStep].requiresTemperature {
                    HStack {
                        Image(systemName: "thermometer")
                            .foregroundColor(.orange)
                        Text("Doel temperatuur: \(brewingSteps[currentStep].targetTemperature)")
                            .font(.subheadline)
                            .font(.body.weight(.medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Timer Controls
                if brewingSteps[currentStep].duration > 0 {
                    VStack(spacing: 10) {
                        ProgressView(value: elapsedTime, total: TimeInterval(brewingSteps[currentStep].duration * 60))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        
                        HStack(spacing: 15) {
                            Button(isTimerRunning ? "⏸️ Pauzeer" : "▶️ Start Timer") {
                                toggleTimer()
                            }
                            .buttonStyle(.borderedProminent)
                            .accessibilityLabel(isTimerRunning ? "Pauzeer timer" : "Start timer")
                            .accessibilityHint("Start of pauzeer de timer voor deze brouwstap")
                            
                            Button("🔄 Reset") {
                                resetTimer()
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Reset timer")
                            .accessibilityHint("Zet de timer terug naar nul")
                            
                            Spacer()
                            
                            Button("ℹ️ Details") {
                                showingStepDetail = true
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Bekijk stap details")
                            .accessibilityHint("Toon gedetailleerde informatie over deze brouwstap")
                        }
                    }
                } else {
                    HStack(spacing: 15) {
                        Button("✅ Stap Voltooid") {
                            nextStep()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                        
                        Button("ℹ️ Details") {
                            showingStepDetail = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Navigation Buttons
            HStack(spacing: 15) {
                Button("⬅️ Vorige Stap") {
                    previousStep()
                }
                .buttonStyle(.bordered)
                .disabled(currentStep == 0)
                
                Spacer()
                
                if currentStep < brewingSteps.count - 1 {
                    Button("➡️ Volgende Stap") {
                        nextStep()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("🏁 Brouwen Voltooien") {
                        showingEndBrewAlert = true
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(.green)
                }
            }
            
            // End Session Button
            Button("🛑 Sessie Beëindigen") {
                showingEndBrewAlert = true
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
    }
    
    private var inactiveBrewingView: some View {
        VStack(spacing: 20) {
            // Recipe Status
            if let recipe = selectedRecipe {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.brewTheme)
                        Text("Geselecteerd Recept")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Text(recipe.name)
                        .font(.title2)
                        .font(.body.weight(.bold))
                    
                    Text("🍺 \(recipe.style)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                VStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Geen Recept Geselecteerd")
                        .font(.headline)
                    
                    Text("Ga naar de Recepten tab om een recept te selecteren, of start met de standaard brouwstappen.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding(30)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // Brewing Steps Preview
            VStack(alignment: .leading, spacing: 15) {
                Text("Brouwstappen Overzicht")
                    .font(.headline)
                
                LazyVStack(spacing: 8) {
                    ForEach(0..<brewingSteps.count, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .font(.body.weight(.medium))
                                .frame(width: 25, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(brewingSteps[index].name)
                                    .font(.body.weight(.medium))
                                
                                if brewingSteps[index].duration > 0 {
                                    Text("⏱️ \(brewingSteps[index].duration) minuten")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if brewingSteps[index].requiresTemperature {
                                Text("🌡️ \(brewingSteps[index].targetTemperature)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Start Brewing Button
            Button("🚀 Start Brouwsessie") {
                if inventoryStatus.allAvailable {
                    startBrewing()
                } else {
                    showingInventoryWarning = true
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Timer Functions
    
    private func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        stepTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
            
            // Auto-complete when timer finishes
            if brewingSteps[currentStep].duration > 0 && elapsedTime >= TimeInterval(brewingSteps[currentStep].duration * 60) {
                // Timer finished
                stepTimer?.invalidate()
                isTimerRunning = false
                
                // Show completion notification or auto-advance
                if currentStep < brewingSteps.count - 1 {
                    // Auto-advance to next step after a brief pause
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        nextStep()
                    }
                }
            }
        }
    }
    
    private func stopTimer() {
        stepTimer?.invalidate()
        stepTimer = nil
        isTimerRunning = false
    }
    
    private func resetTimer() {
        stopTimer()
        elapsedTime = 0
    }
    
    private func startBrewing() {
        isBrewingActive = true
        brewingStartTime = Date()
        currentStep = 0
        elapsedTime = 0
    }
    
    private func endBrewing() {
        stopTimer()
        isBrewingActive = false
        brewingStartTime = nil
        currentStep = 0
        elapsedTime = 0
    }
    
    private func nextStep() {
        if currentStep < brewingSteps.count - 1 {
            stopTimer()
            currentStep += 1
            elapsedTime = 0
        }
    }
    
    private func previousStep() {
        if currentStep > 0 {
            stopTimer()
            currentStep -= 1
            elapsedTime = 0
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Advanced Brewing Mode

struct AdvancedBrewingModeView: View {
    let selectedRecipe: DetailedRecipe?
    let inventoryStatus: (available: Int, total: Int, allAvailable: Bool)
    @State private var activeTimers: [ProcessTimer] = []
    @State private var completedProcesses: [String] = []
    @State private var sessionStartTime: Date?
    @State private var isSessionActive = false
    @State private var showingAddTimer = false
    @State private var temperatureLog: [TemperatureReading] = []
    @State private var currentTemp = ""
    @State private var sessionNotes = ""
    @State private var selectedProcess: BrewingProcess?
    
    private let standardProcesses = [
        BrewingProcess(name: "Maischen", estimatedDuration: 60, description: "Mout en water mengen", color: .orange),
        BrewingProcess(name: "Spoelen", estimatedDuration: 45, description: "Graan spoelen", color: .blue),
        BrewingProcess(name: "Koken", estimatedDuration: 60, description: "Wort koken", color: .red),
        BrewingProcess(name: "Hop Schema", estimatedDuration: 60, description: "Hop toevoegingen", color: .green),
        BrewingProcess(name: "Koelen", estimatedDuration: 30, description: "Wort koelen", color: .cyan),
        BrewingProcess(name: "Fermentatie", estimatedDuration: 10080, description: "Gisting monitoren", color: .purple)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isSessionActive {
                    activeSessionView
                } else {
                    inactiveSessionView
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingAddTimer) {
            TimerCreatorView { timer in
                activeTimers.append(timer)
            }
        }
    }
    
    private var activeSessionView: some View {
        VStack(spacing: 20) {
            // Session Header
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "timer.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    Text("🔥 Geavanceerde Brouwsessie")
                        .font(.headline)
                        .font(.body.weight(.bold))
                    
                    Spacer()
                    
                    if let startTime = sessionStartTime {
                        Text("Gestart: \(formatSessionTime(startTime))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Actieve Timers: \(activeTimers.count)")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("Voltooid: \(completedProcesses.count)")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Active Timers
            if !activeTimers.isEmpty {
                VStack(alignment: .leading, spacing: 15) {
                    Text("🔥 Actieve Timers")
                        .font(.headline)
                    
                    ForEach(activeTimers.indices, id: \.self) { index in
                        TimerCard(timer: $activeTimers[index]) {
                            // Timer completed
                            let completedTimer = activeTimers[index]
                            completedProcesses.append(completedTimer.name)
                            activeTimers.remove(at: index)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // Quick Process Buttons
            VStack(alignment: .leading, spacing: 15) {
                Text("⚡ Snelle Acties")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(standardProcesses, id: \.name) { process in
                        ProcessCard(process: process) {
                            addProcessTimer(process)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Temperature Logging
            VStack(alignment: .leading, spacing: 15) {
                Text("🌡️ Temperatuur Log")
                    .font(.headline)
                
                HStack {
                    TextField("Temperatuur °C", text: $currentTemp)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("📝 Log") {
                        logTemperature()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(currentTemp.isEmpty)
                }
                
                if !temperatureLog.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(temperatureLog.suffix(5), id: \.timestamp) { reading in
                                VStack(spacing: 4) {
                                    Text("\(reading.temperature, specifier: "%.1f")°C")
                                        .font(.headline)
                                        .font(.body.weight(.bold))
                                    Text(formatTime(reading.timestamp))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Session Notes
            VStack(alignment: .leading, spacing: 15) {
                Text("📝 Sessie Notities")
                    .font(.headline)
                
                TextEditor(text: $sessionNotes)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Session Controls
            HStack(spacing: 15) {
                Button("➕ Nieuwe Timer") {
                    showingAddTimer = true
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("🏁 Sessie Beëindigen") {
                    endSession()
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(.red)
            }
        }
    }
    
    private var inactiveSessionView: some View {
        VStack(spacing: 20) {
            // Recipe info if available
            if let recipe = selectedRecipe {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.brewTheme)
                        Text("Recept voor Geavanceerde Sessie")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Text(recipe.name)
                        .font(.title2)
                        .font(.body.weight(.bold))
                    
                    Text("🍺 \(recipe.style)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // Advanced Mode Features
            VStack(alignment: .leading, spacing: 15) {
                Text("🔥 Geavanceerde Functies")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    FeatureRow(icon: "timer.square", title: "Parallelle Timers", description: "Meerdere processen tegelijk monitoren")
                    FeatureRow(icon: "thermometer", title: "Temperatuur Logging", description: "Real-time temperatuur bijhouden")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Proces Analytics", description: "Gedetailleerde brewing data")
                    FeatureRow(icon: "note.text", title: "Uitgebreide Notities", description: "Volledige sessie documentatie")
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Process Preview
            VStack(alignment: .leading, spacing: 15) {
                Text("⚡ Beschikbare Processen")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(standardProcesses, id: \.name) { process in
                        VStack(spacing: 8) {
                            Circle()
                                .fill(process.color.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(process.name.prefix(2))
                                        .font(.caption)
                                        .font(.body.weight(.bold))
                                        .foregroundColor(process.color)
                                )
                            
                            Text(process.name)
                                .font(.caption)
                                .font(.body.weight(.medium))
                                .multilineTextAlignment(.center)
                            
                            Text("\(process.estimatedDuration) min")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Start Session Button
            Button("🚀 Start Geavanceerde Sessie") {
                startSession()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Helper Functions
    
    private func startSession() {
        isSessionActive = true
        sessionStartTime = Date()
        activeTimers = []
        completedProcesses = []
        temperatureLog = []
        sessionNotes = ""
    }
    
    private func endSession() {
        isSessionActive = false
        sessionStartTime = nil
        activeTimers = []
    }
    
    private func addProcessTimer(_ process: BrewingProcess) {
        let timer = ProcessTimer(
            name: process.name,
            duration: TimeInterval(process.estimatedDuration * 60),
            color: process.color,
            description: process.description
        )
        activeTimers.append(timer)
    }
    
    private func logTemperature() {
        if let temp = Double(currentTemp) {
            let reading = TemperatureReading(temperature: temp, timestamp: Date())
            temperatureLog.append(reading)
            currentTemp = ""
        }
    }
    
    private func formatSessionTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Structures

struct ProcessTimer: Identifiable {
    let id = UUID()
    let name: String
    let duration: TimeInterval
    let color: Color
    let description: String
    var elapsedTime: TimeInterval = 0
    var isRunning: Bool = false
    var isCompleted: Bool = false
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(elapsedTime / duration, 1.0)
    }
    
    var remainingTime: TimeInterval {
        max(duration - elapsedTime, 0)
    }
}

struct BrewingProcess {
    let name: String
    let estimatedDuration: Int // minutes
    let description: String
    let color: Color
}

struct TemperatureReading {
    let temperature: Double
    let timestamp: Date
}

// MARK: - Helper Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.brewTheme)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .font(.body.weight(.medium))
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct ProcessCard: View {
    let process: BrewingProcess
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Circle()
                    .fill(process.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "plus")
                            .foregroundColor(process.color)
                            .font(.headline)
                    )
                
                Text(process.name)
                    .font(.caption)
                    .font(.body.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text("\(process.estimatedDuration) min")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.primaryCard)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct TimerCard: View {
    @Binding var timer: ProcessTimer
    @State private var internalTimer: Timer?
    let onComplete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(timer.color.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(timer.name.prefix(2))
                            .font(.caption2)
                            .font(.body.weight(.bold))
                            .foregroundColor(timer.color)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(timer.name)
                        .font(.subheadline)
                        .font(.body.weight(.medium))
                    Text(timer.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(formatTimerTime(timer.remainingTime))
                    .font(.headline)
                    .font(.body.weight(.bold))
                    .foregroundColor(timer.isCompleted ? .green : .primary)
            }
            
            ProgressView(value: timer.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: timer.color))
            
            HStack(spacing: 12) {
                Button(timer.isRunning ? "⏸️ Pauzeer" : "▶️ Start") {
                    toggleTimer()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("🔄 Reset") {
                    resetTimer()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
                
                if timer.isCompleted {
                    Button("✅ Voltooid") {
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
        }
        .padding()
        .background(Color.primaryCard)
        .cornerRadius(12)
        .onAppear {
            if timer.isRunning {
                startInternalTimer()
            }
        }
        .onDisappear {
            stopInternalTimer()
        }
    }
    
    private func toggleTimer() {
        timer.isRunning.toggle()
        if timer.isRunning {
            startInternalTimer()
        } else {
            stopInternalTimer()
        }
    }
    
    private func resetTimer() {
        stopInternalTimer()
        timer.isRunning = false
        timer.elapsedTime = 0
        timer.isCompleted = false
    }
    
    private func startInternalTimer() {
        internalTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timer.elapsedTime += 1
            
            if timer.elapsedTime >= timer.duration {
                timer.isCompleted = true
                timer.isRunning = false
                stopInternalTimer()
            }
        }
    }
    
    private func stopInternalTimer() {
        internalTimer?.invalidate()
        internalTimer = nil
    }
    
    private func formatTimerTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct StepDetailView: View {
    let step: BrewStep
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text(step.name)
                    .font(.title)
                    .font(.body.weight(.bold))
                
                Text(step.description)
                    .font(.body)
                
                if step.requiresTemperature {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🌡️ Temperatuur")
                            .font(.headline)
                        Text("Doel: \(step.targetTemperature)")
                            .font(.subheadline)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Tips")
                        .font(.headline)
                    Text(step.tips)
                        .font(.body)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                if step.duration > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("⏱️ Tijd")
                            .font(.headline)
                        Text("\(step.duration) minuten")
                            .font(.subheadline)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Stap Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TimerCreatorView: View {
    let onTimerCreated: (ProcessTimer) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var duration = 60
    @State private var description = ""
    @State private var selectedColor = Color.blue
    
    private let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .cyan]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Timer Details") {
                    TextField("Timer naam", text: $name)
                    TextField("Beschrijving", text: $description)
                    
                    Stepper("Duur: \(duration) minuten", value: $duration, in: 1...999)
                }
                
                Section("Kleur") {
                    HStack {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
            }
            .navigationTitle("Nieuwe Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuleer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Toevoegen") {
                        createTimer()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func createTimer() {
        let timer = ProcessTimer(
            name: name,
            duration: TimeInterval(duration * 60),
            color: selectedColor,
            description: description
        )
        onTimerCreated(timer)
        dismiss()
    }
}

// MARK: - Helper Function

func generateBrewingSteps(from recipe: DetailedRecipe) -> [BrewStep] {
    var steps: [BrewStep] = []
    
    // Extract ingredients by type
    let grainIngredients = recipe.ingredients.filter { $0.type == .grain }
    let hopIngredients = recipe.ingredients.filter { $0.type == .hop }
    let yeastIngredients = recipe.ingredients.filter { $0.type == .yeast }
    
    // Add basic steps
    steps.append(BrewStep(name: "Voorbereiding", duration: 15, description: "Apparatuur schoonmaken en ingrediënten klaarzetten", tips: "Sanitatie is essentieel", requiresTemperature: false, targetTemperature: ""))
    
    steps.append(BrewStep(name: "Water verwarmen", duration: 30, description: "Verwarm water voor brouwen", tips: "Gebruik gefilterd water", requiresTemperature: true, targetTemperature: "65-68°C"))
    
    if !grainIngredients.isEmpty {
        steps.append(BrewStep(name: "Maischen", duration: 60, description: "Meng \(grainIngredients.map { $0.name }.joined(separator: ", "))", tips: "Houd temperatuur constant", requiresTemperature: true, targetTemperature: "65°C"))
    }
    
    if !hopIngredients.isEmpty {
        steps.append(BrewStep(name: "Koken", duration: 60, description: "Voeg hop toe: \(hopIngredients.map { $0.name }.joined(separator: ", "))", tips: "Let op overkoken", requiresTemperature: false, targetTemperature: ""))
    }
    
    steps.append(BrewStep(name: "Koelen", duration: 30, description: "Koel tot gist temperatuur", tips: "Snel koelen voorkomt infectie", requiresTemperature: true, targetTemperature: "18-22°C"))
    
    if !yeastIngredients.isEmpty {
        steps.append(BrewStep(name: "Gist toevoegen", duration: 10, description: "Voeg \(yeastIngredients.first?.name ?? "gist") toe", tips: "Beluchten voor zuurstof", requiresTemperature: false, targetTemperature: ""))
    }
    
    return steps
} 