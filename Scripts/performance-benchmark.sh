#!/bin/bash

# 🚀 HomeBrewAssistant Performance Benchmarking Script
# Establishes baseline metrics for 5-star App Store optimization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}🚀 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_metric() {
    echo -e "${PURPLE}📊 $1${NC}"
}

print_target() {
    echo -e "${GREEN}🎯 $1${NC}"
}

# Create performance report directory
REPORT_DIR="TestReports/Performance"
mkdir -p "$REPORT_DIR"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
REPORT_FILE="$REPORT_DIR/benchmark_$TIMESTAMP.md"

print_header "Performance Benchmarking - 5-Star App Store Optimization"
echo "Report will be saved to: $REPORT_FILE"
echo ""

# Start report
cat > "$REPORT_FILE" << 'EOF'
# 🚀 HomeBrewAssistant Performance Benchmark Report

## Execution Details
EOF

echo "- **Date**: $(date)" >> "$REPORT_FILE"
echo "- **Version**: v1.3.0 (build 5)" >> "$REPORT_FILE"
echo "- **Platform**: iOS Simulator (iPhone 16 Pro)" >> "$REPORT_FILE"
echo "- **Xcode**: $(xcodebuild -version | head -1)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

print_metric "Testing build performance..."

# 1. BUILD PERFORMANCE
echo "## 📊 Build Performance Metrics" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Clean build test
print_metric "Performing clean build test..."
BUILD_START=$(date +%s)

xcodebuild clean -project HomeBrewAssistant.xcodeproj -scheme HomeBrewAssistant > /dev/null 2>&1
BUILD_RESULT=$(xcodebuild -project HomeBrewAssistant.xcodeproj -scheme HomeBrewAssistant -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build 2>&1)

BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))
BUILD_SUCCESS=$?

if [ $BUILD_SUCCESS -eq 0 ]; then
    print_success "Clean build completed in ${BUILD_TIME}s"
    echo "- **Clean Build Time**: ${BUILD_TIME}s ✅" >> "$REPORT_FILE"
    
    # Extract compilation metrics
    SWIFT_FILES=$(echo "$BUILD_RESULT" | grep -c "SwiftCompile normal arm64" || echo "0")
    echo "- **Swift Files Compiled**: $SWIFT_FILES" >> "$REPORT_FILE"
    
    # Check for warnings
    WARNINGS=$(echo "$BUILD_RESULT" | grep -c "warning:" || echo "0")
    echo "- **Build Warnings**: $WARNINGS" >> "$REPORT_FILE"
    
    if [ $WARNINGS -eq 0 ]; then
        print_success "Zero build warnings"
    else
        print_warning "$WARNINGS build warnings found"
    fi
else
    print_warning "Build failed"
    echo "- **Build Status**: ❌ FAILED" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# 2. CODE METRICS
print_metric "Analyzing code metrics..."

echo "## 📈 Code Quality Metrics" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Count lines of code
SWIFT_FILES_COUNT=$(find HomeBrewAssistant -name "*.swift" | wc -l | tr -d ' ')
TOTAL_LINES=$(find HomeBrewAssistant -name "*.swift" -exec wc -l {} + | tail -1 | awk '{print $1}')

if [ $SWIFT_FILES_COUNT -gt 0 ]; then
    AVG_LINES_PER_FILE=$((TOTAL_LINES / SWIFT_FILES_COUNT))
else
    AVG_LINES_PER_FILE=0
fi

echo "- **Swift Files**: $SWIFT_FILES_COUNT" >> "$REPORT_FILE"
echo "- **Total Lines of Code**: $TOTAL_LINES" >> "$REPORT_FILE"
echo "- **Average Lines per File**: $AVG_LINES_PER_FILE" >> "$REPORT_FILE"

print_metric "Swift files: $SWIFT_FILES_COUNT, Total LOC: $TOTAL_LINES"

# Find largest files (potential refactoring candidates)
echo "" >> "$REPORT_FILE"
echo "### 📋 Largest Files (Refactoring Candidates)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

find HomeBrewAssistant -name "*.swift" -exec wc -l {} + | sort -nr | head -10 | while read lines file; do
    if [ "$lines" != "total" ] && [ ! -z "$file" ]; then
        filename=$(basename "$file")
        echo "- **$filename**: $lines lines" >> "$REPORT_FILE"
        
        if [ "$lines" -gt 500 ]; then
            print_warning "$filename has $lines lines (consider refactoring)"
        fi
    fi
done

echo "" >> "$REPORT_FILE"

# 3. TESTING PERFORMANCE
print_metric "Running test performance analysis..."

echo "## 🧪 Testing Performance" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Run our simple test suite
TEST_START=$(date +%s)
TEST_RESULT=$(./SimpleTest.swift 2>&1)
TEST_END=$(date +%s)
TEST_TIME=$((TEST_END - TEST_START))

if [[ $TEST_RESULT == *"All tests passed!"* ]]; then
    PASSED_TESTS=$(echo "$TEST_RESULT" | grep "Passed:" | awk '{print $3}')
    print_success "All $PASSED_TESTS tests passed in ${TEST_TIME}s"
    echo "- **Test Execution Time**: ${TEST_TIME}s ✅" >> "$REPORT_FILE"
    echo "- **Tests Passed**: $PASSED_TESTS/31 ✅" >> "$REPORT_FILE"
    echo "- **Test Success Rate**: 100% ✅" >> "$REPORT_FILE"
else
    print_warning "Some tests failed"
    echo "- **Test Status**: ❌ SOME FAILED" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# 4. ACCESSIBILITY AUDIT
print_metric "Performing accessibility audit..."

echo "## ♿ Accessibility Metrics" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Count accessibility implementations
ACCESSIBILITY_LABELS=$(grep -r "accessibilityLabel" HomeBrewAssistant --include="*.swift" | wc -l | tr -d ' ')
ACCESSIBILITY_HINTS=$(grep -r "accessibilityHint" HomeBrewAssistant --include="*.swift" | wc -l | tr -d ' ')
ACCESSIBILITY_ELEMENTS=$(grep -r "accessibilityElement" HomeBrewAssistant --include="*.swift" | wc -l | tr -d ' ')

TOTAL_ACCESSIBILITY=$((ACCESSIBILITY_LABELS + ACCESSIBILITY_HINTS + ACCESSIBILITY_ELEMENTS))

echo "- **Accessibility Labels**: $ACCESSIBILITY_LABELS" >> "$REPORT_FILE"
echo "- **Accessibility Hints**: $ACCESSIBILITY_HINTS" >> "$REPORT_FILE"
echo "- **Accessibility Elements**: $ACCESSIBILITY_ELEMENTS" >> "$REPORT_FILE"
echo "- **Total Accessibility Implementations**: $TOTAL_ACCESSIBILITY" >> "$REPORT_FILE"

if [ $TOTAL_ACCESSIBILITY -gt 50 ]; then
    print_success "Good accessibility coverage ($TOTAL_ACCESSIBILITY implementations)"
    echo "- **Accessibility Coverage**: ✅ Good" >> "$REPORT_FILE"
else
    print_warning "Accessibility coverage needs improvement ($TOTAL_ACCESSIBILITY implementations)"
    echo "- **Accessibility Coverage**: ⚠️ Needs Improvement" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# 5. LOCALIZATION METRICS
print_metric "Analyzing localization coverage..."

echo "## 🌍 Localization Metrics" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Count localization strings
EN_STRINGS=0
NL_STRINGS=0

if [ -f "HomeBrewAssistant/Resources/en.lproj/Localizable.strings" ]; then
    EN_STRINGS=$(grep -c "^\"" HomeBrewAssistant/Resources/en.lproj/Localizable.strings || echo "0")
    echo "- **English Strings**: $EN_STRINGS" >> "$REPORT_FILE"
fi

if [ -f "HomeBrewAssistant/Resources/nl.lproj/Localizable.strings" ]; then
    NL_STRINGS=$(grep -c "^\"" HomeBrewAssistant/Resources/nl.lproj/Localizable.strings || echo "0")
    echo "- **Dutch Strings**: $NL_STRINGS" >> "$REPORT_FILE"
    
    if [ "$EN_STRINGS" = "$NL_STRINGS" ]; then
        print_success "Localization in sync (EN: $EN_STRINGS, NL: $NL_STRINGS)"
        echo "- **Localization Status**: ✅ In Sync" >> "$REPORT_FILE"
    else
        print_warning "Localization out of sync (EN: $EN_STRINGS, NL: $NL_STRINGS)"
        echo "- **Localization Status**: ⚠️ Out of Sync" >> "$REPORT_FILE"
    fi
fi

echo "" >> "$REPORT_FILE"

# 6. 5-STAR TARGET ASSESSMENT
echo "## 🌟 5-Star App Store Readiness Assessment" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

READINESS_SCORE=0
MAX_SCORE=7

# Build success
if [ $BUILD_SUCCESS -eq 0 ]; then
    echo "- ✅ **Build Success**: Compiles without errors" >> "$REPORT_FILE"
    ((READINESS_SCORE++))
else
    echo "- ❌ **Build Failed**: Must fix compilation errors" >> "$REPORT_FILE"
fi

# Testing
if [[ $TEST_RESULT == *"All tests passed!"* ]]; then
    echo "- ✅ **Testing**: All tests pass (31/31)" >> "$REPORT_FILE"
    ((READINESS_SCORE++))
else
    echo "- ❌ **Testing**: Some tests failing" >> "$REPORT_FILE"
fi

# Code quality
if [ "$AVG_LINES_PER_FILE" -lt 300 ]; then
    echo "- ✅ **Code Quality**: Good file size distribution" >> "$REPORT_FILE"
    ((READINESS_SCORE++))
else
    echo "- ⚠️ **Code Quality**: Some large files need refactoring" >> "$REPORT_FILE"
fi

# Accessibility
if [ $TOTAL_ACCESSIBILITY -gt 50 ]; then
    echo "- ✅ **Accessibility**: Good coverage" >> "$REPORT_FILE"
    ((READINESS_SCORE++))
else
    echo "- ⚠️ **Accessibility**: Needs improvement" >> "$REPORT_FILE"
fi

# Localization
if [ "$EN_STRINGS" = "$NL_STRINGS" ] && [ "$EN_STRINGS" -gt 50 ]; then
    echo "- ✅ **Localization**: Complete dual-language support" >> "$REPORT_FILE"
    ((READINESS_SCORE++))
else
    echo "- ⚠️ **Localization**: Needs attention" >> "$REPORT_FILE"
fi

# Performance (build time)
if [ "$BUILD_TIME" -lt 60 ]; then
    echo "- ✅ **Build Performance**: Fast compilation" >> "$REPORT_FILE"
    ((READINESS_SCORE++))
else
    echo "- ⚠️ **Build Performance**: Slow compilation" >> "$REPORT_FILE"
fi

# Zero warnings
if [ $WARNINGS -eq 0 ]; then
    echo "- ✅ **Code Quality**: Zero build warnings" >> "$REPORT_FILE"
    ((READINESS_SCORE++))
else
    echo "- ⚠️ **Code Quality**: Has build warnings" >> "$REPORT_FILE"
fi

READINESS_PERCENTAGE=$((READINESS_SCORE * 100 / MAX_SCORE))

echo "" >> "$REPORT_FILE"
echo "### 🎯 Overall Readiness Score" >> "$REPORT_FILE"
echo "**Score: $READINESS_SCORE/$MAX_SCORE ($READINESS_PERCENTAGE%)**" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ $READINESS_SCORE -ge 6 ]; then
    echo "🌟 **Status**: EXCELLENT - Ready for 5-star optimization!" >> "$REPORT_FILE"
    print_success "Readiness Score: $READINESS_SCORE/$MAX_SCORE ($READINESS_PERCENTAGE%) - EXCELLENT!"
elif [ $READINESS_SCORE -ge 4 ]; then
    echo "⭐ **Status**: GOOD - Minor improvements needed" >> "$REPORT_FILE"
    print_success "Readiness Score: $READINESS_SCORE/$MAX_SCORE ($READINESS_PERCENTAGE%) - GOOD!"
else
    echo "⚠️ **Status**: NEEDS WORK - Address critical issues first" >> "$REPORT_FILE"
    print_warning "Readiness Score: $READINESS_SCORE/$MAX_SCORE ($READINESS_PERCENTAGE%) - NEEDS WORK!"
fi

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*Report generated on $(date)*" >> "$REPORT_FILE"

print_header "Performance Benchmark Complete!"
print_success "Report saved to: $REPORT_FILE"

# Show immediate next steps
echo ""
print_header "🔥 IMMEDIATE NEXT STEPS FOR 5-STAR SUCCESS:"

if [ $READINESS_SCORE -ge 6 ]; then
    print_target "1. Implement advanced calculators (water chemistry)"
    print_target "2. Add custom animations and haptic feedback"
    print_target "3. Create professional App Store screenshots"
    print_target "4. Optimize onboarding flow"
else
    print_warning "1. Fix any build warnings or errors"
    print_warning "2. Improve accessibility coverage"
    print_warning "3. Complete localization sync"
    print_warning "4. Optimize performance metrics"
fi

echo ""
print_header "Ready to start PHASE 1 implementation! 🚀" 