#!/bin/bash

# 🏷️ Release Creation Automation Script
# Voor HomeBrewAssistant releases

set -e  # Exit on any error

echo "🚀 HomeBrewAssistant Release Creator"
echo "===================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Check if we're on main or develop branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$current_branch" != "main" && "$current_branch" != "develop" ]]; then
    print_error "Must be on main or develop branch to create release"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_error "You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

# Get current version from git tags
current_version=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
print_info "Current version: $current_version"

# Ask for new version
echo ""
echo "Release types:"
echo "1. Patch (bug fixes): v1.0.0 → v1.0.1"
echo "2. Minor (new features): v1.0.0 → v1.1.0"  
echo "3. Major (breaking changes): v1.0.0 → v2.0.0"
echo "4. Custom version"
echo ""
read -p "Select release type (1-4): " release_type

case $release_type in
    1)
        new_version=$(echo $current_version | awk -F. '{$NF++; print "v" $1"."$2"."$NF}' | sed 's/v v/v/')
        release_notes="🐛 Bug fixes and improvements"
        ;;
    2) 
        new_version=$(echo $current_version | awk -F. '{$(NF-1)++; $NF=0; print "v" $1"."$2"."$NF}' | sed 's/v v/v/')
        release_notes="✨ New features and enhancements"
        ;;
    3)
        new_version=$(echo $current_version | awk -F. '{$1++; $2=0; $NF=0; print "v" $1"."$2"."$NF}' | sed 's/v v/v/')
        release_notes="💥 Major update with breaking changes"
        ;;
    4)
        read -p "Enter custom version (e.g., v1.2.3): " new_version
        read -p "Enter release notes: " release_notes
        ;;
    *)
        print_error "Invalid selection"
        exit 1
        ;;
esac

print_info "New version will be: $new_version"
print_info "Release notes: $release_notes"

# Confirm
echo ""
read -p "Create release $new_version? (y/N): " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
    print_info "Release cancelled"
    exit 0
fi

# Update version in project files
print_info "Updating version in project files..."

# Update Info.plist if it exists
if [ -f "Info.plist" ]; then
    version_number=$(echo $new_version | sed 's/v//')
    sed -i "" "s/<string>.*<\/string>/<string>$version_number<\/string>/" Info.plist
    print_status "Updated Info.plist"
fi

# Build and test
print_info "Building and testing..."
if xcodebuild clean build \
    -project HomeBrewAssistant.xcodeproj \
    -scheme HomeBrewAssistant \
    -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.2' \
    CODE_SIGNING_ALLOWED=NO \
    -quiet; then
    print_status "Build successful"
else
    print_error "Build failed! Cannot create release."
    exit 1
fi

# Commit version changes
if ! git diff-index --quiet HEAD --; then
    git add .
    git commit -m "🔖 Bump version to $new_version"
    print_status "Committed version changes"
fi

# Create and push tag
print_info "Creating git tag..."
git tag -a $new_version -m "$release_notes"
git push origin $new_version
print_status "Tagged and pushed $new_version"

# Push commits if on develop, merge to main if needed
if [[ "$current_branch" == "develop" ]]; then
    git push origin develop
    print_info "Pushed develop branch"
    
    read -p "Merge to main branch? (y/N): " merge_main
    if [[ $merge_main == "y" || $merge_main == "Y" ]]; then
        git checkout main
        git merge develop
        git push origin main
        git checkout develop
        print_status "Merged and pushed to main"
    fi
else
    git push origin main
    print_status "Pushed main branch"
fi

# Generate changelog
print_info "Generating changelog..."
changelog_file="CHANGELOG-$new_version.md"
echo "# Release $new_version" > $changelog_file
echo "" >> $changelog_file
echo "$release_notes" >> $changelog_file
echo "" >> $changelog_file
echo "## Changes since $current_version:" >> $changelog_file
git log $current_version..HEAD --oneline >> $changelog_file

print_status "Changelog created: $changelog_file"

echo ""
echo "🎉 Release $new_version created successfully!"
echo ""
print_info "Next steps:"
echo "  • Go to GitHub: https://github.com/meskers/HomeBrewAssistant/releases"
echo "  • Edit the release $new_version"
echo "  • Add detailed release notes"
echo "  • Upload any assets if needed"
echo "  • Publish the release"
echo ""
print_status "Release automation completed! 🚀" 