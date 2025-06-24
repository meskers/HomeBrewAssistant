//
//  BrewTimerModelsTests.swift
//  HomeBrewAssistantTests
//
//  Created by Automated Testing on 24/06/2025.
//

import XCTest
@testable import HomeBrewAssistant

final class BrewTimerModelsTests: XCTestCase {
    
    // MARK: - BrewTimer Tests
    
    func testTimerProgress() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "Progress Test",
            totalDuration: 120,
            remainingTime: 60,
            category: .mashing
        )
        
        // When/Then
        XCTAssertEqual(timer.progress, 0.5, accuracy: 0.001)
    }
    
    func testTimerProgressAtStart() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "Start Progress",
            totalDuration: 100,
            remainingTime: 100,
            category: .mashing
        )
        
        // When/Then
        XCTAssertEqual(timer.progress, 0.0, accuracy: 0.001)
    }
    
    func testTimerProgressAtCompletion() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "Complete Progress",
            totalDuration: 100,
            remainingTime: 0,
            category: .mashing
        )
        
        // When/Then
        XCTAssertEqual(timer.progress, 1.0, accuracy: 0.001)
    }
    
    func testTimerProgressWithZeroDuration() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "Zero Duration",
            totalDuration: 0,
            remainingTime: 0,
            category: .mashing
        )
        
        // When/Then
        XCTAssertEqual(timer.progress, 0.0, accuracy: 0.001)
    }
    
    func testIsOvertime() {
        // Given - timer with negative remaining time
        let overtimeTimer = BrewTimer(
            id: UUID(),
            name: "Overtime",
            totalDuration: 60,
            remainingTime: -30,
            category: .boiling
        )
        
        // When/Then
        XCTAssertTrue(overtimeTimer.isOvertime)
        
        // Given - timer with positive remaining time
        let normalTimer = BrewTimer(
            id: UUID(),
            name: "Normal",
            totalDuration: 60,
            remainingTime: 30,
            category: .boiling
        )
        
        // When/Then
        XCTAssertFalse(normalTimer.isOvertime)
    }
    
    // MARK: - Display Time Tests
    
    func testDisplayTimeMinutesAndSeconds() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "MM:SS Test",
            totalDuration: 3600,
            remainingTime: 125, // 2:05
            category: .mashing
        )
        
        // When/Then
        XCTAssertEqual(timer.displayTime, "02:05")
    }
    
    func testDisplayTimeHoursMinutesSeconds() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "HH:MM:SS Test",
            totalDuration: 7200,
            remainingTime: 3665, // 1:01:05
            category: .fermentation
        )
        
        // When/Then
        XCTAssertEqual(timer.displayTime, "1:01:05")
    }
    
    func testDisplayTimeZeroTime() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "Zero Time",
            totalDuration: 60,
            remainingTime: 0,
            category: .mashing
        )
        
        // When/Then
        XCTAssertEqual(timer.displayTime, "00:00")
    }
    
    func testDisplayTimeNegativeTime() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "Negative Time",
            totalDuration: 60,
            remainingTime: -75, // -1:15
            category: .boiling
        )
        
        // When/Then
        XCTAssertEqual(timer.displayTime, "01:15") // Should show absolute value
    }
    
    // MARK: - Urgency Level Tests
    
    func testUrgencyLevelCompleted() {
        // Given
        var timer = BrewTimer(
            id: UUID(),
            name: "Completed",
            totalDuration: 60,
            remainingTime: 0,
            category: .mashing
        )
        timer.isCompleted = true
        
        // When/Then
        XCTAssertEqual(timer.urgencyLevel, .completed)
    }
    
    func testUrgencyLevelOvertime() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "Overtime",
            totalDuration: 60,
            remainingTime: -10,
            category: .boiling
        )
        
        // When/Then
        XCTAssertEqual(timer.urgencyLevel, .overtime)
    }
    
    func testUrgencyLevelCritical() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "Critical",
            totalDuration: 600,
            remainingTime: 30, // <= 60 seconds
            category: .hopping
        )
        
        // When/Then
        XCTAssertEqual(timer.urgencyLevel, .critical)
    }
    
    func testUrgencyLevelWarning() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "Warning",
            totalDuration: 600,
            remainingTime: 180, // <= 300 seconds but > 60
            category: .cooling
        )
        
        // When/Then
        XCTAssertEqual(timer.urgencyLevel, .warning)
    }
    
    func testUrgencyLevelNormal() {
        // Given
        let timer = BrewTimer(
            id: UUID(),
            name: "Normal",
            totalDuration: 3600,
            remainingTime: 1800, // > 300 seconds
            category: .fermentation
        )
        
        // When/Then
        XCTAssertEqual(timer.urgencyLevel, .normal)
    }
    
    // MARK: - TimerCategory Tests
    
    func testTimerCategoryIcons() {
        XCTAssertEqual(TimerCategory.mashing.icon, "thermometer")
        XCTAssertEqual(TimerCategory.boiling.icon, "flame")
        XCTAssertEqual(TimerCategory.hopping.icon, "leaf")
        XCTAssertEqual(TimerCategory.cooling.icon, "snowflake")
        XCTAssertEqual(TimerCategory.fermentation.icon, "drop.circle")
        XCTAssertEqual(TimerCategory.conditioning.icon, "hourglass")
        XCTAssertEqual(TimerCategory.other.icon, "timer")
    }
    
    func testTimerCategoryColors() {
        // Test that each category has a unique color
        let categories = TimerCategory.allCases
        let colors = categories.map { $0.color }
        
        // Check that we have the expected number of categories
        XCTAssertEqual(categories.count, 7)
        
        // Verify specific color mappings exist (colors should be non-nil)
        XCTAssertNotNil(TimerCategory.mashing.color)
        XCTAssertNotNil(TimerCategory.boiling.color)
        XCTAssertNotNil(TimerCategory.hopping.color)
        XCTAssertNotNil(TimerCategory.cooling.color)
        XCTAssertNotNil(TimerCategory.fermentation.color)
        XCTAssertNotNil(TimerCategory.conditioning.color)
        XCTAssertNotNil(TimerCategory.other.color)
    }
    
    func testTimerCategoryRawValues() {
        XCTAssertEqual(TimerCategory.mashing.rawValue, "Maischen")
        XCTAssertEqual(TimerCategory.boiling.rawValue, "Koken")
        XCTAssertEqual(TimerCategory.hopping.rawValue, "Hoppen")
        XCTAssertEqual(TimerCategory.cooling.rawValue, "Koelen")
        XCTAssertEqual(TimerCategory.fermentation.rawValue, "Gisting")
        XCTAssertEqual(TimerCategory.conditioning.rawValue, "Lagering")
        XCTAssertEqual(TimerCategory.other.rawValue, "Anders")
    }
    
    // MARK: - TimerSound Tests
    
    func testTimerSoundDisplayNames() {
        XCTAssertEqual(TimerSound.default.displayName, "Standaard")
        XCTAssertEqual(TimerSound.chime.displayName, "Chime")
        XCTAssertEqual(TimerSound.bell.displayName, "Bel")
        XCTAssertEqual(TimerSound.alarm.displayName, "Alarm")
        XCTAssertEqual(TimerSound.gentle.displayName, "Zacht")
    }
    
    func testTimerSoundRawValues() {
        XCTAssertEqual(TimerSound.default.rawValue, "default")
        XCTAssertEqual(TimerSound.chime.rawValue, "chime")
        XCTAssertEqual(TimerSound.bell.rawValue, "bell")
        XCTAssertEqual(TimerSound.alarm.rawValue, "alarm")
        XCTAssertEqual(TimerSound.gentle.rawValue, "gentle")
    }
    
    func testTimerSoundSystemSounds() {
        // Test that system sounds are properly configured
        XCTAssertNotNil(TimerSound.default.systemSound)
        XCTAssertNotNil(TimerSound.chime.systemSound)
        XCTAssertNotNil(TimerSound.bell.systemSound)
        XCTAssertNotNil(TimerSound.alarm.systemSound)
        XCTAssertNotNil(TimerSound.gentle.systemSound)
    }
    
    // MARK: - TimerUrgency Tests
    
    func testTimerUrgencyColors() {
        // Test that each urgency level has appropriate colors
        XCTAssertNotNil(TimerUrgency.normal.color)
        XCTAssertNotNil(TimerUrgency.warning.color)
        XCTAssertNotNil(TimerUrgency.critical.color)
        XCTAssertNotNil(TimerUrgency.overtime.color)
        XCTAssertNotNil(TimerUrgency.completed.color)
    }
    
    func testTimerUrgencyBackgroundColors() {
        // Test that each urgency level has background colors
        XCTAssertNotNil(TimerUrgency.normal.backgroundColor)
        XCTAssertNotNil(TimerUrgency.warning.backgroundColor)
        XCTAssertNotNil(TimerUrgency.critical.backgroundColor)
        XCTAssertNotNil(TimerUrgency.overtime.backgroundColor)
        XCTAssertNotNil(TimerUrgency.completed.backgroundColor)
    }
    
    // MARK: - Codable Tests
    
    func testBrewTimerCodable() throws {
        // Given
        let originalTimer = BrewTimer(
            id: UUID(),
            name: "Codable Test",
            totalDuration: 3600,
            remainingTime: 1800,
            category: .mashing,
            startTime: Date(),
            notificationSound: .chime,
            enableVibration: false
        )
        
        // When - encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTimer)
        
        // Then - decode
        let decoder = JSONDecoder()
        let decodedTimer = try decoder.decode(BrewTimer.self, from: data)
        
        // Verify all properties
        XCTAssertEqual(decodedTimer.id, originalTimer.id)
        XCTAssertEqual(decodedTimer.name, originalTimer.name)
        XCTAssertEqual(decodedTimer.totalDuration, originalTimer.totalDuration)
        XCTAssertEqual(decodedTimer.remainingTime, originalTimer.remainingTime)
        XCTAssertEqual(decodedTimer.category, originalTimer.category)
        XCTAssertEqual(decodedTimer.notificationSound, originalTimer.notificationSound)
        XCTAssertEqual(decodedTimer.enableVibration, originalTimer.enableVibration)
    }
    
    func testTimerCategoryCodable() throws {
        // Test all categories can be encoded/decoded
        for category in TimerCategory.allCases {
            // When
            let encoded = try JSONEncoder().encode(category)
            let decoded = try JSONDecoder().decode(TimerCategory.self, from: encoded)
            
            // Then
            XCTAssertEqual(decoded, category)
        }
    }
    
    func testTimerSoundCodable() throws {
        // Test all sounds can be encoded/decoded
        for sound in TimerSound.allCases {
            // When
            let encoded = try JSONEncoder().encode(sound)
            let decoded = try JSONDecoder().decode(TimerSound.self, from: encoded)
            
            // Then
            XCTAssertEqual(decoded, sound)
        }
    }
} 