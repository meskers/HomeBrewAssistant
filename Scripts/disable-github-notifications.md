# 📧 GitHub Email Notifications Uitschakelen

## 🛑 **Stop GitHub Actions Failure Emails**

### **Methode 1: Via GitHub Website**

1. **Ga naar je GitHub Settings**:
   - Klik op je profielfoto (rechtsboven)
   - Klik op **"Settings"**

2. **Notifications aanpassen**:
   - Klik op **"Notifications"** (links menu)
   - Scroll naar **"Actions"** sectie
   - ❌ Uncheck **"Email"** bij "Actions"
   - ✅ Optioneel: laat **"Web"** aangevinkt

3. **Per Repository**:
   - Ga naar: https://github.com/meskers/HomeBrewAssistant
   - Klik op **"Watch"** dropdown (rechtsboven)
   - Selecteer **"Custom"**
   - ❌ Uncheck **"Actions"**
   - ✅ Keep **"Issues"** en **"Pull requests"** aan

### **Methode 2: Workflow tijdelijk uitschakelen**

```bash
# Verplaats workflow naar disabled folder
mkdir -p .github/workflows-disabled
mv .github/workflows/ios-build.yml .github/workflows-disabled/

git add .
git commit -m "⏸️ Temporarily disable GitHub Actions"
git push
```

### **Methode 3: Email filter instellen**

**In je email client** (Gmail/Outlook):
- **Filter**: Van: `notifications@github.com`
- **Subject bevat**: `workflow run` OF `have failed`
- **Actie**: Verplaats naar map "GitHub Actions" of verwijder

### **Methode 4: Workflow alleen voor PR's**

```yaml
# In .github/workflows/ios-build.yml
on:
  pull_request:    # Alleen bij PR's
    branches: [ main, develop ]
  # push:          # COMMENTED OUT - geen builds bij elke push
  #   branches: [ main, develop ]
```

## ✅ **Recommended Aanpak**

1. **Nu**: Gebruik de simplified workflow (al gedaan)
2. **Later**: Fix de echte build issues
3. **Permanent**: Stel notifications in naar voorkeur

## 🔄 **Workflow weer inschakelen**

Als je later de full workflow weer wilt:
```bash
# Copy van disabled back to active
cp .github/workflows/disabled-ios-build.yml.disabled .github/workflows/ios-build.yml
git add .
git commit -m "✅ Re-enable GitHub Actions"
git push
```

---

**Result: Geen meer failure emails! 📧❌** 