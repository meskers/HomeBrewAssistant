//
//  BrewTrackerView.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 09/06/2025.
//

import SwiftUI
import UserNotifications

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
                    .accessibilityLabel("Preset timers")
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Brouwtracker hoofdscherm")
    }
    
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isBrewingActive ? "Actieve brouwsessie" : "Brouwtracker klaar")
    }
    
    private var activeBrewingView: some View {
        VStack(spacing: 20) {
            currentStepCard
            
            if !timerManager.timers.isEmpty {
                activeTimersSection
            }
            
            timerControlsSection
            
            Spacer()
            
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
            .accessibilityLabel("Brouwsessie beëindigen")
        }
        .padding()
    }
    
    private var startNewSessionView: some View {
        VStack(spacing: 30) {
            Image(systemName: "timer.circle")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .accessibilityHidden(true)
            
            VStack(spacing: 15) {
                Text("Start een nieuwe brouwsessie")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Volg je brouwproces met timers en stap-voor-stap begeleiding")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 15) {
                Button {
                    startNewSession()
                } label: {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Start Brouwsessie")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Start nieuwe brouwsessie")
                
                Button {
                    showingAddTimer = true
                } label: {
                    HStack {
                        Image(systemName: "timer.circle")
                        Text("Alleen Timer")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Voeg alleen timer toe")
            }
            
            Spacer()
        }
        .padding()
    }
    
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
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Huidige stap: \(brewingSteps[currentStep])")
    }
    
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Actieve timers sectie")
    }
    
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
                .accessibilityLabel("Nieuwe timer toevoegen")
                
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
                .accessibilityLabel("Preset timers bekijken")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
    
    private func startNewSession() {
        isBrewingActive = true
        brewStartDate = Date()
        currentStep = 0
    }
    
    private func endSession() {
        isBrewingActive = false
        currentStep = 0
        timerManager.clearAllTimers()
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
    
    private func formatTotalBrewTime() -> String {
        let elapsed = Date().timeIntervalSince(brewStartDate)
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        return String(format: "%d:%02d", hours, minutes)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}

#Preview {
    BrewTrackerView()
}
