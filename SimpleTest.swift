#!/usr/bin/env swift

// 🧪 Simple Test Runner for HomeBrewAssistant
// This is a standalone test to verify our models work correctly

import Foundation

// Simple test framework
class SimpleTestRunner {
    static var passed = 0
    static var failed = 0
    
    static func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "") {
        if actual == expected {
            print("✅ PASS: \(message)")
            passed += 1
        } else {
            print("❌ FAIL: \(message)")
            print("   Expected: \(expected)")
            print("   Actual: \(actual)")
            failed += 1
        }
    }
    
    static func assertTrue(_ condition: Bool, _ message: String = "") {
        if condition {
            print("✅ PASS: \(message)")
            passed += 1
        } else {
            print("❌ FAIL: \(message)")
            failed += 1
        }
    }
    
    static func printSummary() {
        print("\n🧪 Test Summary:")
        print("✅ Passed: \(passed)")
        print("❌ Failed: \(failed)")
        print("📊 Total: \(passed + failed)")
        
        if failed == 0 {
            print("🎉 All tests passed!")
        } else {
            print("⚠️  Some tests failed")
        }
    }
}

// Basic timer model for testing
struct TestTimer {
    let id = UUID()
    var name: String
    var totalDuration: TimeInterval
    var remainingTime: TimeInterval
    var isRunning: Bool = false
    var isPaused: Bool = false
    
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return (totalDuration - remainingTime) / totalDuration
    }
    
    var displayTime: String {
        let time = abs(remainingTime)
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// Test the timer model
func testTimerModel() {
    print("🧪 Testing Timer Model...")
    
    let timer = TestTimer(name: "Test Timer", totalDuration: 300, remainingTime: 150)
    
    SimpleTestRunner.assertEqual(timer.name, "Test Timer", "Timer name")
    SimpleTestRunner.assertEqual(timer.totalDuration, 300.0, "Timer total duration")
    SimpleTestRunner.assertEqual(timer.remainingTime, 150.0, "Timer remaining time")
    SimpleTestRunner.assertEqual(timer.progress, 0.5, "Timer progress calculation")
    SimpleTestRunner.assertEqual(timer.displayTime, "02:30", "Timer display formatting")
    SimpleTestRunner.assertTrue(!timer.isRunning, "Timer not running initially")
    SimpleTestRunner.assertTrue(!timer.isPaused, "Timer not paused initially")
}

func testTimerProgressCalculations() {
    print("\n🧪 Testing Timer Progress Calculations...")
    
    // Test at start
    let startTimer = TestTimer(name: "Start", totalDuration: 100, remainingTime: 100)
    SimpleTestRunner.assertEqual(startTimer.progress, 0.0, "Progress at start")
    
    // Test at halfway
    let halfTimer = TestTimer(name: "Half", totalDuration: 100, remainingTime: 50)
    SimpleTestRunner.assertEqual(halfTimer.progress, 0.5, "Progress at halfway")
    
    // Test at completion
    let completeTimer = TestTimer(name: "Complete", totalDuration: 100, remainingTime: 0)
    SimpleTestRunner.assertEqual(completeTimer.progress, 1.0, "Progress at completion")
    
    // Test with zero duration
    let zeroTimer = TestTimer(name: "Zero", totalDuration: 0, remainingTime: 0)
    SimpleTestRunner.assertEqual(zeroTimer.progress, 0.0, "Progress with zero duration")
}

func testTimerDisplayFormatting() {
    print("\n🧪 Testing Timer Display Formatting...")
    
    // Test minutes and seconds
    let mmssTimer = TestTimer(name: "MMSS", totalDuration: 3600, remainingTime: 125)
    SimpleTestRunner.assertEqual(mmssTimer.displayTime, "02:05", "MM:SS format")
    
    // Test hours, minutes, seconds
    let hhmmssTimer = TestTimer(name: "HHMMSS", totalDuration: 7200, remainingTime: 3665)
    SimpleTestRunner.assertEqual(hhmmssTimer.displayTime, "1:01:05", "HH:MM:SS format")
    
    // Test zero time
    let zeroTimer = TestTimer(name: "Zero", totalDuration: 60, remainingTime: 0)
    SimpleTestRunner.assertEqual(zeroTimer.displayTime, "00:00", "Zero time format")
    
    // Test negative time (overtime)
    let overtimeTimer = TestTimer(name: "Overtime", totalDuration: 60, remainingTime: -75)
    SimpleTestRunner.assertEqual(overtimeTimer.displayTime, "01:15", "Overtime format")
}

func testRecipeModel() {
    print("\n🧪 Testing Recipe Model...")
    
    struct TestRecipe {
        let id = UUID()
        var name: String
        var style: String
        var targetOG: Double
        var targetFG: Double
        var abv: Double
        var ibu: Int
        var srm: Int
        var batchSize: Double
        var efficiency: Double
        
        var apparentAttenuation: Double {
            guard targetOG > 1.0 && targetFG > 0 else { return 0 }
            return ((targetOG - targetFG) / (targetOG - 1.0)) * 100
        }
    }
    
    let recipe = TestRecipe(
        name: "Test IPA",
        style: "American IPA",
        targetOG: 1.065,
        targetFG: 1.012,
        abv: 6.8,
        ibu: 65,
        srm: 8,
        batchSize: 20.0,
        efficiency: 75.0
    )
    
    SimpleTestRunner.assertEqual(recipe.name, "Test IPA", "Recipe name")
    SimpleTestRunner.assertEqual(recipe.style, "American IPA", "Recipe style")
    SimpleTestRunner.assertEqual(recipe.targetOG, 1.065, "Target OG")
    SimpleTestRunner.assertEqual(recipe.targetFG, 1.012, "Target FG")
    SimpleTestRunner.assertEqual(recipe.abv, 6.8, "ABV")
    SimpleTestRunner.assertEqual(recipe.ibu, 65, "IBU")
    SimpleTestRunner.assertEqual(recipe.srm, 8, "SRM")
    SimpleTestRunner.assertEqual(recipe.batchSize, 20.0, "Batch size")
    SimpleTestRunner.assertEqual(recipe.efficiency, 75.0, "Efficiency")
    
    // Test calculated apparent attenuation
    let expectedAttenuation = ((1.065 - 1.012) / (1.065 - 1.0)) * 100
    let actualAttenuation = recipe.apparentAttenuation
    SimpleTestRunner.assertTrue(abs(actualAttenuation - expectedAttenuation) < 0.1, "Apparent attenuation calculation")
}

func testIngredientModel() {
    print("\n🧪 Testing Ingredient Model...")
    
    struct TestIngredient {
        let id = UUID()
        var name: String
        var type: String
        var category: String
        var amount: Double
        var unit: String
        var notes: String
        
        var displayAmount: String {
            if amount == floor(amount) {
                return String(format: "%.0f %@", amount, unit)
            } else {
                return String(format: "%.1f %@", amount, unit)
            }
        }
    }
    
    let maltIngredient = TestIngredient(
        name: "Pilsner Malt",
        type: "Malt",
        category: "Base Malt",
        amount: 5.0,
        unit: "kg",
        notes: "Base malt for brewing"
    )
    
    let hopIngredient = TestIngredient(
        name: "Saaz Hops",
        type: "Hop",
        category: "Aroma",
        amount: 25.5,
        unit: "g",
        notes: "Noble hop variety"
    )
    
    SimpleTestRunner.assertEqual(maltIngredient.name, "Pilsner Malt", "Malt name")
    SimpleTestRunner.assertEqual(maltIngredient.type, "Malt", "Malt type")
    SimpleTestRunner.assertEqual(maltIngredient.displayAmount, "5 kg", "Malt display amount")
    
    SimpleTestRunner.assertEqual(hopIngredient.name, "Saaz Hops", "Hop name")
    SimpleTestRunner.assertEqual(hopIngredient.type, "Hop", "Hop type")
    SimpleTestRunner.assertEqual(hopIngredient.displayAmount, "25.5 g", "Hop display amount")
}

// Run all tests
print("🧪 HomeBrewAssistant Simple Test Suite")
print("=====================================")

testTimerModel()
testTimerProgressCalculations()
testTimerDisplayFormatting()
testRecipeModel()
testIngredientModel()

SimpleTestRunner.printSummary()

// Exit with appropriate code
exit(SimpleTestRunner.failed == 0 ? 0 : 1) 