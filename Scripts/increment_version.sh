#!/bin/bash

# HomeBrewAssistant Version Management Script
# This script automatically increments version numbers following semantic versioning

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_FILE="HomeBrewAssistant.xcodeproj/project.pbxproj"
PLIST_FILE="Info.plist"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get current version from project file
get_current_version() {
    if [ -f "$PROJECT_FILE" ]; then
        grep -m 1 "MARKETING_VERSION" "$PROJECT_FILE" | sed 's/.*= \(.*\);/\1/' | tr -d ' '
    else
        echo "1.0.0"
    fi
}

# Function to get current build number
get_current_build() {
    if [ -f "$PROJECT_FILE" ]; then
        grep -m 1 "CURRENT_PROJECT_VERSION" "$PROJECT_FILE" | sed 's/.*= \(.*\);/\1/' | tr -d ' '
    else
        echo "1"
    fi
}

# Function to increment version based on type
increment_version() {
    local version=$1
    local type=$2
    
    IFS='.' read -ra VERSION_PARTS <<< "$version"
    local major=${VERSION_PARTS[0]}
    local minor=${VERSION_PARTS[1]:-0}
    local patch=${VERSION_PARTS[2]:-0}
    
    case $type in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "patch")
            patch=$((patch + 1))
            ;;
        *)
            print_error "Invalid version type: $type. Use major, minor, or patch."
            exit 1
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Function to update version in project file
update_project_version() {
    local new_version=$1
    local new_build=$2
    
    if [ -f "$PROJECT_FILE" ]; then
        # Update marketing version
        sed -i '' "s/MARKETING_VERSION = .*;/MARKETING_VERSION = $new_version;/g" "$PROJECT_FILE"
        # Update build number
        sed -i '' "s/CURRENT_PROJECT_VERSION = .*;/CURRENT_PROJECT_VERSION = $new_build;/g" "$PROJECT_FILE"
        print_success "Updated project file with version $new_version ($new_build)"
    else
        print_error "Project file not found: $PROJECT_FILE"
        exit 1
    fi
}

# Function to update Info.plist file
update_plist_version() {
    local new_version=$1
    local new_build=$2
    
    if [ -f "$PLIST_FILE" ]; then
        # Update CFBundleShortVersionString
        /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $new_version" "$PLIST_FILE"
        # Update CFBundleVersion
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $new_build" "$PLIST_FILE"
        print_success "Updated Info.plist with version $new_version ($new_build)"
    else
        print_error "Info.plist file not found: $PLIST_FILE"
        exit 1
    fi
}

# Function to create git tag
create_git_tag() {
    local version=$1
    local build=$2
    local tag="v$version-build$build"
    
    if git rev-parse --git-dir > /dev/null 2>&1; then
        if git tag -l | grep -q "^$tag$"; then
            print_warning "Tag $tag already exists"
        else
            git tag -a "$tag" -m "Release version $version (build $build)"
            print_success "Created git tag: $tag"
        fi
    else
        print_warning "Not a git repository, skipping tag creation"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [major|minor|patch] [options]"
    echo ""
    echo "Version types:"
    echo "  major    - Increment major version (x.0.0)"
    echo "  minor    - Increment minor version (x.y.0)"
    echo "  patch    - Increment patch version (x.y.z)"
    echo ""
    echo "Options:"
    echo "  --no-tag    - Don't create git tag"
    echo "  --dry-run   - Show what would be changed without making changes"
    echo "  --help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 patch                    # Increment patch version"
    echo "  $0 minor --no-tag          # Increment minor version without git tag"
    echo "  $0 major --dry-run         # Show what major version increment would do"
}

# Main script
main() {
    local version_type=""
    local create_tag=true
    local dry_run=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            major|minor|patch)
                version_type=$1
                shift
                ;;
            --no-tag)
                create_tag=false
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate arguments
    if [ -z "$version_type" ]; then
        print_error "Version type is required"
        show_usage
        exit 1
    fi
    
    # Get current versions
    current_version=$(get_current_version)
    current_build=$(get_current_build)
    
    print_status "Current version: $current_version ($current_build)"
    
    # Calculate new versions
    new_version=$(increment_version "$current_version" "$version_type")
    new_build=$((current_build + 1))
    
    print_status "New version: $new_version ($new_build)"
    
    if [ "$dry_run" = true ]; then
        print_warning "DRY RUN - No changes will be made"
        print_status "Would update version from $current_version to $new_version"
        print_status "Would update build from $current_build to $new_build"
        if [ "$create_tag" = true ]; then
            print_status "Would create git tag: v$new_version-build$new_build"
        fi
        exit 0
    fi
    
    # Confirm changes
    echo ""
    read -p "Update version from $current_version ($current_build) to $new_version ($new_build)? [y/N] " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Version update cancelled"
        exit 0
    fi
    
    # Make changes
    print_status "Updating version..."
    update_project_version "$new_version" "$new_build"
    update_plist_version "$new_version" "$new_build"    
    if [ "$create_tag" = true ]; then
        create_git_tag "$new_version" "$new_build"
    fi
    
    print_success "Version successfully updated to $new_version ($new_build)"
    
    # Show next steps
    echo ""
    print_status "Next steps:"
    echo "  1. Update changelog in VersionManager.swift"
    echo "  2. Test the app with new version"
    echo "  3. Commit changes: git add . && git commit -m 'Bump version to $new_version'"
    if [ "$create_tag" = true ]; then
        echo "  4. Push with tags: git push origin main --tags"
    else
        echo "  4. Push changes: git push origin main"
    fi
}

# Check if we're in the right directory
if [ ! -f "$PROJECT_FILE" ]; then
    print_error "Project file not found. Please run this script from the project root directory."
    exit 1
fi

# Run main function
main "$@" 