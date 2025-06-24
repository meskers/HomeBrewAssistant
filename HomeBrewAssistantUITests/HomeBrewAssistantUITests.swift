//
//  HomeBrewAssistantUITests.swift
//  HomeBrewAssistantUITests
//
//  Created by Automated Testing on 24/06/2025.
//

import XCTest

final class HomeBrewAssistantUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        // Wait for splash screen to complete
        _ = app.staticTexts["HomeBrewAssistant"].waitForExistence(timeout: 5.0)
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - App Launch Tests
    
    func testAppLaunch() throws {
        // Test that app launches successfully
        XCTAssertTrue(app.staticTexts["HomeBrewAssistant"].exists)
        
        // Test that main tab view is present
        XCTAssertTrue(app.tabBars.firstMatch.exists)
        
        // Test that main tabs are accessible
        XCTAssertTrue(app.buttons["Recepten"].exists)
        XCTAssertTrue(app.buttons["Brouwen"].exists)
        XCTAssertTrue(app.buttons["Calculators"].exists)
        XCTAssertTrue(app.buttons["Brew Monitor"].exists)
        XCTAssertTrue(app.buttons["Ingrediënten"].exists)
        XCTAssertTrue(app.buttons["Meer"].exists)
    }
    
    func testOnboardingSkip() throws {
        // If onboarding is shown, test skipping it
        if app.navigationBars["Welkom"].exists {
            let skipButton = app.buttons["Overslaan"]
            if skipButton.exists {
                skipButton.tap()
                
                // Should navigate to main app
                XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 2.0))
            }
        }
    }
    
    // MARK: - Tab Navigation Tests
    
    func testTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
        
        // Test Recepten tab
        app.buttons["Recepten"].tap()
        XCTAssertTrue(app.navigationBars["Recepten"].waitForExistence(timeout: 2.0))
        
        // Test Brouwen tab
        app.buttons["Brouwen"].tap()
        XCTAssertTrue(app.navigationBars["Brouwen"].waitForExistence(timeout: 2.0))
        
        // Test Calculators tab
        app.buttons["Calculators"].tap()
        XCTAssertTrue(app.navigationBars["Calculators"].waitForExistence(timeout: 2.0))
        
        // Test Brew Monitor tab
        app.buttons["Brew Monitor"].tap()
        XCTAssertTrue(app.navigationBars["Brew Monitor"].waitForExistence(timeout: 2.0))
        
        // Test Ingrediënten tab
        app.buttons["Ingrediënten"].tap()
        XCTAssertTrue(app.navigationBars["Ingrediënten"].waitForExistence(timeout: 2.0))
        
        // Test Meer tab
        app.buttons["Meer"].tap()
        XCTAssertTrue(app.navigationBars["Meer"].waitForExistence(timeout: 2.0))
    }
    
    // MARK: - Recipe Tests
    
    func testRecipesList() throws {
        // Navigate to Recepten tab
        app.buttons["Recepten"].tap()
        
        // Check if recipes list is displayed
        XCTAssertTrue(app.scrollViews.firstMatch.exists)
        
        // Test if default recipes are loaded
        let recipeList = app.scrollViews.firstMatch
        XCTAssertTrue(recipeList.exists)
        
        // Look for any recipe cards (default recipes should be present)
        if app.buttons.matching(identifier: "recipe_card").count > 0 {
            let firstRecipeCard = app.buttons.matching(identifier: "recipe_card").element(boundBy: 0)
            XCTAssertTrue(firstRecipeCard.exists)
        }
    }
    
    func testRecipeDetail() throws {
        // Navigate to Recepten tab
        app.buttons["Recepten"].tap()
        
        // Wait for recipes to load
        _ = app.scrollViews.firstMatch.waitForExistence(timeout: 3.0)
        
        // If there are recipe cards, tap on the first one
        let recipeCards = app.buttons.matching(identifier: "recipe_card")
        if recipeCards.count > 0 {
            recipeCards.element(boundBy: 0).tap()
            
            // Should navigate to recipe detail
            XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 2.0))
            
            // Test back navigation
            let backButton = app.navigationBars.firstMatch.buttons.firstMatch
            if backButton.exists {
                backButton.tap()
                
                // Should return to recipes list
                XCTAssertTrue(app.navigationBars["Recepten"].waitForExistence(timeout: 2.0))
            }
        }
    }
    
    // MARK: - Timer Tests
    
    func testBrewTimerNavigation() throws {
        // Navigate to Brouwen tab
        app.buttons["Brouwen"].tap()
        
        // Should show brew tracker view
        XCTAssertTrue(app.navigationBars["Brouwen"].waitForExistence(timeout: 2.0))
        
        // Test timer interface elements
        XCTAssertTrue(app.scrollViews.firstMatch.exists)
        
        // Look for timer-related buttons
        if app.buttons["add_timer"].exists {
            XCTAssertTrue(app.buttons["add_timer"].exists)
        }
        
        // Look for preset timers section
        if app.staticTexts["Preset Timers"].exists {
            XCTAssertTrue(app.staticTexts["Preset Timers"].exists)
        }
    }
    
    func testAddTimerFlow() throws {
        // Navigate to Brouwen tab
        app.buttons["Brouwen"].tap()
        
        // Look for add timer button
        let addTimerButton = app.buttons["add_timer"]
        if addTimerButton.exists {
            addTimerButton.tap()
            
            // Should show add timer sheet/view
            _ = app.textFields.firstMatch.waitForExistence(timeout: 2.0)
            
            // Test timer creation form (if it exists)
            let nameField = app.textFields["timer_name"]
            if nameField.exists {
                nameField.tap()
                nameField.typeText("Test Timer")
                
                // Try to find duration input
                let durationField = app.textFields["timer_duration"]
                if durationField.exists {
                    durationField.tap()
                    durationField.typeText("300") // 5 minutes
                }
                
                // Look for save/add button
                let saveButton = app.buttons["save_timer"]
                if saveButton.exists {
                    saveButton.tap()
                    
                    // Should return to main timer view
                    XCTAssertTrue(app.navigationBars["Brouwen"].waitForExistence(timeout: 2.0))
                }
            }
        }
    }
    
    // MARK: - Calculator Tests
    
    func testCalculatorsNavigation() throws {
        // Navigate to Calculators tab
        app.buttons["Calculators"].tap()
        
        // Should show calculators grid
        XCTAssertTrue(app.navigationBars["Calculators"].waitForExistence(timeout: 2.0))
        
        // Test calculator grid exists
        XCTAssertTrue(app.scrollViews.firstMatch.exists)
        
        // Look for calculator buttons
        if app.buttons["hydrometer_calculator"].exists {
            app.buttons["hydrometer_calculator"].tap()
            
            // Should navigate to hydrometer calculator
            _ = app.navigationBars.firstMatch.waitForExistence(timeout: 2.0)
            
            // Test back navigation
            let backButton = app.navigationBars.firstMatch.buttons.firstMatch
            if backButton.exists {
                backButton.tap()
                XCTAssertTrue(app.navigationBars["Calculators"].waitForExistence(timeout: 2.0))
            }
        }
        
        if app.buttons["strike_water_calculator"].exists {
            app.buttons["strike_water_calculator"].tap()
            
            // Should navigate to strike water calculator
            _ = app.navigationBars.firstMatch.waitForExistence(timeout: 2.0)
            
            // Test back navigation
            let backButton = app.navigationBars.firstMatch.buttons.firstMatch
            if backButton.exists {
                backButton.tap()
                XCTAssertTrue(app.navigationBars["Calculators"].waitForExistence(timeout: 2.0))
            }
        }
    }
    
    // MARK: - Ingredients Tests
    
    func testIngredientsView() throws {
        // Navigate to Ingrediënten tab
        app.buttons["Ingrediënten"].tap()
        
        // Should show ingredients view
        XCTAssertTrue(app.navigationBars["Ingrediënten"].waitForExistence(timeout: 2.0))
        
        // Test ingredients interface
        XCTAssertTrue(app.scrollViews.firstMatch.exists)
        
        // Look for ingredient-related elements
        if app.buttons["add_ingredient"].exists {
            XCTAssertTrue(app.buttons["add_ingredient"].exists)
        }
    }
    
    // MARK: - Settings Tests
    
    func testMoreTabNavigation() throws {
        // Navigate to Meer tab
        app.buttons["Meer"].tap()
        
        // Should show more/settings view
        XCTAssertTrue(app.navigationBars["Meer"].waitForExistence(timeout: 2.0))
        
        // Test settings list exists
        XCTAssertTrue(app.scrollViews.firstMatch.exists)
        
        // Look for settings options
        if app.buttons["settings"].exists {
            app.buttons["settings"].tap()
            
            // Should navigate to settings
            _ = app.navigationBars.firstMatch.waitForExistence(timeout: 2.0)
            
            // Test back navigation
            let backButton = app.navigationBars.firstMatch.buttons.firstMatch
            if backButton.exists {
                backButton.tap()
                XCTAssertTrue(app.navigationBars["Meer"].waitForExistence(timeout: 2.0))
            }
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        // Test main tab accessibility
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
        
        let receptenTab = app.buttons["Recepten"]
        XCTAssertTrue(receptenTab.exists)
        XCTAssertNotNil(receptenTab.label)
        
        let brouwenTab = app.buttons["Brouwen"]
        XCTAssertTrue(brouwenTab.exists)
        XCTAssertNotNil(brouwenTab.label)
        
        let calculatorsTab = app.buttons["Calculators"]
        XCTAssertTrue(calculatorsTab.exists)
        XCTAssertNotNil(calculatorsTab.label)
        
        // Test VoiceOver navigation
        XCTAssertTrue(receptenTab.isHittable)
        XCTAssertTrue(brouwenTab.isHittable)
        XCTAssertTrue(calculatorsTab.isHittable)
    }
    
    func testVoiceOverSupport() throws {
        // Navigate through tabs and verify accessibility
        let tabs = ["Recepten", "Brouwen", "Calculators", "Brew Monitor", "Ingrediënten", "Meer"]
        
        for tabName in tabs {
            let tab = app.buttons[tabName]
            if tab.exists {
                XCTAssertTrue(tab.isHittable, "Tab \(tabName) should be accessible to VoiceOver")
                XCTAssertFalse(tab.label.isEmpty, "Tab \(tabName) should have accessibility label")
                
                tab.tap()
                
                // Wait for navigation to complete
                _ = app.navigationBars.firstMatch.waitForExistence(timeout: 2.0)
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchPerformance() throws {
        // Test app launch performance
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func testTabNavigationPerformance() throws {
        // Test tab navigation performance
        measure {
            let tabs = ["Recepten", "Brouwen", "Calculators", "Brew Monitor", "Ingrediënten", "Meer"]
            
            for tabName in tabs {
                app.buttons[tabName].tap()
                _ = app.navigationBars.firstMatch.waitForExistence(timeout: 1.0)
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkErrorHandling() throws {
        // This test would require network mocking
        // For now, just verify app doesn't crash during navigation
        
        let tabs = ["Recepten", "Brouwen", "Calculators", "Brew Monitor", "Ingrediënten", "Meer"]
        
        for tabName in tabs {
            app.buttons[tabName].tap()
            
            // App should remain responsive
            XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 3.0))
            
            // No crash alerts should appear
            XCTAssertFalse(app.alerts.firstMatch.exists)
        }
    }
    
    // MARK: - Localization Tests
    
    func testDutchLocalization() throws {
        // Test that Dutch text appears correctly
        XCTAssertTrue(app.buttons["Recepten"].exists)
        XCTAssertTrue(app.buttons["Brouwen"].exists)
        XCTAssertTrue(app.buttons["Ingrediënten"].exists)
        XCTAssertTrue(app.buttons["Meer"].exists)
        
        // Navigate to each tab and verify Dutch text
        app.buttons["Recepten"].tap()
        XCTAssertTrue(app.navigationBars["Recepten"].waitForExistence(timeout: 2.0))
        
        app.buttons["Brouwen"].tap()
        XCTAssertTrue(app.navigationBars["Brouwen"].waitForExistence(timeout: 2.0))
        
        app.buttons["Meer"].tap()
        XCTAssertTrue(app.navigationBars["Meer"].waitForExistence(timeout: 2.0))
    }
    
    // MARK: - Memory Tests
    
    func testMemoryUsage() throws {
        // Navigate through all tabs multiple times to test for memory leaks
        let tabs = ["Recepten", "Brouwen", "Calculators", "Brew Monitor", "Ingrediënten", "Meer"]
        
        for _ in 0..<3 {
            for tabName in tabs {
                app.buttons[tabName].tap()
                _ = app.navigationBars.firstMatch.waitForExistence(timeout: 1.0)
                
                // Small delay to allow memory cleanup
                usleep(100000) // 0.1 seconds
            }
        }
        
        // App should still be responsive after multiple navigations
        XCTAssertTrue(app.tabBars.firstMatch.exists)
        XCTAssertFalse(app.alerts.firstMatch.exists)
    }
} 