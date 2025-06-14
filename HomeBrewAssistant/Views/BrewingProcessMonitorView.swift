import SwiftUI
import CoreData

struct BrewingProcessMonitorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedProcess: BrewingProcess = .mashing
    @State private var currentStep: Int = 0
    @State private var activeTimers: [ProcessTimer] = []
    @State private var showingTimerCreator = false
    @State private var showingTemperatureLog = false
    @State private var brewingSessionNotes = ""
    @State private var sessionStartTime = Date()
    @State private var isSessionActive = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Session Header
                    sessionHeaderSection
                    
                    // Process Selector
                    processSelector
                    
                    // Current Process Steps
                    currentProcessSection
                    
                    // Active Timers
                    activeTimersSection
                    
                    // Temperature Monitoring
                    temperatureMonitoringSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Session Notes
                    sessionNotesSection
                }
                .padding()
            }
            .navigationTitle("🧪 Brew Monitor")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { startNewSession() }) {
                            Label("Nieuwe Sessie", systemImage: "play.circle")
                        }
                        
                        Button(action: { showingTemperatureLog = true }) {
                            Label("Temperatuur Log", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        
                        Button(action: { exportSession() }) {
                            Label("Exporteer Sessie", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingTimerCreator) {
            TimerCreatorView { timer in
                addTimer(timer)
            }
        }
        .sheet(isPresented: $showingTemperatureLog) {
            TemperatureLogView()
        }
    }
    
    // MARK: - Session Header
    
    private var sessionHeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isSessionActive ? "Actieve Brouw Sessie" : "Brouw Monitor")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if isSessionActive {
                        Text("Gestart: \(timeAgoString(from: sessionStartTime))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Klaar om te beginnen")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Circle()
                        .fill(isSessionActive ? Color.green : Color.gray)
                        .frame(width: 12, height: 12)
                    
                    Text(isSessionActive ? "Actief" : "Inactief")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if isSessionActive {
                HStack(spacing: 16) {
                    quickStatCard(
                        title: "Proces",
                        value: selectedProcess.displayName,
                        icon: selectedProcess.icon,
                        color: selectedProcess.color
                    )
                    
                    quickStatCard(
                        title: "Stap",
                        value: "\(currentStep + 1)/\(selectedProcess.steps.count)",
                        icon: "list.number",
                        color: .blue
                    )
                    
                    quickStatCard(
                        title: "Timers",
                        value: "\(activeTimers.count)",
                        icon: "timer",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func quickStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Process Selector
    
    private var processSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔄 Brouw Proces")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(BrewingProcess.allCases, id: \.self) { process in
                        ProcessCard(
                            process: process,
                            isSelected: selectedProcess == process
                        )
                        .onTapGesture {
                            selectedProcess = process
                            currentStep = 0
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Current Process Section
    
    private var currentProcessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📋 \(selectedProcess.displayName) Stappen")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(Array(selectedProcess.steps.enumerated()), id: \.offset) { index, step in
                    ProcessStepCard(
                        step: step,
                        stepNumber: index + 1,
                        isActive: index == currentStep,
                        isCompleted: index < currentStep,
                        onStepSelected: {
                            currentStep = index
                        },
                        onStepCompleted: {
                            if index == currentStep && index < selectedProcess.steps.count - 1 {
                                currentStep = index + 1
                            }
                        },
                        onTimerRequested: { duration, name in
                                                    let timer = ProcessTimer(
                            name: name,
                            duration: duration,
                            process: selectedProcess.displayName,
                            step: step.title
                        )
                        addTimer(timer)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Active Timers Section
    
    private var activeTimersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("⏱️ Actieve Timers")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingTimerCreator = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.brewTheme)
                }
            }
            .padding(.horizontal)
            
            if activeTimers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "timer")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("Geen actieve timers")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Timer Toevoegen") {
                        showingTimerCreator = true
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(activeTimers) { timer in
                        TimerCard(
                            timer: timer,
                            onPause: { pauseTimer(timer) },
                            onStop: { stopTimer(timer) },
                            onReset: { resetTimer(timer) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Temperature Monitoring
    
    private var temperatureMonitoringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🌡️ Temperatuur Monitor")
                .font(.headline)
                .padding(.horizontal)
            
            TemperatureMonitorCard(
                currentTemp: getCurrentTemperature(),
                targetTemp: getTargetTemperature(),
                onTemperatureLogged: { temp, location in
                    logTemperature(temp, location: location)
                }
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚡ Snelle Acties")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                quickActionButton(
                    title: "Mash Timer",
                    icon: "flame",
                    color: .orange
                ) {
                    addPresetTimer(.mash)
                }
                
                quickActionButton(
                    title: "Hop Timer",
                    icon: "leaf",
                    color: .green
                ) {
                    addPresetTimer(.hopAddition)
                }
                
                quickActionButton(
                    title: "Kook Timer", 
                    icon: "drop.fill",
                    color: .blue
                ) {
                    addPresetTimer(.boil)
                }
                
                quickActionButton(
                    title: "Chill Timer",
                    icon: "snowflake",
                    color: .cyan
                ) {
                    addPresetTimer(.cooling)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func quickActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Session Notes
    
    private var sessionNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📝 Sessie Notities")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                TextEditor(text: $brewingSessionNotes)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
                HStack {
                    Text("Tip: Noteer belangrijke observaties, temperaturen en timings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(brewingSessionNotes.count) tekens")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Functions
    
    private func startNewSession() {
        isSessionActive = true
        sessionStartTime = Date()
        currentStep = 0
        activeTimers.removeAll()
        brewingSessionNotes = ""
    }
    
    private func addTimer(_ timer: ProcessTimer) {
        var newTimer = timer
        newTimer.startTime = Date()
        newTimer.isRunning = true
        activeTimers.append(newTimer)
    }
    
    private func addPresetTimer(_ preset: TimerPreset) {
        let timer = ProcessTimer(
            name: preset.name,
            duration: preset.duration,
            process: selectedProcess.displayName,
            step: selectedProcess.steps[currentStep].title
        )
        addTimer(timer)
    }
    
    private func pauseTimer(_ timer: ProcessTimer) {
        if let index = activeTimers.firstIndex(where: { $0.id == timer.id }) {
            activeTimers[index].isRunning.toggle()
        }
    }
    
    private func stopTimer(_ timer: ProcessTimer) {
        activeTimers.removeAll { $0.id == timer.id }
    }
    
    private func resetTimer(_ timer: ProcessTimer) {
        if let index = activeTimers.firstIndex(where: { $0.id == timer.id }) {
            activeTimers[index].startTime = Date()
            activeTimers[index].isRunning = true
        }
    }
    
    private func getCurrentTemperature() -> Double {
        // Mock temperature - in real app would come from sensors
        return 66.0
    }
    
    private func getTargetTemperature() -> Double {
        // Target based on current process and step
        switch selectedProcess {
        case .mashing:
            return 66.0
        case .boiling:
            return 100.0
        case .cooling:
            return 20.0
        case .fermentation:
            return 18.0
        }
    }
    
    private func logTemperature(_ temp: Double, location: String) {
        // Log temperature reading
        print("Temperature logged: \(temp)°C at \(location)")
    }
    
    private func exportSession() {
        // Export brewing session data
        print("Exporting brewing session...")
    }
    
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        let hours = Int(timeInterval / 3600)
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)u \(minutes)m geleden"
        } else {
            return "\(minutes)m geleden"
        }
    }
}

// MARK: - Supporting Views

struct ProcessCard: View {
    let process: BrewingProcess
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: process.icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : process.color)
            
            Text(process.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(width: 80, height: 80)
        .background(isSelected ? process.color : Color(.systemGray6))
        .cornerRadius(12)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct ProcessStepCard: View {
    let step: BrewingStep
    let stepNumber: Int
    let isActive: Bool
    let isCompleted: Bool
    let onStepSelected: () -> Void
    let onStepCompleted: () -> Void
    let onTimerRequested: (TimeInterval, String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Step indicator
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 30, height: 30)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else {
                        Text("\(stepNumber)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(isActive ? .white : .secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(step.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isActive && !isCompleted {
                    Button("Voltooid") {
                        onStepCompleted()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            if isActive {
                HStack {
                    if let duration = step.suggestedDuration {
                        Button("Timer: \(formatDuration(duration))") {
                            onTimerRequested(duration, step.title)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    
                    if let temp = step.targetTemperature {
                        Text("🌡️ \(Int(temp))°C")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: isActive ? 2 : 1)
        )
        .onTapGesture {
            onStepSelected()
        }
    }
    
    private var circleColor: Color {
        if isCompleted {
            return .green
        } else if isActive {
            return .brewTheme
        } else {
            return .gray
        }
    }
    
    private var backgroundColor: Color {
        if isActive {
            return Color.brewTheme.opacity(0.1)
        } else if isCompleted {
            return Color.green.opacity(0.1)
        } else {
            return Color(.systemBackground)
        }
    }
    
    private var borderColor: Color {
        if isActive {
            return .brewTheme
        } else if isCompleted {
            return .green
        } else {
            return Color(.systemGray4)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes)min"
    }
}

struct TimerCard: View {
    let timer: ProcessTimer
    let onPause: () -> Void
    let onStop: () -> Void
    let onReset: () -> Void
    
    @State private var currentTime = Date()
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(timer.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("\(timer.process) - \(timer.step)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(remainingTimeString)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(remainingTime > 0 ? .brewTheme : .red)
                    
                    Text(timer.isRunning ? "Loopt" : "Gepauzeerd")
                        .font(.caption2)
                        .foregroundColor(timer.isRunning ? .green : .orange)
                }
            }
            
            // Progress bar
            ProgressView(value: progressValue)
                .progressViewStyle(LinearProgressViewStyle(tint: remainingTime > 0 ? .brewTheme : .red))
            
            // Controls
            HStack(spacing: 16) {
                Button(action: onPause) {
                    Image(systemName: timer.isRunning ? "pause.circle" : "play.circle")
                        .font(.title2)
                        .foregroundColor(.brewTheme)
                }
                
                Button(action: onReset) {
                    Image(systemName: "arrow.clockwise.circle")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                Button(action: onStop) {
                    Image(systemName: "stop.circle")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if timer.isRunning {
                currentTime = Date()
            }
        }
    }
    
    private var elapsedTime: TimeInterval {
        guard timer.isRunning else { return 0 }
        return currentTime.timeIntervalSince(timer.startTime ?? Date())
    }
    
    private var remainingTime: TimeInterval {
        max(0, timer.duration - elapsedTime)
    }
    
    private var progressValue: Double {
        guard timer.duration > 0 else { return 0 }
        return min(1.0, elapsedTime / timer.duration)
    }
    
    private var remainingTimeString: String {
        let time = remainingTime
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TemperatureMonitorCard: View {
    let currentTemp: Double
    let targetTemp: Double
    let onTemperatureLogged: (Double, String) -> Void
    
    @State private var newTemperature = ""
    @State private var selectedLocation = "Mash Tun"
    
    private let locations = ["Mash Tun", "Boil Kettle", "Fermenter", "Ambient"]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Huidige Temperatuur")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.1f", currentTemp))°C")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(temperatureColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Doel Temperatuur")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.1f", targetTemp))°C")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.brewTheme)
                }
            }
            
            // Temperature difference indicator
            HStack {
                let difference = currentTemp - targetTemp
                let absDefference = abs(difference)
                
                Image(systemName: difference > 0 ? "arrow.up" : "arrow.down")
                    .foregroundColor(difference > 0 ? .red : .blue)
                
                Text("\(String(format: "%.1f", absDefference))°C \(difference > 0 ? "te warm" : "te koud")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(temperatureStatus)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(temperatureStatusColor)
            }
            
            // Manual temperature entry
            VStack(spacing: 8) {
                HStack {
                    TextField("Temperatuur", text: $newTemperature)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    
                    Picker("Locatie", selection: $selectedLocation) {
                        ForEach(locations, id: \.self) { location in
                            Text(location).tag(location)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Button("Temperatuur Loggen") {
                    if let temp = Double(newTemperature) {
                        onTemperatureLogged(temp, selectedLocation)
                        newTemperature = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(newTemperature.isEmpty)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var temperatureColor: Color {
        let difference = abs(currentTemp - targetTemp)
        if difference <= 1.0 {
            return .green
        } else if difference <= 3.0 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var temperatureStatus: String {
        let difference = abs(currentTemp - targetTemp)
        if difference <= 1.0 {
            return "Perfecte Temperatuur"
        } else if difference <= 3.0 {
            return "Kleine Afwijking"
        } else {
            return "Grote Afwijking"
        }
    }
    
    private var temperatureStatusColor: Color {
        let difference = abs(currentTemp - targetTemp)
        if difference <= 1.0 {
            return .green
        } else if difference <= 3.0 {
            return .orange
        } else {
            return .red
        }
    }
}

struct TimerCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    let onTimerCreated: (ProcessTimer) -> Void
    
    @State private var timerName = ""
    @State private var hours = 0
    @State private var minutes = 15
    @State private var selectedPreset: TimerPreset?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "timer.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.brewTheme)
                    
                    Text("Nieuwe Timer")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                // Preset buttons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Snelle Presets")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(TimerPreset.allCases, id: \.self) { preset in
                            Button(action: { selectPreset(preset) }) {
                                VStack(spacing: 4) {
                                    Text(preset.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text(formatDuration(preset.duration))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(selectedPreset == preset ? Color.brewTheme.opacity(0.2) : Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Manual timer creation
                VStack(spacing: 16) {
                    TextField("Timer Naam", text: $timerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        VStack {
                            Text("Uren")
                                .font(.caption)
                            Picker("Uren", selection: $hours) {
                                ForEach(0...5, id: \.self) { hour in
                                    Text("\(hour)").tag(hour)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 60, height: 80)
                        }
                        
                        VStack {
                            Text("Minuten")
                                .font(.caption)
                            Picker("Minuten", selection: $minutes) {
                                ForEach(0...59, id: \.self) { minute in
                                    Text("\(minute)").tag(minute)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 80, height: 80)
                        }
                    }
                }
                
                Spacer()
                
                // Create button
                Button("Timer Aanmaken") {
                    createTimer()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(timerName.isEmpty || (hours == 0 && minutes == 0))
            }
            .padding()
            .navigationTitle("Timer Aanmaken")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuleren") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func selectPreset(_ preset: TimerPreset) {
        selectedPreset = preset
        timerName = preset.name
        let totalMinutes = Int(preset.duration / 60)
        hours = totalMinutes / 60
        minutes = totalMinutes % 60
    }
    
    private func createTimer() {
        let totalDuration = TimeInterval((hours * 3600) + (minutes * 60))
        let timer = ProcessTimer(
            name: timerName,
            duration: totalDuration,
            process: "Manual",
            step: "Custom Timer"
        )
        onTimerCreated(timer)
        dismiss()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalMinutes = Int(duration / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)u \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct TemperatureLogView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🌡️ Temperatuur Log")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("Coming Soon!")
                        .font(.headline)
                        .foregroundColor(.brewTheme)
                    
                    Text("Hier komt een grafiek met temperatuur geschiedenis en trends.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Temperatuur Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Data Models

struct ProcessTimer: Identifiable {
    let id = UUID()
    let name: String
    let duration: TimeInterval
    let process: String
    let step: String
    var startTime: Date?
    var isRunning = false
}

enum BrewingProcess: String, CaseIterable {
    case mashing = "mashing"
    case boiling = "boiling"
    case cooling = "cooling"
    case fermentation = "fermentation"
    
    var displayName: String {
        switch self {
        case .mashing: return "Mashing"
        case .boiling: return "Koken"
        case .cooling: return "Koelen"
        case .fermentation: return "Fermentatie"
        }
    }
    
    var icon: String {
        switch self {
        case .mashing: return "flame"
        case .boiling: return "drop.fill"
        case .cooling: return "snowflake"
        case .fermentation: return "flask"
        }
    }
    
    var color: Color {
        switch self {
        case .mashing: return .orange
        case .boiling: return .blue
        case .cooling: return .cyan
        case .fermentation: return .purple
        }
    }
    
    var steps: [BrewingStep] {
        switch self {
        case .mashing:
            return [
                BrewingStep(title: "Water Verwarmen", description: "Verwarm strike water naar juiste temperatuur", targetTemperature: 72, suggestedDuration: 900),
                BrewingStep(title: "Mash In", description: "Voeg mout toe aan water", targetTemperature: 66, suggestedDuration: 300),
                BrewingStep(title: "Saccharificatie", description: "Laat enzymen hun werk doen", targetTemperature: 66, suggestedDuration: 3600),
                BrewingStep(title: "Mash Out", description: "Verhoog temperatuur om enzymen te stoppen", targetTemperature: 76, suggestedDuration: 600)
            ]
        case .boiling:
            return [
                BrewingStep(title: "Pre-Boil", description: "Verwarm wort naar kookpunt", targetTemperature: 100, suggestedDuration: 900),
                BrewingStep(title: "Bittering Hops", description: "Voeg bittering hops toe", targetTemperature: 100, suggestedDuration: 60),
                BrewingStep(title: "Flavor Hops", description: "Voeg flavor hops toe", targetTemperature: 100, suggestedDuration: 60),
                BrewingStep(title: "Aroma Hops", description: "Voeg aroma hops toe aan eind kook", targetTemperature: 100, suggestedDuration: 300)
            ]
        case .cooling:
            return [
                BrewingStep(title: "Whirlpool", description: "Creëer whirlpool voor hop utilization", targetTemperature: 80, suggestedDuration: 900),
                BrewingStep(title: "Chilling", description: "Koel wort naar fermentatie temperatuur", targetTemperature: 20, suggestedDuration: 1800),
                BrewingStep(title: "Transfer", description: "Overspoelen naar fermenter", targetTemperature: 20, suggestedDuration: 600)
            ]
        case .fermentation:
            return [
                BrewingStep(title: "Pitch Yeast", description: "Voeg gist toe aan gekoelde wort", targetTemperature: 18, suggestedDuration: 300),
                BrewingStep(title: "Primary Fermentation", description: "Primaire fermentatie", targetTemperature: 18, suggestedDuration: 604800),
                BrewingStep(title: "Secondary", description: "Optionele secondary fermentation", targetTemperature: 18, suggestedDuration: 1209600)
            ]
        }
    }
}

struct BrewingStep {
    let title: String
    let description: String
    let targetTemperature: Double?
    let suggestedDuration: TimeInterval?
}

enum TimerPreset: CaseIterable {
    case mash
    case hopAddition
    case boil
    case cooling
    case dryHop
    case fermentation
    
    var name: String {
        switch self {
        case .mash: return "Mash"
        case .hopAddition: return "Hop Toevoeging"
        case .boil: return "Kook"
        case .cooling: return "Koelen"
        case .dryHop: return "Dry Hop"
        case .fermentation: return "Fermentatie"
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .mash: return 3600 // 60 minutes
        case .hopAddition: return 900 // 15 minutes
        case .boil: return 3600 // 60 minutes
        case .cooling: return 1800 // 30 minutes
        case .dryHop: return 259200 // 3 days
        case .fermentation: return 604800 // 7 days
        }
    }
}

#Preview {
    BrewingProcessMonitorView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 