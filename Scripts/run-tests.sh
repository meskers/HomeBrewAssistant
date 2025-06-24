#!/bin/bash

# 🧪 HomeBrewAssistant Test Runner Script
# Usage: ./Scripts/run-tests.sh [unit|integration|ui|all|coverage|performance]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="HomeBrewAssistant"
SCHEME="HomeBrewAssistant"
SIMULATOR="iPhone 15 Pro"
IOS_VERSION="17.2"
DESTINATION="platform=iOS Simulator,name=${SIMULATOR},OS=${IOS_VERSION}"

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORTS_DIR="${PROJECT_ROOT}/TestReports"
COVERAGE_DIR="${REPORTS_DIR}/Coverage"

# Create reports directory
mkdir -p "$REPORTS_DIR"
mkdir -p "$COVERAGE_DIR"

# Functions
print_header() {
    echo -e "${BLUE}===========================================${NC}"
    echo -e "${BLUE}🧪 $1${NC}"
    echo -e "${BLUE}===========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Check if Xcode is available
check_xcode() {
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode is not installed or not in PATH"
        exit 1
    fi
    
    print_info "Using Xcode version: $(xcodebuild -version | head -n 1)"
}

# Clean build artifacts
clean_build() {
    print_info "Cleaning build artifacts..."
    xcodebuild clean \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        > /dev/null 2>&1
    print_success "Build cleaned"
}

# Check simulator availability
check_simulator() {
    print_info "Checking simulator availability..."
    
    if ! xcrun simctl list devices | grep -q "$SIMULATOR"; then
        print_warning "Simulator '$SIMULATOR' not found, using available simulator"
        SIMULATOR=$(xcrun simctl list devices | grep iPhone | head -n 1 | sed 's/.*iPhone \([^(]*\).*/iPhone \1/' | xargs)
        DESTINATION="platform=iOS Simulator,name=${SIMULATOR}"
        print_info "Using simulator: $SIMULATOR"
    else
        print_success "Simulator '$SIMULATOR' is available"
    fi
}

# Run unit tests
run_unit_tests() {
    print_header "Running Unit Tests"
    
    local test_results="${REPORTS_DIR}/unit_tests.txt"
    
    if xcodebuild test \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:"${PROJECT_NAME}Tests" \
        -resultBundlePath "${REPORTS_DIR}/UnitTests.xcresult" \
        2>&1 | tee "$test_results"; then
        
        print_success "Unit tests passed!"
        return 0
    else
        print_error "Unit tests failed!"
        return 1
    fi
}

# Run integration tests
run_integration_tests() {
    print_header "Running Integration Tests"
    
    local test_results="${REPORTS_DIR}/integration_tests.txt"
    
    # For now, integration tests are part of the main test target
    # In the future, they could be separated into their own target
    if xcodebuild test \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:"${PROJECT_NAME}Tests/Integration" \
        -resultBundlePath "${REPORTS_DIR}/IntegrationTests.xcresult" \
        2>&1 | tee "$test_results"; then
        
        print_success "Integration tests passed!"
        return 0
    else
        print_error "Integration tests failed!"
        return 1
    fi
}

# Run UI tests
run_ui_tests() {
    print_header "Running UI Tests"
    
    local test_results="${REPORTS_DIR}/ui_tests.txt"
    
    if xcodebuild test \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:"${PROJECT_NAME}UITests" \
        -resultBundlePath "${REPORTS_DIR}/UITests.xcresult" \
        2>&1 | tee "$test_results"; then
        
        print_success "UI tests passed!"
        return 0
    else
        print_error "UI tests failed!"
        return 1
    fi
}

# Run all tests
run_all_tests() {
    print_header "Running All Tests"
    
    local test_results="${REPORTS_DIR}/all_tests.txt"
    local success=0
    
    if xcodebuild test \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -resultBundlePath "${REPORTS_DIR}/AllTests.xcresult" \
        2>&1 | tee "$test_results"; then
        
        print_success "All tests passed!"
    else
        print_error "Some tests failed!"
        success=1
    fi
    
    # Extract test summary
    echo ""
    print_info "Test Summary:"
    if grep -q "Test Suite.*passed" "$test_results"; then
        grep "Test Suite.*passed\|Test Suite.*failed" "$test_results" | tail -5
    fi
    
    return $success
}

# Generate test coverage report
generate_coverage() {
    print_header "Generating Test Coverage Report"
    
    # Run tests with code coverage
    xcodebuild test \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -enableCodeCoverage YES \
        -resultBundlePath "${REPORTS_DIR}/CoverageTests.xcresult" \
        > /dev/null 2>&1
    
    # Generate coverage report using xcparse (if available)
    if command -v xcparse &> /dev/null; then
        print_info "Generating detailed coverage report with xcparse..."
        xcparse codecov "${REPORTS_DIR}/CoverageTests.xcresult" "${COVERAGE_DIR}/coverage.json"
        print_success "Coverage report generated at ${COVERAGE_DIR}/coverage.json"
    else
        print_warning "xcparse not installed. Install with: brew install chargepoint/xcparse/xcparse"
        print_info "Coverage data available in Xcode result bundle: ${REPORTS_DIR}/CoverageTests.xcresult"
    fi
    
    # Basic coverage summary from xcodebuild output
    print_info "Basic coverage information:"
    echo "Open ${REPORTS_DIR}/CoverageTests.xcresult in Xcode to view detailed coverage"
}

# Run performance tests
run_performance_tests() {
    print_header "Running Performance Tests"
    
    local test_results="${REPORTS_DIR}/performance_tests.txt"
    
    # Performance tests are typically marked with specific naming or in specific classes
    if xcodebuild test \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:"${PROJECT_NAME}Tests" \
        -only-testing:"${PROJECT_NAME}UITests" \
        -resultBundlePath "${REPORTS_DIR}/PerformanceTests.xcresult" \
        2>&1 | tee "$test_results"; then
        
        print_success "Performance tests completed!"
        
        # Extract performance metrics if available
        if grep -q "Performance" "$test_results"; then
            print_info "Performance metrics:"
            grep -A 5 -B 5 "Performance\|measure\|XCTMetric" "$test_results" | tail -20
        fi
        
        return 0
    else
        print_error "Performance tests failed!"
        return 1
    fi
}

# Validate test setup
validate_setup() {
    print_header "Validating Test Setup"
    
    # Check if test files exist
    local unit_tests_exist=false
    local ui_tests_exist=false
    
    if [ -d "${PROJECT_ROOT}/${PROJECT_NAME}Tests" ]; then
        unit_tests_exist=true
        print_success "Unit test directory found"
    else
        print_warning "Unit test directory not found at ${PROJECT_ROOT}/${PROJECT_NAME}Tests"
    fi
    
    if [ -d "${PROJECT_ROOT}/${PROJECT_NAME}UITests" ]; then
        ui_tests_exist=true
        print_success "UI test directory found"
    else
        print_warning "UI test directory not found at ${PROJECT_ROOT}/${PROJECT_NAME}UITests"
    fi
    
    # Check if test targets are in project
    local project_content
    if [ -f "${PROJECT_NAME}.xcodeproj/project.pbxproj" ]; then
        project_content=$(cat "${PROJECT_NAME}.xcodeproj/project.pbxproj")
        
        if echo "$project_content" | grep -q "${PROJECT_NAME}Tests"; then
            print_success "Unit test target found in project"
        else
            print_warning "Unit test target not found in project file"
        fi
        
        if echo "$project_content" | grep -q "${PROJECT_NAME}UITests"; then
            print_success "UI test target found in project"
        else
            print_warning "UI test target not found in project file"
        fi
    fi
    
    if [ "$unit_tests_exist" = false ] && [ "$ui_tests_exist" = false ]; then
        print_error "No test directories found! Run this script from the project root."
        return 1
    fi
    
    return 0
}

# Open test results
open_results() {
    print_info "Opening test results..."
    
    # Find the most recent result bundle
    local latest_result
    latest_result=$(find "$REPORTS_DIR" -name "*.xcresult" -type d | head -n 1)
    
    if [ -n "$latest_result" ]; then
        open "$latest_result"
        print_success "Opened test results in Xcode"
    else
        print_warning "No test result bundles found"
        open "$REPORTS_DIR"
    fi
}

# Cleanup old test results
cleanup_results() {
    print_info "Cleaning up old test results..."
    
    # Keep only the 5 most recent result bundles
    find "$REPORTS_DIR" -name "*.xcresult" -type d | head -n -5 | xargs rm -rf
    
    # Clean up old text reports older than 7 days
    find "$REPORTS_DIR" -name "*.txt" -mtime +7 -delete
    
    print_success "Cleanup completed"
}

# CI mode - for continuous integration
run_ci_mode() {
    print_header "Running in CI Mode"
    
    local exit_code=0
    
    # Validate setup
    if ! validate_setup; then
        exit_code=1
    fi
    
    # Clean build
    clean_build
    
    # Run all tests
    if ! run_all_tests; then
        exit_code=1
    fi
    
    # Generate coverage
    generate_coverage
    
    # Cleanup
    cleanup_results
    
    if [ $exit_code -eq 0 ]; then
        print_success "CI tests completed successfully!"
    else
        print_error "CI tests failed!"
    fi
    
    return $exit_code
}

# Display help
show_help() {
    echo "🧪 HomeBrewAssistant Test Runner"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  unit         Run unit tests only"
    echo "  integration  Run integration tests only"
    echo "  ui           Run UI tests only"
    echo "  all          Run all tests (default)"
    echo "  coverage     Generate test coverage report"
    echo "  performance  Run performance tests"
    echo "  validate     Validate test setup"
    echo "  clean        Clean build artifacts"
    echo "  open         Open latest test results"
    echo "  cleanup      Clean up old test results"
    echo "  ci           Run in CI mode (all tests + coverage)"
    echo "  help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all tests"
    echo "  $0 unit              # Run only unit tests"
    echo "  $0 coverage          # Generate coverage report"
    echo "  $0 ci                # Run in CI mode"
    echo ""
    echo "Reports are saved to: $REPORTS_DIR"
}

# Main execution
main() {
    local command="${1:-all}"
    
    # Change to project directory
    cd "$PROJECT_ROOT"
    
    # Pre-flight checks
    check_xcode
    check_simulator
    
    case "$command" in
        "unit")
            run_unit_tests
            ;;
        "integration")
            run_integration_tests
            ;;
        "ui")
            run_ui_tests
            ;;
        "all")
            run_all_tests
            ;;
        "coverage")
            generate_coverage
            ;;
        "performance")
            run_performance_tests
            ;;
        "validate")
            validate_setup
            ;;
        "clean")
            clean_build
            ;;
        "open")
            open_results
            ;;
        "cleanup")
            cleanup_results
            ;;
        "ci")
            run_ci_mode
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@" 