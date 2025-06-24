//
//  BrewTimerComponents.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 09/06/2025.
//

import SwiftUI
import UserNotifications

// MARK: - Timer Card View
struct TimerCardView: View {
    let timer: BrewTimer
    let timerManager: BrewTimerManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            VStack {
                Image(systemName: timer.category.icon)
                    .font(.title2)
                    .foregroundColor(timer.category.color)
                    .frame(width: 40, height: 40)
                    .background(timer.category.color.opacity(0.1))
                    .clipShape(Circle())
                
                Text(timer.category.rawValue)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 60)
            
            // Timer Info
            VStack(alignment: .leading, spacing: 4) {
                Text(timer.name)
                    .font(.headline)
                    .foregroundColor(timer.urgencyLevel.color)
                
                HStack {
                    Text(timer.displayTime)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(timer.urgencyLevel.color)
                    
                    if timer.isOvertime {
                        Text("(Overtime)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                }
                
                // Progress Bar
                if !timer.isCompleted {
                    ProgressView(value: timer.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: timer.urgencyLevel.color))
                        .scaleEffect(y: 0.5)
                }
            }
            
            Spacer()
            
            // Timer Controls
            VStack(spacing: 8) {
                if timer.isCompleted {
                    Button {
                        timerManager.resetTimer(timer)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.borderless)
                } else if timer.isRunning {
                    Button {
                        timerManager.pauseTimer(timer)
                    } label: {
                        Image(systemName: "pause.fill")
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(.borderless)
                } else {
                    Button {
                        timerManager.startTimer(timer)
                    } label: {
                        Image(systemName: "play.fill")
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.borderless)
                }
                
                Button {
                    timerManager.removeTimer(timer)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .background(timer.urgencyLevel.backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(timer.urgencyLevel.color.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Timer \(timer.name), \(timer.displayTime)")
        .accessibilityHint(timer.isRunning ? "Timer is actief" : "Timer is gepauzeerd")
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
                Section("Timer Instellingen") {
                    TextField("Timer Naam", text: $customName)
                        .accessibilityLabel("Timer naam invoerveld")
                    
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
                    .accessibilityLabel("Timer categorie selectie")
                    
                    HStack {
                        Text("Tijd")
                        Spacer()
                        TextField("Minuten", value: $customMinutes, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        Text("min")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Timer duur: \(customMinutes) minuten")
                }
                
                Section("Notificatie Instellingen") {
                    Picker("Geluid", selection: $selectedSound) {
                        ForEach(TimerSound.allCases, id: \.self) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                    .accessibilityLabel("Notificatie geluid selectie")
                    
                    Toggle("Trillen", isOn: $enableVibration)
                        .accessibilityLabel("Trilling inschakelen")
                    
                    Button("Test Notificatie") {
                        testNotificationSound()
                    }
                    .foregroundColor(.blue)
                    .accessibilityLabel("Test notificatie")
                    .accessibilityHint("Speelt een test notificatie af")
                }
            }
            .navigationTitle("Nieuwe Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuleren") {
                        dismiss()
                    }
                    .accessibilityLabel("Annuleren")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Toevoegen") {
                        addTimer()
                        dismiss()
                    }
                    .disabled(customName.isEmpty)
                    .accessibilityLabel("Timer toevoegen")
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
                        .accessibilityLabel("Voeg \(presetName) timer toe")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(presetName), \(preset.category.rawValue)")
                }
            }
            .navigationTitle("Preset Timers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Klaar") {
                        dismiss()
                    }
                    .accessibilityLabel("Klaar")
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