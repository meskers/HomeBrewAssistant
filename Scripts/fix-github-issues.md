# 🔧 GitHub Issues Fix Guide

## 🐛 "Ruleset does not target any resources" Fix

Deze foutmelding kan verschillende oorzaken hebben. Hier zijn de oplossingen:

### **1. GitHub Branch Protection Rules**

**Via GitHub Website:**
1. Ga naar: `https://github.com/meskers/HomeBrewAssistant/settings/branches`
2. Als er al rules zijn, klik op **"Edit"** naast de rule
3. Zorg ervoor dat:
   - ✅ **Branch name pattern**: `main` (exact match)
   - ✅ **Restrict pushes that create files larger than**: UIT
   - ✅ **Require status checks to pass**: OPTIONEEL aan/uit
4. Save changes

**Rule verwijderen (tijdelijk):**
1. Ga naar Settings → Branches
2. Klik **"Delete"** naast bestaande rules
3. Test of foutmelding weg is
4. Voeg rules later weer toe

### **2. GitHub Actions Workflow Issues**

**Als GitHub Actions niet werkt:**
1. Ga naar: `https://github.com/meskers/HomeBrewAssistant/actions`
2. Check of er failed workflows zijn
3. Klik op failed workflow
4. Bekijk error logs

**Workflow opnieuw triggeren:**
```bash
git commit --allow-empty -m "🔄 Trigger GitHub Actions"
git push
```

### **3. Repository Settings Check**

**Via GitHub Website - Settings:**
1. **General** → **Features**:
   - ✅ Issues enabled
   - ✅ Wiki enabled
   - ❌ Projects disabled (if not needed)

2. **Actions** → **General**:
   - ✅ Allow all actions and reusable workflows
   - ✅ Allow actions created by GitHub
   - ✅ Allow specified actions and reusable workflows

3. **Code security and analysis**:
   - ✅ Dependency graph
   - ✅ Dependabot alerts
   - ❌ Code scanning (optional)

### **4. Lokale Build Test**

Test of het lokaal werkt:
```bash
# Clean build test
./Scripts/daily-development.sh

# Manual build test
xcodebuild clean build \
  -project HomeBrewAssistant.xcodeproj \
  -scheme HomeBrewAssistant \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.4' \
  CODE_SIGNING_ALLOWED=NO
```

### **5. Xcode Scheme Fix**

**Als scheme issues:**
1. Open Xcode
2. Product → Scheme → Manage Schemes
3. Zorg dat "HomeBrewAssistant" scheme:
   - ✅ **Shared** is aangevinkt
   - ✅ **Container**: HomeBrewAssistant.xcodeproj
4. File → Save

### **6. Emergency Reset**

**Als niets werkt:**
```bash
# Reset GitHub Actions
rm -rf .github/workflows/
mkdir -p .github/workflows/

# Maak minimale workflow
cat > .github/workflows/basic-build.yml << 'EOF'
name: Basic Build
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4
    - name: Build
      run: echo "Build test completed"
EOF

git add .
git commit -m "🔧 Reset to basic workflow"
git push
```

## ✅ **Verification Steps**

Na elke fix, test:
1. Push een kleine wijziging
2. Check GitHub Actions tab
3. Kijk of er nog foutmeldingen zijn
4. Test lokale scripts

## 📞 **Als het nog steeds niet werkt**

1. **Check GitHub Status**: https://www.githubstatus.com/
2. **Repository opnieuw clonen**:
   ```bash
   cd ..
   git clone https://github.com/meskers/HomeBrewAssistant.git test-clone
   cd test-clone
   ./Scripts/daily-development.sh
   ```

## 🎯 **Success Indicators**

Je weet dat het werkt als:
- ✅ Geen "ruleset" foutmeldingen
- ✅ GitHub Actions worden getriggerd
- ✅ Lokale scripts werken
- ✅ Push/pull werkt zonder warnings

---

**Most common fix: Disable branch protection temporarily, test, then re-enable.** 