#!/bin/bash

# 🎯 HomeBrewAssistant Test Target Setup Script
# This script creates test targets in the Xcode project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}🎯 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

PROJECT_NAME="HomeBrewAssistant"
PROJECT_FILE="${PROJECT_NAME}.xcodeproj"

print_header "Setting up Test Targets for ${PROJECT_NAME}"

# Check if project exists
if [ ! -d "$PROJECT_FILE" ]; then
    print_error "Project file not found: $PROJECT_FILE"
    exit 1
fi

print_info "Found project: $PROJECT_FILE"

# Create Info.plist files for test targets
print_info "Creating Info.plist files for test targets..."

# Unit Tests Info.plist
cat > HomeBrewAssistantTests/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>BNDL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
</dict>
</plist>
EOF

# UI Tests Info.plist
cat > HomeBrewAssistantUITests/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>BNDL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
</dict>
</plist>
EOF

print_success "Created Info.plist files"

print_info "Manual steps required in Xcode:"
echo ""
echo "1. Open ${PROJECT_NAME}.xcodeproj in Xcode"
echo "2. In Project Navigator, right-click on the project root"
echo "3. Select 'Add Files to \"${PROJECT_NAME}\"'"
echo "4. Add the following directories:"
echo "   - HomeBrewAssistantTests/"
echo "   - HomeBrewAssistantUITests/"
echo ""
echo "5. For each test directory, when prompted:"
echo "   - Create groups (not folder references)"
echo "   - Add to the appropriate test target"
echo ""
echo "OR use this automated approach:"
echo ""

print_header "Automated Test Target Creation"

# Create a simple Xcode project modification approach
print_info "Attempting to create test targets automatically..."

# We'll use ruby to parse and modify the project.pbxproj file
cat > setup_test_targets.rb << 'EOF'
#!/usr/bin/env ruby

require 'fileutils'

project_file = 'HomeBrewAssistant.xcodeproj/project.pbxproj'

if !File.exist?(project_file)
  puts "❌ Project file not found"
  exit 1
end

content = File.read(project_file)

# Generate UUIDs for test targets
def generate_uuid
  # Simple UUID generation for Xcode
  chars = ('A'..'F').to_a + ('0'..'9').to_a
  (0...24).map { chars.sample }.join
end

unit_test_target_uuid = generate_uuid
ui_test_target_uuid = generate_uuid
unit_test_product_uuid = generate_uuid
ui_test_product_uuid = generate_uuid

puts "🎯 Adding test targets to Xcode project..."

# Find the products group
products_section = content[/87BFD35A2DF75A9A005950ED \/\* Products \*\/ = \{[^}]+\}/]
if products_section
  new_products = products_section.gsub(
    /children = \(\s*87BFD3592DF75A9A005950ED \/\* HomeBrewAssistant\.app \*\/,\s*\);/,
    "children = (\n\t\t\t\t87BFD3592DF75A9A005950ED /* HomeBrewAssistant.app */,\n\t\t\t\t#{unit_test_product_uuid} /* HomeBrewAssistantTests.xctest */,\n\t\t\t\t#{ui_test_product_uuid} /* HomeBrewAssistantUITests.xctest */,\n\t\t\t);"
  )
  content = content.gsub(products_section, new_products)
  puts "✅ Updated Products group"
end

# Add to targets array
targets_section = content[/targets = \([^)]+\);/]
if targets_section
  new_targets = targets_section.gsub(
    /targets = \(\s*87BFD3582DF75A9A005950ED \/\* HomeBrewAssistant \*\/,\s*\);/,
    "targets = (\n\t\t\t\t87BFD3582DF75A9A005950ED /* HomeBrewAssistant */,\n\t\t\t\t#{unit_test_target_uuid} /* HomeBrewAssistantTests */,\n\t\t\t\t#{ui_test_target_uuid} /* HomeBrewAssistantUITests */,\n\t\t\t);"
  )
  content = content.gsub(targets_section, new_targets)
  puts "✅ Updated targets array"
end

# Add PBXFileReference for test products
file_references_end = content.index('/* End PBXFileReference section */')
if file_references_end
  new_refs = "\t\t#{unit_test_product_uuid} /* HomeBrewAssistantTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = HomeBrewAssistantTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };\n"
  new_refs += "\t\t#{ui_test_product_uuid} /* HomeBrewAssistantUITests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = HomeBrewAssistantUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };\n"
  
  content = content.insert(file_references_end, new_refs)
  puts "✅ Added file references"
end

# Add PBXNativeTarget sections
native_targets_end = content.index('/* End PBXNativeTarget section */')
if native_targets_end
  unit_test_target = <<~EOF
\t\t#{unit_test_target_uuid} /* HomeBrewAssistantTests */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = #{generate_uuid} /* Build configuration list for PBXNativeTarget "HomeBrewAssistantTests" */;
\t\t\tbuildPhases = (
\t\t\t\t#{generate_uuid} /* Sources */,
\t\t\t\t#{generate_uuid} /* Frameworks */,
\t\t\t\t#{generate_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t\t#{generate_uuid} /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = HomeBrewAssistantTests;
\t\t\tproductName = HomeBrewAssistantTests;
\t\t\tproductReference = #{unit_test_product_uuid} /* HomeBrewAssistantTests.xctest */;
\t\t\tproductType = "com.apple.product-type.bundle.unit-test";
\t\t};
  EOF

  ui_test_target = <<~EOF
\t\t#{ui_test_target_uuid} /* HomeBrewAssistantUITests */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = #{generate_uuid} /* Build configuration list for PBXNativeTarget "HomeBrewAssistantUITests" */;
\t\t\tbuildPhases = (
\t\t\t\t#{generate_uuid} /* Sources */,
\t\t\t\t#{generate_uuid} /* Frameworks */,
\t\t\t\t#{generate_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t\t#{generate_uuid} /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = HomeBrewAssistantUITests;
\t\t\tproductName = HomeBrewAssistantUITests;
\t\t\tproductReference = #{ui_test_product_uuid} /* HomeBrewAssistantUITests.xctest */;
\t\t\tproductType = "com.apple.product-type.bundle.ui-testing";
\t\t};
  EOF

  content = content.insert(native_targets_end, unit_test_target + ui_test_target)
  puts "✅ Added native targets"
end

# Write the modified content back
File.write(project_file, content)
puts "✅ Project file updated successfully!"
puts ""
puts "🎯 Next steps:"
puts "1. Open #{File.basename(Dir.pwd)}.xcodeproj in Xcode"
puts "2. Clean build folder (Cmd+Shift+K)"
puts "3. Run: ./Scripts/run-tests.sh validate"
puts "4. If validation passes, run: ./Scripts/run-tests.sh all"
EOF

# Run the Ruby script
print_info "Running automated project modification..."
if command -v ruby &> /dev/null; then
    ruby setup_test_targets.rb
    rm setup_test_targets.rb
    print_success "Automated setup completed!"
else
    print_error "Ruby not found. Please follow manual steps above."
    rm setup_test_targets.rb
fi

print_header "Setup Complete!"
print_info "Test your setup with: ./Scripts/run-tests.sh validate" 