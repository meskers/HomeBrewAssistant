//
//  BrewTimerManagerTests.swift
//  HomeBrewAssistantTests
//
//  Created by Automated Testing on 24/06/2025.
//

import XCTest
import Combine
@testable import HomeBrewAssistant

@MainActor
final class BrewTimerManagerTests: XCTestCase {
    
    var timerManager: BrewTimerManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        timerManager = BrewTimerManager()
        cancellables = Set<AnyCancellable>()
        
        // Clear any existing timers and reset UserDefaults for clean testing
        UserDefaults.standard.removeObject(forKey: "SavedBrewTimers")
        timerManager.clearAllTimers()
    }
    
    override func tearDown() {
        cancellables.removeAll()
        timerManager = nil
        UserDefaults.standard.removeObject(forKey: "SavedBrewTimers")
        super.tearDown()
    }
    
    // MARK: - Timer Creation Tests
    
    func testAddTimer() {
        // Given
        let timer = createTestTimer(name: "Test Timer", duration: 60)
        
        // When
        timerManager.addTimer(timer)
        
        // Then
        XCTAssertEqual(timerManager.timers.count, 1)
        XCTAssertEqual(timerManager.timers.first?.name, "Test Timer")
        XCTAssertEqual(timerManager.timers.first?.totalDuration, 60)
    }
    
    func testAddMultipleTimers() {
        // Given
        let timer1 = createTestTimer(name: "Timer 1", duration: 60)
        let timer2 = createTestTimer(name: "Timer 2", duration: 120)
        
        // When
        timerManager.addTimer(timer1)
        timerManager.addTimer(timer2)
        
        // Then
        XCTAssertEqual(timerManager.timers.count, 2)
        XCTAssertEqual(timerManager.timers.map { $0.name }.sorted(), ["Timer 1", "Timer 2"])
    }
    
    // MARK: - Timer Control Tests
    
    func testStartTimer() {
        // Given
        let timer = createTestTimer(name: "Start Test", duration: 60)
        timerManager.addTimer(timer)
        
        // When
        timerManager.startTimer(timer)
        
        // Then
        XCTAssertTrue(timerManager.timers.first?.isRunning ?? false)
        XCTAssertFalse(timerManager.timers.first?.isPaused ?? true)
        XCTAssertNotNil(timerManager.timers.first?.startTime)
        XCTAssertEqual(timerManager.activeTimersCount, 1)
    }
    
    func testPauseTimer() {
        // Given
        let timer = createTestTimer(name: "Pause Test", duration: 60)
        timerManager.addTimer(timer)
        timerManager.startTimer(timer)
        
        // When
        timerManager.pauseTimer(timer)
        
        // Then
        XCTAssertFalse(timerManager.timers.first?.isRunning ?? true)
        XCTAssertTrue(timerManager.timers.first?.isPaused ?? false)
        XCTAssertEqual(timerManager.activeTimersCount, 0)
    }
    
    func testResetTimer() {
        // Given
        let timer = createTestTimer(name: "Reset Test", duration: 60)
        timerManager.addTimer(timer)
        timerManager.startTimer(timer)
        
        // When
        timerManager.resetTimer(timer)
        
        // Then
        let resetTimer = timerManager.timers.first
        XCTAssertFalse(resetTimer?.isRunning ?? true)
        XCTAssertFalse(resetTimer?.isPaused ?? true)
        XCTAssertFalse(resetTimer?.isCompleted ?? true)
        XCTAssertEqual(resetTimer?.remainingTime, resetTimer?.totalDuration)
        XCTAssertNil(resetTimer?.startTime)
        XCTAssertNil(resetTimer?.endTime)
    }
    
    // MARK: - Timer State Tests
    
    func testActiveTimersCount() {
        // Given
        let timer1 = createTestTimer(name: "Active 1", duration: 60)
        let timer2 = createTestTimer(name: "Active 2", duration: 120)
        let timer3 = createTestTimer(name: "Inactive", duration: 180)
        
        timerManager.addTimer(timer1)
        timerManager.addTimer(timer2)
        timerManager.addTimer(timer3)
        
        // When
        timerManager.startTimer(timer1)
        timerManager.startTimer(timer2)
        // timer3 remains inactive
        
        // Then
        XCTAssertEqual(timerManager.activeTimersCount, 2)
        XCTAssertTrue(timerManager.hasActiveTimers)
    }
    
    func testHasActiveTimers() {
        // Given - no timers
        XCTAssertFalse(timerManager.hasActiveTimers)
        
        // When - add but don't start timer
        let timer = createTestTimer(name: "Inactive", duration: 60)
        timerManager.addTimer(timer)
        
        // Then
        XCTAssertFalse(timerManager.hasActiveTimers)
        
        // When - start timer
        timerManager.startTimer(timer)
        
        // Then
        XCTAssertTrue(timerManager.hasActiveTimers)
    }
    
    // MARK: - Bulk Operations Tests
    
    func testPauseAllTimers() {
        // Given
        let timer1 = createTestTimer(name: "Timer 1", duration: 60)
        let timer2 = createTestTimer(name: "Timer 2", duration: 120)
        
        timerManager.addTimer(timer1)
        timerManager.addTimer(timer2)
        timerManager.startTimer(timer1)
        timerManager.startTimer(timer2)
        
        XCTAssertEqual(timerManager.activeTimersCount, 2)
        
        // When
        timerManager.pauseAllTimers()
        
        // Then
        XCTAssertEqual(timerManager.activeTimersCount, 0)
        XCTAssertTrue(timerManager.timers.allSatisfy { $0.isPaused && !$0.isRunning })
    }
    
    func testResumeAllTimers() {
        // Given
        let timer1 = createTestTimer(name: "Timer 1", duration: 60)
        let timer2 = createTestTimer(name: "Timer 2", duration: 120)
        
        timerManager.addTimer(timer1)
        timerManager.addTimer(timer2)
        timerManager.startTimer(timer1)
        timerManager.startTimer(timer2)
        timerManager.pauseAllTimers()
        
        XCTAssertEqual(timerManager.activeTimersCount, 0)
        
        // When
        timerManager.resumeAllTimers()
        
        // Then
        XCTAssertEqual(timerManager.activeTimersCount, 2)
        XCTAssertTrue(timerManager.timers.allSatisfy { $0.isRunning && !$0.isPaused })
    }
    
    func testClearAllTimers() {
        // Given
        let timer1 = createTestTimer(name: "Timer 1", duration: 60)
        let timer2 = createTestTimer(name: "Timer 2", duration: 120)
        
        timerManager.addTimer(timer1)
        timerManager.addTimer(timer2)
        timerManager.startTimer(timer1)
        
        XCTAssertEqual(timerManager.timers.count, 2)
        
        // When
        timerManager.clearAllTimers()
        
        // Then
        XCTAssertEqual(timerManager.timers.count, 0)
        XCTAssertEqual(timerManager.activeTimersCount, 0)
        XCTAssertFalse(timerManager.hasActiveTimers)
    }
    
    // MARK: - Timer Removal Tests
    
    func testRemoveTimer() {
        // Given
        let timer1 = createTestTimer(name: "Keep", duration: 60)
        let timer2 = createTestTimer(name: "Remove", duration: 120)
        
        timerManager.addTimer(timer1)
        timerManager.addTimer(timer2)
        
        XCTAssertEqual(timerManager.timers.count, 2)
        
        // When
        timerManager.removeTimer(timer2)
        
        // Then
        XCTAssertEqual(timerManager.timers.count, 1)
        XCTAssertEqual(timerManager.timers.first?.name, "Keep")
    }
    
    func testRemoveRunningTimer() {
        // Given
        let timer = createTestTimer(name: "Running Timer", duration: 60)
        timerManager.addTimer(timer)
        timerManager.startTimer(timer)
        
        XCTAssertEqual(timerManager.activeTimersCount, 1)
        
        // When
        timerManager.removeTimer(timer)
        
        // Then
        XCTAssertEqual(timerManager.timers.count, 0)
        XCTAssertEqual(timerManager.activeTimersCount, 0)
    }
    
    // MARK: - Persistence Tests
    
    func testTimerPersistence() {
        // Given
        let timer = createTestTimer(name: "Persistent Timer", duration: 300)
        timerManager.addTimer(timer)
        
        // When - create new manager instance (simulates app restart)
        let newTimerManager = BrewTimerManager()
        
        // Then
        XCTAssertEqual(newTimerManager.timers.count, 1)
        XCTAssertEqual(newTimerManager.timers.first?.name, "Persistent Timer")
        XCTAssertEqual(newTimerManager.timers.first?.totalDuration, 300)
    }
    
    // MARK: - Observable Tests
    
    func testTimerManagerPublishing() {
        // Given
        let expectation = XCTestExpectation(description: "Timer manager publishes changes")
        var changeCount = 0
        
        timerManager.$timers
            .dropFirst() // Skip initial empty state
            .sink { _ in
                changeCount += 1
                if changeCount == 2 { // After add and start
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        let timer = createTestTimer(name: "Observable Test", duration: 60)
        timerManager.addTimer(timer)
        timerManager.startTimer(timer)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(changeCount, 2)
    }
    
    // MARK: - Edge Cases Tests
    
    func testAddTimerWithSameId() {
        // Given
        let timer1 = createTestTimer(name: "Original", duration: 60)
        let timer2 = BrewTimer(
            id: timer1.id, // Same ID
            name: "Duplicate",
            totalDuration: 120,
            remainingTime: 120,
            category: .boiling
        )
        
        timerManager.addTimer(timer1)
        
        // When
        timerManager.addTimer(timer2)
        
        // Then - should have both timers (manager doesn't prevent duplicates by ID)
        XCTAssertEqual(timerManager.timers.count, 2)
    }
    
    func testOperationsOnNonExistentTimer() {
        // Given
        let timer = createTestTimer(name: "Non-existent", duration: 60)
        
        // When/Then - operations on timer not in manager should not crash
        timerManager.startTimer(timer)
        timerManager.pauseTimer(timer)
        timerManager.resetTimer(timer)
        timerManager.removeTimer(timer)
        
        // Should still be empty
        XCTAssertEqual(timerManager.timers.count, 0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestTimer(name: String, duration: TimeInterval, category: TimerCategory = .mashing) -> BrewTimer {
        return BrewTimer(
            id: UUID(),
            name: name,
            totalDuration: duration,
            remainingTime: duration,
            category: category
        )
    }
} 