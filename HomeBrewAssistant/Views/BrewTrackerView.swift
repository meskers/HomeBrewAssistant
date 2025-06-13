//
//  BrewTrackerView.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 09/06/2025.
//

import SwiftUI
import UserNotifications
import AudioToolbox

// MARK: - Enhanced Timer Models
struct BrewTimer: Identifiable, Codable {
    let id: UUID
    var name: String
    var totalDuration: TimeInterval // in seconds
    var remainingTime: TimeInterval
    var isRunning: Bool = false
    var isPaused: Bool = false
    var isCompleted: Bool = false
    var category: TimerCategory
    var startTime: Date?
    var endTime: Date?
    var notificationSound: TimerSound = .default
    var enableVibration: Bool = true
    var backgroundStartTime: Date?
    
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (remainingTime / totalDuration)
    }
    
    var isOvertime: Bool {
        return remainingTime < 0
    }
    
    var displayTime: String {
        let absTime = abs(remainingTime)
        let hours = Int(absTime) / 3600
        let minutes = (Int(absTime) % 3600) / 60
        let seconds = Int(absTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var urgencyLevel: TimerUrgency {
        if isCompleted { return .completed }
        if isOvertime { return .overtime }
        if remainingTime <= 60 { return .critical }
        if remainingTime <= 300 { return .warning }
        return .normal
    }
}

enum TimerCategory: String, CaseIterable, Codable {
    case mashing = "Maischen"
    case boiling = "Koken"
    case hopping = "Hoppen"
    case cooling = "Koelen"
    case fermentation = "Gisting"
    case conditioning = "Lagering"
    case other = "Anders"
    
    var icon: String {
        switch self {
        case .mashing: return "thermometer"
        case .boiling: return "flame"
        case .hopping: return "leaf"
        case .cooling: return "snowflake"
        case .fermentation: return "drop.circle"
        case .conditioning: return "hourglass"
        case .other: return "timer"
        }
    }
    
    var color: Color {
        switch self {
        case .mashing: return .orange
        case .boiling: return .red
        case .hopping: return .green
        case .cooling: return .blue
        case .fermentation: return .purple
        case .conditioning: return .brown
        case .other: return .gray
        }
    }
}

enum TimerSound: String, CaseIterable, Codable {
    case `default` = "default"
    case chime = "chime"
    case bell = "bell"
    case alarm = "alarm"
    case gentle = "gentle"
    
    var displayName: String {
        switch self {
        case .default: return "Standaard"
        case .chime: return "Chime"
        case .bell: return "Bel"
        case .alarm: return "Alarm"
        case .gentle: return "Zacht"
        }
    }
    
    var systemSound: UNNotificationSound {
        switch self {
        case .default: return .default
        case .chime: return .defaultCritical
        case .bell: return .default
        case .alarm: return .defaultCritical
        case .gentle: return .default
        }
    }
}

enum TimerUrgency {
    case normal, warning, critical, overtime, completed
    
    var color: Color {
        switch self {
        case .normal: return .primary
        case .warning: return .orange
        case .critical: return .red
        case .overtime: return .red
        case .completed: return .green
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .normal: return Color(.systemGray6)
        case .warning: return Color.orange.opacity(0.1)
        case .critical: return Color.red.opacity(0.1)
        case .overtime: return Color.red.opacity(0.2)
        case .completed: return Color.green.opacity(0.1)
        }
    }
}

// MARK: - Enhanced Brew Tracker View
struct BrewTrackerView: View {
    @StateObject private var timerManager = BrewTimerManager()
    @State private var showingAddTimer = false
    @State private var showingPresets = false
    @State private var selectedTimerCategory: TimerCategory = .mashing
    @State private var customTimerMinutes: Int = 60
    @State private var customTimerName: String = ""
    @State private var currentStep = 0
    @State private var brewStartDate = Date()
    @State private var isBrewingActive = false
    
    // Preset timers for common brewing tasks
    private let presetTimers: [String: (duration: Int, category: TimerCategory)] = [
        "Maischen (60 min)": (60, .mashing),
        "Maischen (90 min)": (90, .mashing),
        "Koken (60 min)": (60, .boiling),
        "Koken (90 min)": (90, .boiling),
        "Bittering Hops (60 min)": (60, .hopping),
        "Aroma Hops (15 min)": (15, .hopping),
        "Aroma Hops (5 min)": (5, .hopping),
        "Whirlpool (20 min)": (20, .cooling),
        "Koelen (30 min)": (30, .cooling),
        "Dry Hop (3 dagen)": (4320, .fermentation), // 3 days in minutes
        "Cold Crash (2 dagen)": (2880, .conditioning), // 2 days in minutes
    ]
    
    private let brewingSteps = [
        "Graan malen", "Maischen", "Spoelen", "Koken", 
        "Hoppen toevoegen", "Koelen", "Gist toevoegen", 
        "Primaire fermentatie", "Secundaire fermentatie", "Bottelen"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with session info
                headerView
                
                if isBrewingActive {
                    activeBrewingView
                } else {
                    startNewSessionView
                }
            }
            .navigationTitle("Brouwtracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingPresets = true
                    } label: {
                        Image(systemName: "clock.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTimer) {
                AddTimerView(
                    timerManager: timerManager,
                    selectedCategory: $selectedTimerCategory,
                    customMinutes: $customTimerMinutes,
                    customName: $customTimerName
                )
            }
            .sheet(isPresented: $showingPresets) {
                PresetTimersView(timerManager: timerManager, presets: presetTimers)
            }
            .onAppear {
                requestNotificationPermission()
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: isBrewingActive ? "drop.fill" : "timer.circle.fill")
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text(isBrewingActive ? "Actieve Brouwsessie" : "Brouwtracker")
                        .font(.title2)
                        .fontWeight(.bold)
                    if isBrewingActive {
                        Text("Gestart: \(brewStartDate, style: .time)")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Klaar om te brouwen")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                
                if isBrewingActive {
                    VStack(alignment: .trailing) {
                        Text("Stap \(currentStep + 1)/\(brewingSteps.count)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        
                        Text("Actieve timers: \(timerManager.activeTimersCount)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if isBrewingActive {
                Text("Totale tijd: \(formatTotalBrewTime())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Active Brewing View
    private var activeBrewingView: some View {
        VStack(spacing: 20) {
            // Current Step Card
            currentStepCard
            
            // Active Timers Section
            if !timerManager.timers.isEmpty {
                activeTimersSection
            }
            
            // Timer Controls
            timerControlsSection
            
            // Step Navigation
            stepNavigationSection
            
            Spacer()
            
            // End Session Button
            Button {
                endSession()
            } label: {
                HStack {
                    Image(systemName: "stop.circle")
                    Text("Sessie Beëindigen")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
        .padding()
    }
    
    // MARK: - Current Step Card
    private var currentStepCard: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text(brewingSteps[currentStep])
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Stap \(currentStep + 1) van \(brewingSteps.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Step-specific timer quick actions
                stepTimerActions
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Step Timer Actions
    private var stepTimerActions: some View {
        VStack(spacing: 8) {
            // Quick timer buttons based on current step
            if let presetDuration = getPresetForCurrentStep() {
                Button {
                    addQuickTimer(duration: presetDuration.duration, category: presetDuration.category)
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: presetDuration.category.icon)
                        Text("\(presetDuration.duration)m")
                            .font(.caption2)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }
    
    // MARK: - Active Timers Section
    private var activeTimersSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Actieve Timers")
                    .font(.headline)
                Spacer()
                Text("\(timerManager.activeTimersCount) actief")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(timerManager.timers) { timer in
                    TimerCardView(timer: timer, timerManager: timerManager)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
    
    // MARK: - Timer Controls Section
    private var timerControlsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Timer Beheer")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button {
                    showingAddTimer = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Nieuwe Timer")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    showingPresets = true
                } label: {
                    HStack {
                        Image(systemName: "clock.badge.plus")
                        Text("Presets")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            
            // Global timer controls
            if timerManager.hasActiveTimers {
                HStack(spacing: 12) {
                    Button {
                        timerManager.pauseAllTimers()
                    } label: {
                        HStack {
                            Image(systemName: "pause.fill")
                            Text("Pauzeer Alles")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        timerManager.resumeAllTimers()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Hervat Alles")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
    
    // MARK: - Step Navigation Section
    private var stepNavigationSection: some View {
        HStack(spacing: 15) {
            Button {
                previousStep()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Vorige")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(currentStep == 0)
            
            Button {
                nextStep()
            } label: {
                HStack {
                    Text("Volgende")
                    Image(systemName: "chevron.right")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(currentStep == brewingSteps.count - 1)
        }
    }
    
    // MARK: - Start New Session View
    private var startNewSessionView: some View {
        VStack(spacing: 30) {
            Image(systemName: "timer.circle")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 15) {
                Text("Start een Nieuwe Brouwsessie")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Gebruik geavanceerde timers voor elke stap van je brouwproces")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 15) {
                DatePicker("Startdatum:", selection: $brewStartDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .padding(.horizontal)
                
                Button("Start Brouwen") {
                    startSession()
                }
                .buttonStyle(.borderedProminent)
                .font(.headline)
                .controlSize(.large)
            }
            
            // Quick timer section for non-brewing use
            VStack(spacing: 15) {
                Text("Of gebruik gewoon timers:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Button {
                        showingAddTimer = true
                    } label: {
                        VStack {
                            Image(systemName: "plus.circle")
                            Text("Nieuwe Timer")
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        showingPresets = true
                    } label: {
                        VStack {
                            Image(systemName: "clock.badge.plus")
                            Text("Preset Timers")
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Helper Functions
    private func startSession() {
        isBrewingActive = true
        currentStep = 0
        brewStartDate = Date()
        
        // Add a default mashing timer
        addQuickTimer(duration: 60, category: .mashing)
    }
    
    private func endSession() {
        isBrewingActive = false
        currentStep = 0
        timerManager.clearAllTimers()
    }
    
    private func nextStep() {
        if currentStep < brewingSteps.count - 1 {
            currentStep += 1
        }
    }
    
    private func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    private func formatTotalBrewTime() -> String {
        let elapsed = Date().timeIntervalSince(brewStartDate)
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        return String(format: "%d:%02d", hours, minutes)
    }
    
    private func getPresetForCurrentStep() -> (duration: Int, category: TimerCategory)? {
        switch currentStep {
        case 1: return (60, .mashing) // Maischen
        case 3: return (60, .boiling) // Koken
        case 4: return (60, .hopping) // Hoppen toevoegen
        case 5: return (30, .cooling) // Koelen
        default: return nil
        }
    }
    
    private func addQuickTimer(duration: Int, category: TimerCategory) {
        let timer = BrewTimer(
            id: UUID(),
            name: "\(category.rawValue) (\(duration) min)",
            totalDuration: TimeInterval(duration * 60),
            remainingTime: TimeInterval(duration * 60),
            category: category
        )
        timerManager.addTimer(timer)
        timerManager.startTimer(timer)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge, .criticalAlert]
        ) { granted, error in
            if granted {
                print("✅ Notificatie permissies toegekend")
                
                // Register notification categories
                let completeAction = UNNotificationAction(
                    identifier: "COMPLETE_ACTION",
                    title: "Volgende Stap",
                    options: .foreground
                )
                
                let completeCategory = UNNotificationCategory(
                    identifier: "TIMER_COMPLETE",
                    actions: [completeAction],
                    intentIdentifiers: [],
                    options: [.customDismissAction]
                )
                
                let alertCategory = UNNotificationCategory(
                    identifier: "TIMER_ALERT",
                    actions: [],
                    intentIdentifiers: [],
                    options: [.customDismissAction]
                )
                
                UNUserNotificationCenter.current().setNotificationCategories([
                    completeCategory,
                    alertCategory
                ])
            } else if let error = error {
                print("❌ Notificatie permissie error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Timer Card View
struct TimerCardView: View {
    let timer: BrewTimer
    let timerManager: BrewTimerManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(timer.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: timer.category.icon)
                            .foregroundColor(timer.category.color)
                        Text(timer.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(timer.displayTime)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(timer.urgencyLevel.color)
                        .monospacedDigit()
                    
                    if timer.isOvertime {
                        Text("OVERTIME")
                            .font(.caption2)
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                    } else if timer.isCompleted {
                        Text("KLAAR")
                            .font(.caption2)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    }
                }
            }
            
            // Progress bar
            ProgressView(value: timer.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: timer.isOvertime ? .red : timer.category.color))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
            
            // Timer controls
            HStack(spacing: 15) {
                Button {
                    if timer.isRunning {
                        timerManager.pauseTimer(timer)
                    } else {
                        timerManager.startTimer(timer)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                        Text(timer.isRunning ? "Pause" : "Start")
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button {
                    timerManager.resetTimer(timer)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "gobackward")
                        Text("Reset")
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
                
                Button {
                    timerManager.removeTimer(timer)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(timer.urgencyLevel.backgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(timer.urgencyLevel.color.opacity(0.5), lineWidth: timer.urgencyLevel == .normal ? 0 : 2)
        )
        .scaleEffect(timer.urgencyLevel == .critical ? 1.02 : 1.0)
        .animation(.easeInOut(duration: timer.urgencyLevel == .critical ? 0.5 : 0.3).repeatForever(autoreverses: true), value: timer.urgencyLevel == .critical)
    }
}

// MARK: - Add Timer View
struct AddTimerView: View {
    let timerManager: BrewTimerManager
    @Binding var selectedCategory: TimerCategory
    @Binding var customMinutes: Int
    @Binding var customName: String
    @State private var selectedSound: TimerSound = .default
    @State private var enableVibration: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Timer Details") {
                    TextField("Timer Naam", text: $customName)
                    
                    Stepper("Duur: \(customMinutes) minuten", value: $customMinutes, in: 1...720)
                    
                    Picker("Categorie", selection: $selectedCategory) {
                        ForEach(TimerCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("Meldingen") {
                    Picker("Geluid", selection: $selectedSound) {
                        ForEach(TimerSound.allCases, id: \.self) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                    
                    Toggle("Trillen", isOn: $enableVibration)
                }
                
                Section("Voorbeeld") {
                    HStack {
                        Text("Duur: \(customMinutes) minuten")
                        Spacer()
                        Button("Test Geluid") {
                            testNotificationSound()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
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
                        addTimer()
                        dismiss()
                    }
                    .disabled(customName.isEmpty)
                }
            }
        }
    }
    
    private func addTimer() {
        let timer = BrewTimer(
            id: UUID(),
            name: customName,
            totalDuration: TimeInterval(customMinutes * 60),
            remainingTime: TimeInterval(customMinutes * 60),
            category: selectedCategory,
            notificationSound: selectedSound,
            enableVibration: enableVibration
        )
        timerManager.addTimer(timer)
        
        // Reset fields
        customName = ""
        customMinutes = 60
        selectedCategory = .mashing
        selectedSound = .default
        enableVibration = true
    }
    
    private func testNotificationSound() {
        // Trigger haptic feedback if enabled
        if enableVibration {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        // Send test notification
        let content = UNMutableNotificationContent()
        content.title = "Test Timer"
        content.body = "Dit is hoe je timer melding eruit ziet"
        content.sound = selectedSound.systemSound
        
        let request = UNNotificationRequest(
            identifier: "test-timer",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Preset Timers View
struct PresetTimersView: View {
    let timerManager: BrewTimerManager
    let presets: [String: (duration: Int, category: TimerCategory)]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(presets.keys.sorted(), id: \.self) { presetName in
                    let preset = presets[presetName]!
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(presetName)
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: preset.category.icon)
                                    .foregroundColor(preset.category.color)
                                Text(preset.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Toevoegen") {
                            addPresetTimer(name: presetName, preset: preset)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
            .navigationTitle("Preset Timers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Klaar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addPresetTimer(name: String, preset: (duration: Int, category: TimerCategory)) {
        let timer = BrewTimer(
            id: UUID(),
            name: name,
            totalDuration: TimeInterval(preset.duration * 60),
            remainingTime: TimeInterval(preset.duration * 60),
            category: preset.category
        )
        timerManager.addTimer(timer)
    }
}

// MARK: - Timer Manager
class BrewTimerManager: ObservableObject {
    @Published var timers: [BrewTimer] = []
    private var updateTimer: Timer?
    private let userDefaults = UserDefaults.standard
    private let timersKey = "SavedBrewTimers"
    
    var activeTimersCount: Int {
        timers.filter { $0.isRunning }.count
    }
    
    var hasActiveTimers: Bool {
        activeTimersCount > 0
    }
    
    init() {
        loadTimers()
        startUpdateTimer()
        setupBackgroundNotifications()
    }
    
    func addTimer(_ timer: BrewTimer) {
        timers.append(timer)
        saveTimers()
    }
    
    func removeTimer(_ timer: BrewTimer) {
        timers.removeAll { $0.id == timer.id }
        saveTimers()
    }
    
    func startTimer(_ timer: BrewTimer) {
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            timers[index].isRunning = true
            timers[index].isPaused = false
            timers[index].startTime = Date()
            timers[index].backgroundStartTime = Date()
            scheduleNotification(for: timers[index])
            saveTimers()
        }
    }
    
    func pauseTimer(_ timer: BrewTimer) {
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            timers[index].isRunning = false
            timers[index].isPaused = true
            cancelNotification(for: timers[index])
            saveTimers()
        }
    }
    
    func resetTimer(_ timer: BrewTimer) {
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            timers[index].remainingTime = timers[index].totalDuration
            timers[index].isRunning = false
            timers[index].isPaused = false
            timers[index].isCompleted = false
            timers[index].startTime = nil
            timers[index].endTime = nil
            timers[index].backgroundStartTime = nil
            cancelNotification(for: timers[index])
            saveTimers()
        }
    }
    
    func pauseAllTimers() {
        for i in 0..<timers.count {
            if timers[i].isRunning {
                timers[i].isRunning = false
                timers[i].isPaused = true
            }
        }
    }
    
    func resumeAllTimers() {
        for i in 0..<timers.count {
            if timers[i].isPaused {
                timers[i].isRunning = true
                timers[i].isPaused = false
            }
        }
    }
    
    func clearAllTimers() {
        // Cancel all notifications
        for timer in timers {
            cancelNotification(for: timer)
        }
        timers.removeAll()
        saveTimers()
    }
    
    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTimers()
        }
    }
    
    private func updateTimers() {
        var hasChanges = false
        
        for i in 0..<timers.count {
            if timers[i].isRunning {
                timers[i].remainingTime -= 1
                hasChanges = true
                
                // Check if timer completed
                if timers[i].remainingTime <= 0 && !timers[i].isCompleted {
                    timers[i].isCompleted = true
                    timers[i].isRunning = false
                    timers[i].endTime = Date()
                    
                    // Send notification
                    sendCompletionNotification(for: timers[i])
                    
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedback.impactOccurred()
                }
            }
        }
        
        if hasChanges {
            objectWillChange.send()
        }
    }
    
    private func sendCompletionNotification(for timer: BrewTimer) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ \(timer.name) is klaar!"
        content.body = "Je \(timer.category.rawValue.lowercased()) timer is afgelopen.\nTijd voor de volgende stap! 🍺"
        content.sound = timer.notificationSound.systemSound
        content.badge = 1
        content.categoryIdentifier = "TIMER_COMPLETE"
        
        // Add critical alert for important brewing steps
        if timer.category == .mashing || timer.category == .boiling {
            content.interruptionLevel = .critical
        }
        
        let request = UNNotificationRequest(
            identifier: timer.id.uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
        
        // Trigger haptic feedback if enabled
        if timer.enableVibration {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            // Double tap for important steps
            if timer.category == .mashing || timer.category == .boiling {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    impactFeedback.impactOccurred()
                }
            }
        }
        
        // Play additional sound for important steps
        if timer.category == .mashing || timer.category == .boiling {
            AudioServicesPlaySystemSound(1005) // Second alert sound
        }
    }
    
    private func scheduleNotification(for timer: BrewTimer) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ \(timer.name)"
        content.body = "Je \(timer.category.rawValue.lowercased()) timer is bijna klaar.\nMaak je klaar voor de volgende stap! 🍺"
        content.sound = timer.notificationSound.systemSound
        content.badge = 1
        content.categoryIdentifier = "TIMER_ALERT"
        
        // Add warning notification 1 minute before completion
        if timer.remainingTime > 60 {
            let warningContent = content.copy() as! UNMutableNotificationContent
            warningContent.title = "⚠️ \(timer.name) - Nog 1 minuut!"
            
            let warningTrigger = UNTimeIntervalNotificationTrigger(
                timeInterval: timer.remainingTime - 60,
                repeats: false
            )
            
            let warningRequest = UNNotificationRequest(
                identifier: "\(timer.id.uuidString)-warning",
                content: warningContent,
                trigger: warningTrigger
            )
            
            UNUserNotificationCenter.current().add(warningRequest)
        }
        
        // Final notification
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timer.remainingTime,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: timer.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification(for timer: BrewTimer) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [timer.id.uuidString]
        )
    }
    
    private func saveTimers() {
        if let encoded = try? JSONEncoder().encode(timers) {
            userDefaults.set(encoded, forKey: timersKey)
        }
    }
    
    private func loadTimers() {
        if let data = userDefaults.data(forKey: timersKey),
           let decoded = try? JSONDecoder().decode([BrewTimer].self, from: data) {
            timers = decoded
            
            // Restore background timers
            restoreBackgroundTimers()
        }
    }
    
    private func restoreBackgroundTimers() {
        let now = Date()
        
        for i in 0..<timers.count {
            if timers[i].isRunning,
               let backgroundStart = timers[i].backgroundStartTime {
                let elapsed = now.timeIntervalSince(backgroundStart)
                timers[i].remainingTime -= elapsed
                
                // Check if timer completed while in background
                if timers[i].remainingTime <= 0 {
                    timers[i].isCompleted = true
                    timers[i].isRunning = false
                    timers[i].endTime = now
                }
            }
        }
        
        saveTimers()
    }
    
    private func setupBackgroundNotifications() {
        // Remove any existing observers first
        NotificationCenter.default.removeObserver(self)
        
        // Add new observers
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppBackground()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppForeground()
        }
        
        // Add memory warning observer
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }
    
    private func handleMemoryWarning() {
        // Clean up any completed timers
        timers.removeAll { $0.isCompleted }
        saveTimers()
    }
    
    private func handleAppBackground() {
        let now = Date()
        
        // Update all running timers
        for i in 0..<timers.count {
            if timers[i].isRunning {
                timers[i].backgroundStartTime = now
                
                // Schedule local notification for timer completion
                scheduleTimerNotification(for: timers[i])
            }
        }
        
        saveTimers()
        
        // Invalidate update timer when going to background
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func handleAppForeground() {
        // Restore timers
        restoreBackgroundTimers()
        
        // Cancel any pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Restart update timer if needed
        setupUpdateTimer()
    }
    
    private func setupUpdateTimer() {
        // Clean up existing timer first
        updateTimer?.invalidate()
        
        // Only create new timer if there are running timers
        if timers.contains(where: { $0.isRunning }) {
            updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.updateRunningTimers()
            }
        }
    }
    
    private func scheduleTimerNotification(for timer: BrewTimer) {
        guard timer.isRunning,
              !timer.isCompleted,
              timer.remainingTime > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Timer Voltooid"
        content.body = "\(timer.name) is klaar!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timer.remainingTime,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: timer.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func updateRunningTimers() {
        let now = Date()
        var needsSave = false
        
        for i in 0..<timers.count {
            if timers[i].isRunning {
                if let startTime = timers[i].startTime {
                    let elapsed = now.timeIntervalSince(startTime)
                    timers[i].remainingTime = timers[i].totalDuration - elapsed
                    
                    // Check if timer completed
                    if timers[i].remainingTime <= 0 {
                        timers[i].isCompleted = true
                        timers[i].isRunning = false
                        timers[i].endTime = now
                        needsSave = true
                        
                        // Play sound and vibrate
                        playTimerCompletionSound(timer: timers[i])
                    }
                }
            }
        }
        
        if needsSave {
            saveTimers()
        }
    }
    
    private func playTimerCompletionSound(timer: BrewTimer) {
        // Play notification sound (always play default sound for now)
        AudioServicesPlaySystemSound(SystemSoundID(1007))
        
        // Vibrate if enabled
        if timer.enableVibration {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    deinit {
        updateTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

#Preview {
    BrewTrackerView()
}
