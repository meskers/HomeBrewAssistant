# HomeBrewAssistant Version Management System

Dit document beschrijft het versiesysteem van HomeBrewAssistant en hoe je het gebruikt voor het beheren van app-versies.

## 📋 Overzicht

Het versiesysteem bestaat uit:
- **VersionManager.swift** - Centraal versie management systeem
- **VersionHistoryView.swift** - UI voor versiegeschiedenis
- **increment_version.sh** - Automatisch versie-increment script
- **Semantic Versioning** - Volgt SemVer standaarden

## 🚀 Gebruik van het Versiesysteem

### Automatische Versie Incrementen

Gebruik het `increment_version.sh` script om versies automatisch te verhogen:

```bash
# Patch versie verhogen (1.0.0 → 1.0.1)
./Scripts/increment_version.sh patch

# Minor versie verhogen (1.0.1 → 1.1.0)
./Scripts/increment_version.sh minor

# Major versie verhogen (1.1.0 → 2.0.0)
./Scripts/increment_version.sh major
```

### Script Opties

```bash
# Dry run - toon wat er zou gebeuren zonder wijzigingen
./Scripts/increment_version.sh patch --dry-run

# Geen git tag aanmaken
./Scripts/increment_version.sh minor --no-tag

# Help informatie
./Scripts/increment_version.sh --help
```

## 📝 Semantic Versioning

We volgen [Semantic Versioning](https://semver.org/) principes:

### **MAJOR** versie (X.0.0)
Gebruik voor:
- Breaking changes in de API
- Grote UI redesigns
- Fundamentele architectuur wijzigingen
- Incompatibele wijzigingen

**Voorbeelden:**
- Complete app redesign
- Nieuwe tab structuur (zoals recent geïmplementeerd)
- Database schema wijzigingen die migratie vereisen

### **MINOR** versie (X.Y.0)
Gebruik voor:
- Nieuwe features
- Nieuwe calculators
- Nieuwe views/screens
- Backwards compatible wijzigingen

**Voorbeelden:**
- Nieuwe AI Recipe Generator
- Nieuwe calculator toevoegen
- Photo Gallery functionaliteit
- BeerXML import/export

### **PATCH** versie (X.Y.Z)
Gebruik voor:
- Bug fixes
- Performance verbeteringen
- Kleine UI tweaks
- Lokalisatie updates

**Voorbeelden:**
- SF Symbols fouten oplossen
- Crash fixes
- Tekst correcties
- Performance optimalisaties

## 🔄 Workflow voor Nieuwe Releases

### 1. Bepaal Versie Type
```bash
# Analyseer je wijzigingen
git log --oneline v1.0.0..HEAD

# Bepaal of het major, minor, of patch is
```

### 2. Update Changelog
Bewerk `VersionManager.swift` en voeg nieuwe versie toe aan `getChangesForVersion()`:

```swift
case "1.1.0":
    return [
        "🎉 Nieuwe AI Recipe Generator",
        "📊 Verbeterde analytics dashboard",
        "🐛 Diverse bugfixes en verbeteringen"
    ]
```

### 3. Increment Versie
```bash
# Test eerst met dry-run
./Scripts/increment_version.sh minor --dry-run

# Voer uit als alles correct is
./Scripts/increment_version.sh minor
```

### 4. Test en Commit
```bash
# Test de app met nieuwe versie
xcodebuild -project HomeBrewAssistant.xcodeproj -scheme HomeBrewAssistant build

# Commit wijzigingen
git add .
git commit -m "Bump version to 1.1.0

- Added AI Recipe Generator
- Improved analytics dashboard
- Various bugfixes"

# Push met tags
git push origin main --tags
```

## 📱 In-App Versie Informatie

### VersionManager Features
- **Automatische versie detectie** van Bundle info
- **Changelog management** met lokale opslag
- **Versie vergelijking** utilities
- **Semantic versioning** ondersteuning

### VersionHistoryView Features
- **Mooie UI** voor versiegeschiedenis
- **Expandable cards** voor elke versie
- **Versie type indicators** (Major/Minor/Patch)
- **Changelog weergave** per versie

### Integratie in AboutView
- **Klikbare versie info** die versiegeschiedenis opent
- **Automatische nieuwe versie detectie**
- **Visuele indicators** voor versie types

## 🛠️ Technische Details

### Versie Opslag
- **Bundle Info** - Primaire bron voor huidige versie
- **UserDefaults** - Versiegeschiedenis en laatste bekende versie
- **JSON Encoding** - Changelog data persistentie

### Git Integratie
- **Automatische tags** - `v1.0.0-build123` formaat
- **Tag validatie** - Voorkomt duplicate tags
- **Git repository detectie** - Werkt alleen in git repos

### Xcode Project Updates
- **MARKETING_VERSION** - Gebruiker-zichtbare versie (1.0.0)
- **CURRENT_PROJECT_VERSION** - Build nummer (incrementeel)
- **Automatische updates** via sed commands

## 🎯 Best Practices

### 1. Consistente Changelog Updates
- Altijd changelog updaten vóór versie increment
- Gebruik emoji's voor visuele categorisatie
- Schrijf duidelijke, gebruiker-gerichte beschrijvingen

### 2. Testing Protocol
- Test altijd met `--dry-run` eerst
- Bouw en test app na versie increment
- Controleer versie info in AboutView

### 3. Git Workflow
- Maak feature branches voor grote wijzigingen
- Gebruik descriptive commit messages
- Tag releases voor belangrijke milestones

### 4. Release Notes
```
Format voor commit messages:
Bump version to X.Y.Z

- Feature 1 beschrijving
- Feature 2 beschrijving
- Bug fix beschrijving

Closes #issue-number
```

## 🔍 Troubleshooting

### Script Problemen
```bash
# Controleer of je in project root bent
ls HomeBrewAssistant.xcodeproj

# Maak script executable
chmod +x Scripts/increment_version.sh

# Controleer git status
git status
```

### Versie Sync Problemen
```bash
# Reset laatste bekende versie
defaults delete com.meskersonline.HomeBrewAssistant last_recorded_version

# Clear versie geschiedenis
defaults delete com.meskersonline.HomeBrewAssistant version_history
```

### Build Problemen
```bash
# Clean build folder
xcodebuild clean

# Rebuild project
xcodebuild -project HomeBrewAssistant.xcodeproj -scheme HomeBrewAssistant build
```

## 📚 Referenties

- [Semantic Versioning](https://semver.org/)
- [Apple App Store Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Git Tagging Best Practices](https://git-scm.com/book/en/v2/Git-Basics-Tagging)

---

**Gemaakt voor HomeBrewAssistant v1.0.0**  
*Laatste update: December 2024* 