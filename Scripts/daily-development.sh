#!/bin/bash

# 🚀 Daily Development Automation Script
# Voor HomeBrewAssistant development

echo "🍺 HomeBrewAssistant Daily Development Script"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 1. Git Status Check
echo ""
print_info "Checking Git status..."
if git diff-index --quiet HEAD --; then
    print_status "No uncommitted changes"
else
    print_warning "You have uncommitted changes:"
    git status --porcelain
fi

# 2. Update from remote
echo ""
print_info "Fetching latest changes from remote..."
git fetch origin

# 3. Check current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
print_info "Current branch: $current_branch"

# 4. Build the project
echo ""
print_info "Building HomeBrewAssistant..."
if xcodebuild clean build \
    -project HomeBrewAssistant.xcodeproj \
    -scheme HomeBrewAssistant \
    -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.2' \
    CODE_SIGNING_ALLOWED=NO \
    -quiet; then
    print_status "Build successful!"
else
    print_error "Build failed!"
    exit 1
fi

# 5. Run tests if they exist
echo ""
print_info "Running tests..."
if xcodebuild test \
    -project HomeBrewAssistant.xcodeproj \
    -scheme HomeBrewAssistant \
    -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.2' \
    CODE_SIGNING_ALLOWED=NO \
    -quiet 2>/dev/null; then
    print_status "All tests passed!"
else
    print_warning "Tests failed or no tests found"
fi

# 6. Check for TODO/FIXME comments
echo ""
print_info "Checking for TODO/FIXME comments..."
todo_count=$(grep -r "TODO\|FIXME\|XXX" --include="*.swift" HomeBrewAssistant/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$todo_count" -gt 0 ]; then
    print_warning "Found $todo_count TODO/FIXME comments"
    grep -r "TODO\|FIXME\|XXX" --include="*.swift" HomeBrewAssistant/ | head -5
else
    print_status "No TODO/FIXME comments found"
fi

# 7. Check code formatting (basic)
echo ""
print_info "Checking code formatting..."
# Basic check for consistent indentation
if find HomeBrewAssistant/ -name "*.swift" -exec grep -l "    " {} \; | wc -l | grep -q "0"; then
    print_warning "Some files might have inconsistent indentation"
else
    print_status "Code formatting looks good"
fi

# 8. Check for recent commits
echo ""
print_info "Recent commits (last 3):"
git log --oneline -3

# 9. Summary
echo ""
echo "==============================================="
print_status "Daily development check completed!"
echo ""
print_info "Next steps:"
echo "  • Check GitHub Issues for new bugs/features"
echo "  • Review any failed tests"
echo "  • Address TODO/FIXME comments"
echo "  • Push any new commits"
echo ""
print_info "Happy coding! 🚀" 