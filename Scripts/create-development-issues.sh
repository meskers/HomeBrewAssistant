#!/bin/bash

# 📋 GitHub Issues Creator voor Development Tasks
# Automatisch issues aanmaken op basis van roadmap

echo "📋 Creating GitHub Issues for HomeBrewAssistant Development"
echo "========================================================="

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Install it from: https://cli.github.com/"
    echo "Or run: brew install gh"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "🔐 Please authenticate with GitHub first:"
    echo "Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is ready!"
echo ""

# v1.1 Critical Fixes
echo "Creating v1.1 Bug Fix Issues..."

gh issue create \
    --title "🐛 Fix recipe scaling type conversion issues" \
    --body "## Problem
Recipe scaling functionality has type conversion issues between DetailedRecipe and DetailedRecipeModel.

## Expected Behavior
Recipe scaling should work seamlessly with proper type conversions.

## Tasks
- [ ] Identify type conversion points
- [ ] Implement proper conversion functions
- [ ] Test scaling with different recipe types
- [ ] Update RecipeScalingView implementation

## Priority
High - affects core functionality" \
    --label "bug,v1.1,high-priority"

gh issue create \
    --title "🎨 Resolve UI/UX inconsistencies" \
    --body "## Problem
Various UI/UX inconsistencies throughout the app need to be addressed.

## Tasks
- [ ] Audit all views for consistency
- [ ] Standardize color usage
- [ ] Fix navigation flow issues
- [ ] Improve form layouts
- [ ] Standardize button styles

## Priority
Medium - improves user experience" \
    --label "enhancement,ui,v1.1"

gh issue create \
    --title "⚡ Optimize app performance and memory usage" \
    --body "## Problem
App performance can be improved, especially memory usage and startup time.

## Tasks
- [ ] Profile app performance
- [ ] Optimize Core Data queries
- [ ] Reduce memory footprint
- [ ] Improve app startup time
- [ ] Add performance monitoring

## Priority
Medium - affects user experience" \
    --label "performance,v1.1"

# v1.2 Enhanced Features
echo "Creating v1.2 Enhancement Issues..."

gh issue create \
    --title "🧪 Implement advanced mash calculator" \
    --body "## Feature Description
Add advanced mash calculation functionality for precise brewing calculations.

## Requirements
- Step mash temperature calculations
- Time-based mash scheduling
- Efficiency calculations
- Water-to-grain ratios

## Implementation
- [ ] Design calculator UI
- [ ] Implement calculation logic
- [ ] Add unit tests
- [ ] Integrate with recipe builder

## Priority
Medium - enhances brewing capabilities" \
    --label "feature,calculator,v1.2"

gh issue create \
    --title "💧 Add water chemistry calculator" \
    --body "## Feature Description
Water chemistry calculator for optimal brewing water preparation.

## Requirements
- pH calculations
- Mineral additions
- Water profile matching
- Style-specific recommendations

## Implementation
- [ ] Research water chemistry formulas
- [ ] Design calculator interface
- [ ] Implement calculation engine
- [ ] Add water profile database

## Priority
Medium - advanced brewing feature" \
    --label "feature,calculator,v1.2"

gh issue create \
    --title "📊 Implement brew session logging" \
    --body "## Feature Description
Detailed logging system for brew sessions to track progress and results.

## Requirements
- Session start/stop tracking
- Step-by-step logging
- Notes and observations
- Photo attachments
- Session history

## Implementation
- [ ] Design logging data model
- [ ] Create session UI
- [ ] Implement Core Data storage
- [ ] Add export functionality

## Priority
High - core brewing feature" \
    --label "feature,logging,v1.2"

# v2.0 Cloud Features
echo "Creating v2.0 Cloud Feature Issues..."

gh issue create \
    --title "☁️ Implement CloudKit synchronization" \
    --body "## Feature Description
CloudKit integration for cross-device recipe and data synchronization.

## Requirements
- Recipe synchronization
- Settings sync
- Conflict resolution
- Offline support

## Implementation
- [ ] Design CloudKit schema
- [ ] Implement sync logic
- [ ] Handle merge conflicts
- [ ] Add sync UI indicators
- [ ] Test on multiple devices

## Priority
High - enables multi-device usage" \
    --label "feature,cloud,v2.0,high-priority"

gh issue create \
    --title "🤖 Advanced AI recipe optimization" \
    --body "## Feature Description
AI-powered recipe optimization and suggestions.

## Requirements
- Recipe analysis
- Optimization suggestions
- Style compliance checking
- Ingredient substitutions

## Implementation
- [ ] Research AI/ML frameworks
- [ ] Design optimization algorithms
- [ ] Implement suggestion engine
- [ ] Add user feedback loop

## Priority
Medium - advanced feature" \
    --label "feature,ai,v2.0"

# Future Development
echo "Creating Future Development Issues..."

gh issue create \
    --title "⌚ Apple Watch companion app" \
    --body "## Feature Description
Apple Watch app for monitoring brew timers and quick access to brewing data.

## Requirements
- Timer display and controls
- Temperature monitoring
- Quick notes
- Standalone functionality

## Implementation
- [ ] Design Watch UI
- [ ] Implement WatchOS app
- [ ] Add complications
- [ ] Test user scenarios

## Priority
Low - nice-to-have feature" \
    --label "feature,watchos,future"

gh issue create \
    --title "📱 iPhone widget support" \
    --body "## Feature Description
iOS widgets for quick access to brewing information and timers.

## Requirements
- Active brew timer widget
- Recipe of the day widget
- Quick stats widget
- Multiple widget sizes

## Implementation
- [ ] Design widget layouts
- [ ] Implement WidgetKit
- [ ] Add configuration options
- [ ] Test widget performance

## Priority
Medium - improves accessibility" \
    --label "feature,widget,future"

echo ""
echo "🎉 All development issues created successfully!"
echo ""
echo "📋 Issues created for:"
echo "  • v1.1 Bug fixes and polish"
echo "  • v1.2 Enhanced features"
echo "  • v2.0 Cloud and AI features"
echo "  • Future development items"
echo ""
echo "🔗 View all issues: https://github.com/meskers/HomeBrewAssistant/issues"
echo ""
echo "✅ Your development roadmap is now tracked in GitHub Issues!" 