# 💊 MedBuddy — Smart Medicine Reminder App

<div align="center">

![MedBuddy Banner](https://img.shields.io/badge/MedBuddy-Medicine%20Reminder-3B6CF8?style=for-the-badge&logo=android&logoColor=white)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-5.0%2B-3DDC84?style=flat-square&logo=android&logoColor=white)](https://android.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**Never miss a dose again. Scan your prescription, set reminders, and track your medicine history — all in one beautiful app.**

[Features](#-features) • [Screenshots](#-screenshots) • [Setup on Mac](#-setup-on-mac) • [Setup on Windows](#-setup-on-windows) • [Tech Stack](#-tech-stack)

</div>

---

## ✨ Features

| Feature | Description |
|---|---|
| 📷 **OCR Prescription Scan** | Take a photo of your doctor's prescription — the app automatically reads medicine names, dosages, and timings |
| 🔔 **Real Alarm Notifications** | Get notified exactly when it's time to take your medicine, even when the app is closed |
| ✅ **Mark as Taken** | One tap to confirm you've taken your medicine directly from the notification |
| 📊 **History & Analytics** | 14-day adherence chart and day-by-day log to track your progress |
| ⏰ **Next Dose Countdown** | Always shows how long until your next medicine on the home screen |
| 🎨 **Color-coded Medicines** | Each medicine gets a unique color for easy identification |
| 💾 **100% Offline** | All data stored locally on your phone — no internet or account required |

---

## 📱 App Screens

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   TODAY TAB     │  │  MEDICINES TAB  │  │  HISTORY TAB    │
│                 │  │                 │  │                 │
│  Good Morning!  │  │  + Add Medicine │  │  Last 7 Days    │
│  Feb 28, 2026   │  │                 │  │  Adherence: 85% │
│                 │  │  💊 Paracetamol │  │                 │
│  Next: Parac..  │  │  500mg          │  │  ████████░░     │
│  In 15 min      │  │  8AM • 9PM      │  │                 │
│                 │  │                 │  │  Day-by-day log │
│  ──────────     │  │  💊 Amoxicillin │  │  ✅ Taken       │
│  8:00 AM Taken  │  │  250mg          │  │  ❌ Missed      │
│  2:00 PM [Take] │  │  8AM•2PM•8PM    │  │  ⏭ Skipped     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

---

## 🚀 Setup on Mac

### Prerequisites
- macOS (any version)
- Android phone with USB cable
- ~45 minutes

### Step 1 — Install Homebrew
Open Terminal (`⌘ + Space` → type Terminal → Enter):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
> It will ask for your Mac password — type it and press Enter (you won't see it as you type)

### Step 2 — Install Flutter & Java
```bash
brew install --cask flutter
brew install --cask temurin@17
```

### Step 3 — Install Android Studio
```bash
brew install --cask android-studio
```
After installing, open Android Studio:
- Click **More Actions → SDK Manager**
- Under **SDK Platforms** → check **Android 13.0 (API 33)**
- Under **SDK Tools** → check **Android SDK Build-Tools** + **Android SDK Command-line Tools**
- Click **Apply** and wait for download

### Step 4 — Accept Licenses
```bash
flutter doctor --android-licenses
```
Type `y` for every prompt.

### Step 5 — Clone the Project
```bash
git clone https://github.com/YOUR_USERNAME/medbuddy.git
cd medbuddy
```

### Step 6 — Add Fonts
- Download **Nunito** from [fonts.google.com/specimen/Nunito](https://fonts.google.com/specimen/Nunito)
- Create folders: `assets/fonts/` and `assets/animations/`
- Copy `Nunito-Regular.ttf`, `Nunito-Bold.ttf`, `Nunito-ExtraBold.ttf` into `assets/fonts/`

### Step 7 — Install Dependencies
```bash
flutter pub get
```

### Step 8 — Set Up Your Android Phone
1. **Settings → About Phone → tap Build Number 7 times** (enables Developer Mode)
2. **Settings → Developer Options → USB Debugging → ON**
3. Connect phone via USB → tap **Allow** on the popup

### Step 9 — Run the App
```bash
flutter run
```

### Step 10 — Build Release APK (to share with others)
```bash
# Generate signing key
keytool -genkey -v -keystore medbuddy.jks -keyalg RSA -keysize 2048 -validity 10000 \
  -alias medbuddy -storepass medbuddy123 -keypass medbuddy123 \
  -dname "CN=MedBuddy, O=MedBuddy, C=IN"

# Create key.properties
cat > android/key.properties << 'EOF'
storePassword=medbuddy123
keyPassword=medbuddy123
keyAlias=medbuddy
storeFile=../../medbuddy.jks
EOF

# Build
flutter build apk --release
```
APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🪟 Setup on Windows

### Prerequisites
- Windows 10 or 11
- Android phone with USB cable
- ~45 minutes

### Step 1 — Install Flutter
1. Download Flutter SDK from [flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows)
2. Extract the zip to `C:\flutter`
3. Add Flutter to PATH:
   - Search **"Environment Variables"** in Start Menu
   - Click **Environment Variables**
   - Under **User Variables** → select **Path** → click **Edit**
   - Click **New** → type `C:\flutter\bin`
   - Click OK on all windows
4. Open a **new** Command Prompt and verify:
```cmd
flutter --version
```

### Step 2 — Install Java
1. Download **Eclipse Temurin 17** from [adoptium.net](https://adoptium.net)
2. Run the installer — make sure to check **"Set JAVA_HOME"** during install
3. Verify:
```cmd
java --version
```

### Step 3 — Install Android Studio
1. Download from [developer.android.com/studio](https://developer.android.com/studio)
2. Run the installer with default settings
3. Open Android Studio:
   - Click **More Actions → SDK Manager**
   - Under **SDK Platforms** → check **Android 13.0 (API 33)**
   - Under **SDK Tools** → check **Android SDK Build-Tools** + **Android SDK Command-line Tools**
   - Click **Apply**
4. Add Android SDK to PATH:
   - Add `C:\Users\YOUR_NAME\AppData\Local\Android\Sdk\platform-tools` to PATH (same steps as Flutter)

### Step 4 — Accept Licenses
Open Command Prompt and run:
```cmd
flutter doctor --android-licenses
```
Type `y` for every prompt.

### Step 5 — Clone the Project
```cmd
git clone https://github.com/YOUR_USERNAME/medbuddy.git
cd medbuddy
```

### Step 6 — Add Fonts
- Download **Nunito** from [fonts.google.com/specimen/Nunito](https://fonts.google.com/specimen/Nunito)
- Create folders `assets\fonts\` and `assets\animations\` inside the project
- Copy `Nunito-Regular.ttf`, `Nunito-Bold.ttf`, `Nunito-ExtraBold.ttf` into `assets\fonts\`

### Step 7 — Install Dependencies
```cmd
flutter pub get
```

### Step 8 — Set Up Your Android Phone
1. **Settings → About Phone → tap Build Number 7 times**
2. **Settings → Developer Options → USB Debugging → ON**
3. Connect phone via USB → tap **Allow** on popup
4. Verify phone is detected:
```cmd
flutter devices
```

### Step 9 — Run the App
```cmd
flutter run
```

### Step 10 — Build Release APK
```cmd
keytool -genkey -v -keystore medbuddy.jks -keyalg RSA -keysize 2048 -validity 10000 -alias medbuddy -storepass medbuddy123 -keypass medbuddy123 -dname "CN=MedBuddy, O=MedBuddy, C=IN"
flutter build apk --release
```

---

## 🔧 Troubleshooting

| Problem | Fix |
|---|---|
| `flutter: command not found` | Close and reopen Terminal/Command Prompt |
| Phone not detected | Check USB Debugging is ON, try a different cable |
| `flutter pub get` fails | Run `flutter upgrade` then retry |
| App stuck on logo | Go to phone Settings → Apps → MedBuddy → Battery → Unrestricted |
| Notifications not showing | Settings → Apps → Special Access → Alarms & Reminders → Allow MedBuddy |
| Build fails with font error | Make sure 3 .ttf files are in `assets/fonts/` |

---

## 🛠 Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform mobile framework |
| **Dart** | Programming language |
| **Hive** | Local database (offline storage) |
| **Awesome Notifications** | Alarm-grade notifications on Android |
| **Google ML Kit** | On-device OCR for prescription scanning |
| **FL Chart** | Adherence charts and analytics |
| **Image Picker** | Camera and gallery access |

---

## 📁 Project Structure

```
medbuddy/
├── lib/
│   ├── main.dart                     # App entry point
│   ├── app_theme.dart                # Colors, fonts, theme
│   ├── models/
│   │   ├── medicine.dart             # Data models
│   │   └── medicine.g.dart           # Hive adapters
│   ├── services/
│   │   ├── notification_service.dart # Alarm scheduling
│   │   ├── medicine_service.dart     # Data management
│   │   └── ocr_service.dart          # Prescription scanning
│   ├── screens/
│   │   ├── today_screen.dart         # Home/Today tab
│   │   ├── medicines_screen.dart     # Medicine list
│   │   ├── add_medicine_screen.dart  # Add/edit medicine
│   │   ├── scan_prescription_screen.dart
│   │   └── history_screen.dart       # Analytics
│   └── widgets/
│       ├── medicine_card.dart
│       └── medicine_log_card.dart
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml       # Android permissions
├── assets/
│   ├── fonts/                        # Nunito font files
│   └── animations/
└── pubspec.yaml                      # Dependencies
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first.

---

## 📄 License

This project is licensed under the MIT License.

---

<div align="center">
Made with ❤️ using Flutter
</div>
