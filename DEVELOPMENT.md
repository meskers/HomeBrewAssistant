# 🛠️ HomeBrewAssistant Development Guide

Complete gids voor het ontwikkelen van de HomeBrewAssistant iOS app.

## 📋 **Quick Start**

### **Daily Development Workflow**
```bash
# Start je dag met een health check
./Scripts/daily-development.sh

# Werk aan een feature
git checkout -b feature/nieuwe-feature
# ... maak wijzigingen ...
git add .
git commit -m "✨ Add nieuwe feature"
git push -u origin feature/nieuwe-feature

# Maak Pull Request op GitHub
# Na review: merge via GitHub UI
```

### **Release Workflow**
```bash
# Wanneer klaar voor release
git checkout develop  # of main
./Scripts/create-release.sh

# Volg de prompts voor versie type
# Script handelt automatisch af:
# - Version bump
# - Git tagging  
# - Branch management
# - Changelog generatie
```

## 🚀 **Automation Scripts**

### **Daily Development (`daily-development.sh`)**
Dagelijkse development health check:
- ✅ Git status controle
- ✅ Build test
- ✅ Unit tests
- ✅ TODO/FIXME scan
- ✅ Code formatting check
- ✅ Recent commits overzicht

**Usage:**
```bash
./Scripts/daily-development.sh
```

### **Release Creator (`create-release.sh`)**
Geautomatiseerde release creatie:
- 🏷️ Version bumping (patch/minor/major)
- 🏗️ Build verification
- 📝 Changelog generatie
- 🔖 Git tagging
- 🚀 GitHub release prep

**Usage:**
```bash
./Scripts/create-release.sh
```

### **Issues Generator (`create-development-issues.sh`)**
GitHub issues aanmaken op basis van roadmap:
- 📋 Roadmap tasks → GitHub Issues
- 🏷️ Automatische labels
- 📊 Priority assignment
- 🎯 Milestone tracking

**Usage:**
```bash
./Scripts/create-development-issues.sh
```
*Vereist: GitHub CLI (`gh`) geïnstalleerd en ingelogd*

### **Version Incrementer (`increment_version.sh`)**
Bestaand script voor version management:
- 📈 Automatic version bumping
- 📱 iOS project file updates
- 🔄 Build number management

## 📁 **Project Structure**

```
HomeBrewAssistant/
├── 📱 HomeBrewAssistant/          # Main app code
│   ├── 📁 Views/                  # SwiftUI views
│   ├── 📁 ViewModels/             # MVVM view models
│   ├── 📁 Models/                 # Data models
│   └── 📁 Resources/              # Assets, localizations
├── 📋 Scripts/                    # Automation scripts
├── 📄 Docs/                       # Documentation
├── 🧪 Tests/                      # Unit tests (todo)
└── 🔧 .github/                    # GitHub templates & workflows
```

## 🔄 **Branch Strategy**

### **Branch Types**
- `main` - Stable release branch
- `develop` - Active development
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Emergency fixes

### **Workflow**
```bash
# Nieuwe feature
git checkout develop
git checkout -b feature/mijn-feature
# ... development ...
git push -u origin feature/mijn-feature
# Create PR to develop

# Bug fix
git checkout -b bugfix/fix-probleem
# ... fix ...
# Create PR to develop

# Hotfix (emergency)
git checkout main
git checkout -b hotfix/critical-fix
# ... fix ...
# Create PR to main
```

## 📊 **GitHub Integration**

### **Issue Templates**
- 🐛 Bug Report (`bug_report.md`)
- ✨ Feature Request (`feature_request.md`)

### **Pull Request Template**
- 📝 Standardized PR format
- ✅ Checklist voor reviews
- 📱 Testing requirements

### **GitHub Actions**
- 🔨 Automatic builds on PR
- ✅ Test execution
- 📊 Code quality checks

### **Labels & Milestones**
- `bug` - Bug fixes
- `enhancement` - New features
- `v1.1`, `v1.2` - Version milestones
- `high-priority` - Urgent items

## 🧪 **Testing Strategy**

### **Current Status**
- Unit tests: 📋 Todo
- UI tests: 📋 Todo  
- Integration tests: 📋 Todo

### **Planned Testing**
```bash
# Unit tests for models
XCTest framework voor Core Data models
ViewModels testing
Calculation logic testing

# UI tests  
SwiftUI view testing
Navigation flow testing
User interaction testing
```

## 📈 **Performance Monitoring**

### **Key Metrics**
- App launch time: Target <2s
- Memory usage: Target <100MB
- Crash rate: Target <0.1%
- Build time: Target <30s

### **Tools**
- Xcode Instruments
- Crash reporting (toekomst)
- Performance analytics (toekomst)

## 🔧 **Development Tools**

### **Required Tools**
- Xcode 15.0+
- Git
- GitHub CLI (`gh`) - voor issues automation

### **Recommended Tools**
- SwiftLint - code style
- SwiftFormat - code formatting
- Charles Proxy - network debugging

### **Installation**
```bash
# GitHub CLI
brew install gh
gh auth login

# SwiftLint (future)
brew install swiftlint

# SwiftFormat (future)  
brew install swiftformat
```

## 🎯 **Development Goals**

### **Short Term (v1.1)**
- [ ] Fix all critical bugs
- [ ] Improve app stability
- [ ] Polish UI/UX
- [ ] Add unit tests

### **Medium Term (v1.2-v2.0)**
- [ ] Advanced features
- [ ] Cloud synchronization
- [ ] AI enhancements
- [ ] Performance optimization

### **Long Term (v2.1+)**
- [ ] Professional tools
- [ ] Hardware integration
- [ ] Commercial features
- [ ] API development

## 📞 **Support & Communication**

### **Development Questions**
- GitHub Issues voor bugs
- GitHub Discussions voor algemene vragen
- PR comments voor code reviews

### **Community**
- Open source contributions welcome
- Following brewing community feedback
- Regular development updates

---

## 🚀 **Next Steps**

1. **Run daily script**: `./Scripts/daily-development.sh`
2. **Check GitHub Issues**: Review roadmap items
3. **Pick a task**: Start with v1.1 bugs
4. **Create branch**: Follow branch strategy
5. **Develop & test**: Use automation tools
6. **Create PR**: Use PR template
7. **Release**: Use release script

**Happy brewing and coding! 🍺**

---

*Last updated: December 2024* 