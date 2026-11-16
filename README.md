# 🚆 RailTrack BD — Bangladesh Railway Live Train Tracker (Flutter Android)

A real-time train tracking Android mobile application built with **Flutter** and **Material Design 3**, featuring live route mapping, analog/digital speedometer, journey progress milestones, destination proximity alarms, bilingual Bangla/English localization, and an Admin telemetry console.

---

## 💻 Complete Setup Guide for Windows 10 & VS Code (Flutter 3.44.2)

### 1. Install Flutter on Windows 10
1. Download the Flutter Windows SDK ZIP (or **Flutter 3.44.2**) from [https://docs.flutter.dev/get-started/install/windows/mobile](https://docs.flutter.dev/get-started/install/windows/mobile).
2. Extract it to `C:\src\flutter` (avoid paths with spaces or `C:\Program Files`).
3. Add `C:\src\flutter\bin` to your Windows **User PATH** environment variable, or run in PowerShell:
   ```powershell
   $oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
   [Environment]::SetEnvironmentVariable("Path", "$oldPath;C:\src\flutter\bin", "User")
   ```
4. Open a **new** PowerShell window and verify:
   ```powershell
   flutter --version
   ```

### 2. Install Android Studio & Android SDK
1. Download and install **Android Studio** from [https://developer.android.com/studio](https://developer.android.com/studio).
2. Open Android Studio → **More Actions** (or **Settings**) → **SDK Manager**.
3. Under **SDK Platforms**, install **Android 14 / 15 (API 34 or API 35)**.
4. Under **SDK Tools**, check and install:
   - **Android SDK Build-Tools**
   - **Android SDK Command-line Tools (latest)**
   - **Android SDK Platform-Tools**

### 3. Configure Flutter Android SDK & Licenses
Run these PowerShell commands:
```powershell
flutter doctor
flutter doctor --android-licenses
```
Press `y` to accept all Android SDK licenses. Re-run `flutter doctor` to verify both **Flutter** and **Android toolchain** show green checkmarks `[✓]`.

### 4. Open the Project in Visual Studio Code
1. Launch **Visual Studio Code**.
2. Install the **Flutter** and **Dart** extensions from the Extensions view (`Ctrl + Shift + X`).
3. Click **File → Open Folder...** and select the extracted `flutter_railtrack_bd` folder (the folder containing `pubspec.yaml`).

### 5. Install Dependencies
Open the VS Code PowerShell terminal (`Ctrl + `` `) in the `flutter_railtrack_bd` project root and run:
```powershell
flutter clean
flutter pub get
flutter analyze
```

### 6. Connect Your Physical Android Phone & 7. Enable USB Debugging
1. On your Android phone, open **Settings → About phone**.
2. Tap **Build number** 7 times until *"You are now a developer!"* appears.
3. Go to **Settings → System → Developer options** (on Xiaomi/MIUI: **Additional settings → Developer options**; enable **USB debugging (Security settings)** if prompted).
4. Turn on **USB debugging**.
5. Connect your phone to your Windows 10 PC using a data-capable USB cable.
6. Tap **Allow** on the *"Allow USB debugging?"* popup on your phone (check *Always allow from this computer*).

### 8. Check Connected Devices
In PowerShell inside the `flutter_railtrack_bd` directory:
```powershell
flutter devices
```
Verify your physical Android device appears (for example: `SM-G998B (mobile) • ... • android-arm64 • Android 14`).

### 9. Run the Application on Your Phone
```powershell
flutter run
```
Or press **`F5`** in VS Code after selecting your phone in the bottom-right status bar.

### 10. Generate a Debug APK
To build an installable Android Debug APK for manual transfer/testing:
```powershell
flutter build apk --debug
```
The generated APK will be at:
`build\app\outputs\flutter-apk\app-debug.apk`

### 11. Troubleshooting Common Errors
- **`flutter` is not recognized in PowerShell**: Ensure `C:\src\flutter\bin` is in your User `PATH`, then restart VS Code / PowerShell.
- **Device not detected by `flutter devices`**: Try another USB port/cable, set USB mode on your phone to **File Transfer (MTP)**, or install your phone manufacturer's Windows USB driver (or Google USB Driver via Android Studio SDK Manager). Run `adb devices` to confirm detection.
- **Gradle / `local.properties` error**: Run `flutter pub get` from the project root so Flutter regenerates `android\local.properties` with your Windows `flutter.sdk` and `sdk.dir` paths.
- **Missing Gradle wrapper binaries**: If `android\gradlew.bat` reports an error on a fresh setup, run once from the project root:
  ```powershell
  flutter create --platforms=android .
  ```
  (Keep existing `AndroidManifest.xml` permissions and `MainActivity.kt`.)
- **SDK / License warnings**: Re-run `flutter doctor --android-licenses` and ensure **Android SDK Command-line Tools** is installed in Android Studio.

---

## 🌟 Comprehensive 30-Feature Matrix

| # | Feature | Implementation Detail |
|---|---------|-----------------------|
| 1 | **Flutter Mobile Application** | Clean MVVM architecture with Provider state management & full Android runner configs. |
| 2 | **Professional Train Tracking UI** | Material 3 emerald green & deep slate navy theme designed for railway operations. |
| 3 | **Train Search** | Search by train name (English/Bangla), train number (e.g., #701, #787), or destination. |
| 4 | **Train Database** | Database of intercity, express, and commuter trains (Suborno, Sonar Bangla, Parabat, Padma, etc.). |
| 5 | **Station Database** | Geospatial station database (Kamalapur, Airport, Tongi, Bhairab, Feni, Chittagong, Sylhet, etc.). |
| 6 | **Railway Route Database** | Polyline geometries of major lines (Dhaka–Chittagong, Dhaka–Sylhet, Dhaka–Rajshahi). |
| 7 | **MapLibre-style Map Engine** | Interactive vector canvas map supporting pinch-to-zoom, pan, standard & satellite modes. |
| 8 | **Train Marker** | Directional bearing arrow, real-time speed badge, and pulsing radar halo. |
| 9 | **Station Markers** | Golden node beacons with interactive halos and station labels. |
| 10 | **Route Visualization** | Dual-track ballast bed with illuminated emerald active segments. |
| 11 | **GPS Simulation Engine** | Real-time train physics simulation with Play/Pause and speed multiplier (1x, 2x, 5x). |
| 12 | **Distance Calculation** | Spherical Haversine distance formula with sub-kilometer precision. |
| 13 | **Speed Calculation** | Dynamic train cruising velocity (km/h) with analog & digital speedometer. |
| 14 | **Next Station Calculation** | Dynamic nearest station identification along the railway corridor. |
| 15 | **ETA Calculation** | Time-to-destination arrival calculation based on remaining distance and velocity. |
| 16 | **Delay Calculation** | Scheduled timetable vs actual arrival time comparison (+mins late badge). |
| 17 | **Journey Progress** | Station-by-station journey milestone bar and percentage completion indicator. |
| 18 | **WebSocket Real-Time Updates** | Telemetry socket client with heartbeat and broadcast stream. |
| 19 | **Favorite Trains** | Persistent favorites storage with quick access dashboard. |
| 20 | **Train Alerts** | Station proximity alarms (configure directly from Live Tracking or Destination Alarm screen). |
| 21 | **Notification Service** | Local proximity trigger evaluator with single-trigger and reset support. |
| 22 | **Bangla / English Localization** | Seamless bilingual toggle (বাংলা / English) across all screens. |
| 23 | **Dark & Light Theme** | Persisted theme preference with high-contrast emerald dark UI. |
| 24 | **User Authentication** | Passenger mode and Railway Admin Dispatcher mode. |
| 25 | **Admin Dashboard** | Dispatch console with system telemetry, signal logs, and broadcast trigger. |
| 26 | **PostgreSQL + PostGIS** | Spatial database schema (`backend/schema.sql`) with GiST indexes & proximity triggers. |
| 27 | **Redis Integration** | Geospatial indexing (`GEOADD`/`GEORADIUS`) & pub/sub cache (`backend/redis_service.py`). |
| 28 | **REST API** | FastAPI telemetry specification (`backend/server.py`). |
| 29 | **GPS Validation** | Outlier detection, speed violation threshold (>125 km/h), and geofence checks. |
| 30 | **Status Indicators** | **`LIVE GPS`**, **`DEMO SIMULATION`**, **`STALE SIGNAL`**, **`OFFLINE`**. |

---

## 🧪 Note on Demo Mode & Backend Assets
The `backend/` folder contains the FastAPI/PostGIS/Redis reference server (`server.py`, `schema.sql`, `redis_service.py`). When no live backend server is reachable, the mobile app runs cleanly offline in **Demo Simulation Mode** using bundled Bangladesh Railway route geometry and local `SharedPreferences` storage.
