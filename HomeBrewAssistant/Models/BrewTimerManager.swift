//
//  BrewTimerManager.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 09/06/2025.
//

import Foundation
import SwiftUI
import UserNotifications
import AudioToolbox

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
    }
    
    private func scheduleNotification(for timer: BrewTimer) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Timer Klaar!"
        content.body = "\(timer.name) is klaar! Tijd: \(timer.displayTime)"
        content.sound = timer.notificationSound.systemSound
        content.badge = 1
        
        // Add critical alert for important brewing steps
        if timer.category == .mashing || timer.category == .boiling {
            content.interruptionLevel = .critical
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