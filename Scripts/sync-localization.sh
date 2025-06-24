#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}📍 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# File paths
EN_FILE="HomeBrewAssistant/Resources/en.lproj/Localizable.strings"
NL_FILE="HomeBrewAssistant/Resources/nl.lproj/Localizable.strings"

print_header "🌍 Localization Synchronization Tool"

if [ ! -f "$EN_FILE" ]; then
    print_error "English localization file not found: $EN_FILE"
    exit 1
fi

if [ ! -f "$NL_FILE" ]; then
    print_error "Dutch localization file not found: $NL_FILE"
    exit 1
fi

# Count current strings
EN_COUNT=$(grep -c '^".*" = ' "$EN_FILE")
NL_COUNT=$(grep -c '^".*" = ' "$NL_FILE")

print_header "Current Status:"
echo "📊 English strings: $EN_COUNT"
echo "📊 Dutch strings: $NL_COUNT"
echo "📊 Difference: $((NL_COUNT - EN_COUNT))"

# Extract keys
print_header "Extracting localization keys..."

# Create temp files
EN_KEYS="/tmp/en_keys.txt"
NL_KEYS="/tmp/nl_keys.txt"

grep '^".*" = ' "$EN_FILE" | cut -d'"' -f2 | sort > "$EN_KEYS"
grep '^".*" = ' "$NL_FILE" | cut -d'"' -f2 | sort > "$NL_KEYS"

# Find differences
MISSING_IN_EN="/tmp/missing_in_en.txt"
MISSING_IN_NL="/tmp/missing_in_nl.txt"

comm -23 "$NL_KEYS" "$EN_KEYS" > "$MISSING_IN_EN"
comm -13 "$NL_KEYS" "$EN_KEYS" > "$MISSING_IN_NL"

MISSING_EN_COUNT=$(wc -l < "$MISSING_IN_EN")
MISSING_NL_COUNT=$(wc -l < "$MISSING_IN_NL")

print_header "Analysis Results:"
echo "🔍 Keys missing in English: $MISSING_EN_COUNT"
echo "🔍 Keys missing in Dutch: $MISSING_NL_COUNT"

if [ $MISSING_EN_COUNT -gt 0 ]; then
    print_warning "Keys missing in English localization:"
    head -10 "$MISSING_IN_EN" | while read key; do
        echo "  - $key"
    done
    
    if [ $MISSING_EN_COUNT -gt 10 ]; then
        echo "  ... and $((MISSING_EN_COUNT - 10)) more"
    fi
fi

if [ $MISSING_NL_COUNT -gt 0 ]; then
    print_warning "Keys missing in Dutch localization:"
    head -10 "$MISSING_IN_NL" | while read key; do
        echo "  - $key"
    done
    
    if [ $MISSING_NL_COUNT -gt 10 ]; then
        echo "  ... and $((MISSING_NL_COUNT - 10)) more"
    fi
fi

# Backup original files
print_header "Creating backups..."
cp "$EN_FILE" "${EN_FILE}.backup"
cp "$NL_FILE" "${NL_FILE}.backup"
print_success "Backup files created"

# Function to add missing keys from one file to another
add_missing_keys() {
    local source_file=$1
    local target_file=$2
    local missing_keys_file=$3
    local language=$4
    
    if [ ! -s "$missing_keys_file" ]; then
        return 0
    fi
    
    print_header "Adding missing keys to $language..."
    
    # Add header for missing keys
    echo "" >> "$target_file"
    echo "// MARK: - Auto-synchronized keys ($(date +%Y-%m-%d))" >> "$target_file"
    
    local added_count=0
    while read -r key; do
        if [ -n "$key" ]; then
            # Find the line with this key in source file
            local source_line=$(grep "^\"$key\" = " "$source_file")
            if [ -n "$source_line" ]; then
                echo "$source_line" >> "$target_file"
                ((added_count++))
            fi
        fi
    done < "$missing_keys_file"
    
    print_success "Added $added_count keys to $language localization"
    return $added_count
}

# Add missing keys to English
if [ $MISSING_EN_COUNT -gt 0 ]; then
    add_missing_keys "$NL_FILE" "$EN_FILE" "$MISSING_IN_EN" "English"
fi

# Add missing keys to Dutch  
if [ $MISSING_NL_COUNT -gt 0 ]; then
    add_missing_keys "$EN_FILE" "$NL_FILE" "$MISSING_IN_NL" "Dutch"
fi

# Recount after synchronization
NEW_EN_COUNT=$(grep -c '^".*" = ' "$EN_FILE")
NEW_NL_COUNT=$(grep -c '^".*" = ' "$NL_FILE")

print_header "📊 Synchronization Results:"
echo "English: $EN_COUNT → $NEW_EN_COUNT (+$((NEW_EN_COUNT - EN_COUNT)))"
echo "Dutch: $NL_COUNT → $NEW_NL_COUNT (+$((NEW_NL_COUNT - NL_COUNT)))"

if [ $NEW_EN_COUNT -eq $NEW_NL_COUNT ]; then
    print_success "🎉 Perfect sync! Both languages have $NEW_EN_COUNT strings"
else
    print_warning "Sync incomplete. Difference: $((NEW_NL_COUNT - NEW_EN_COUNT)) strings"
fi

# Clean up temp files
rm -f "$EN_KEYS" "$NL_KEYS" "$MISSING_IN_EN" "$MISSING_IN_NL"

print_success "Localization synchronization complete!"
echo ""
echo "📋 Next steps:"
echo "1. Review the added translations"
echo "2. Update any placeholder/auto-generated translations"
echo "3. Test the app in both languages"
echo "4. Commit the changes" 