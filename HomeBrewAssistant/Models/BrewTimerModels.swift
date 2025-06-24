//
//  BrewTimerModels.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 09/06/2025.
//

import SwiftUI
import UserNotifications

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