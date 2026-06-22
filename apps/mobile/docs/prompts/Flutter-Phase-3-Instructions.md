# Flutter Application - Phase 3: Implementation & Integration
## Functional Instructions for Development (Based on Greek Requirements)

---

## 📋 PHASE 3 REQUIREMENTS OVERVIEW

This document converts Greek requirements into executable tasks for Flutter application development, incorporating LLMs and AR/VR elements from the provided guides.

---

## 🎯 PRIMARY OBJECTIVES

### 1. LAYOUT & NAVIGATION (Διάταξη & Πλοήγηση)

#### 1.1 Screen Layout Implementation
- [ ] **TASK: Design and implement screen layouts** following the prototype from Phase 2
  - **AGENT ACTION**: Create `.dart` files for each screen widget
  - **VERIFICATION**: Each screen renders without errors
  - **ACCEPTANCE**: All layouts match Phase 2 prototype visually

#### 1.2 Screen Navigation Implementation
- [ ] **TASK: Implement navigation between screens**
  - **METHOD A - Button-based navigation**:
    - [ ] Create `ElevatedButton` or `TextButton` widgets for screen transitions
    - [ ] Implement `Navigator.push()` or `Navigator.pushNamed()` for navigation
  - **METHOD B - Gesture-based navigation** (if more appropriate):
    - [ ] Implement `GestureDetector` with `onHorizontalDragEnd` for swipe navigation
    - [ ] Use `onTapDown` for custom gesture-based transitions
    - [ ] Implement `PageView` widget for swipeable screen transitions (if applicable)
  - **VERIFICATION**: 
    - All screen transitions work smoothly
    - No broken navigation paths exist
    - Back button correctly returns to previous screen

#### 1.3 Navigation Architecture
- [ ] **TASK: Choose navigation paradigm**
  - Option A: `Navigator` with `MaterialPageRoute` (simple apps)
  - Option B: `go_router` package (complex navigation hierarchies)
  - Option C: `GetX` (simplified state + navigation)
  - **RECORD**: Selected approach in README.md

---

## 📱 DATA & CONTENT MANAGEMENT (Κείμενο, Εικόνες, Δεδομένα)

### 2.1 Static Content Implementation
- [ ] **TASK: Implement dummy text and images**
  - [ ] Use `Text()` widget for all textual content
  - [ ] Use `Image.asset()` for local images or `Image.network()` for remote images
  - [ ] Reference: Laboratory workshop example for correct implementation
  - **VERIFICATION**: All content displays correctly on screen

### 2.2 StatefulWidget for Data Processing
- [ ] **TASK: Use `StatefulWidget` where data changes between screens**
  - [ ] Identify screens where data is modified/processed
  - [ ] Convert relevant widgets to `StatefulWidget`
  - [ ] Implement `setState()` to trigger UI rebuilds when data changes
  - [ ] Example use cases:
    - Task creation/editing screens
    - User profile modification
    - Settings/preferences changes
  - **VERIFICATION**: Data changes reflect immediately in UI

### 2.3 User Input Handling
- [ ] **TASK: Implement user input mechanisms**
  - **OPTION A - Using specialized widgets**:
    - [ ] `showTimePicker()` for time selection
    - [ ] `showDatePicker()` for date selection
    - [ ] `DropdownButton` for selection from lists
    - [ ] `Slider` for numeric value selection
  - **OPTION B - Using Forms**:
    - [ ] Create `Form` widget with `GlobalKey<FormState>`
    - [ ] Use `TextFormField` for text input with validation
    - [ ] Implement `validator` callbacks for input validation
    - [ ] Use `FormField` for custom input types
  - **VERIFICATION**: 
    - All inputs validate correctly
    - Error messages display for invalid input
    - Form submission works correctly

### 2.4 Data Persistence (Critical Requirement)
- [ ] **TASK: Implement local/remote database persistence**
  - **OBJECTIVE**: Data persists across screen transitions AND app sessions
  - **IMPLEMENTATION OPTIONS**:
    - **Option A - Local (SQLite/Hive)**:
      - [ ] Add `sqflite: ^2.x.x` or `hive: ^2.x.x` to `pubspec.yaml`
      - [ ] Create model classes with `toJson()` and `fromJson()` methods
      - [ ] Implement database service class for CRUD operations
      - [ ] Initialize database on app startup
      - [ ] Load persisted data on app launch
    - **Option B - Remote (Firebase)**:
      - [ ] Add `firebase_core: ^x.x.x` and `cloud_firestore: ^x.x.x` to `pubspec.yaml`
      - [ ] Initialize Firebase in `main.dart`
      - [ ] Implement Firestore data models with serialization
      - [ ] Use `StreamBuilder` or `FutureBuilder` for real-time data
      - [ ] Implement authentication for user-specific data
    - **Option C - REST API**:
      - [ ] Add `http: ^x.x.x` or `dio: ^x.x.x` to `pubspec.yaml`
      - [ ] Create API client service
      - [ ] Implement data sync on app launch
  - **VERIFICATION**:
    - Create new data on screen A
    - Navigate to screen B
    - Navigate back to screen A - data still exists
    - Close and reopen app - data persists
    - Data appears after login/authentication

### 2.5 Data Flow Between Screens
- [ ] **TASK: Implement data passing and modification across screens**
  - [ ] **REQUIREMENT**: Avoid simple non-functional screen switching
  - [ ] **IMPLEMENTATION**:
    - [ ] Pass data via constructor: `Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(data: selectedData)))`
    - [ ] Use state management for complex flows (Provider, GetX, Bloc, Riverpod)
    - [ ] Implement `onResult` pattern with `Navigator.pop(result: modifiedData)`
  - **VERIFICATION**:
    - Data modifications on detail screen reflect on list screen
    - Newly created items appear in lists without restart
    - Deleted items disappear from lists immediately

---

## 🔌 ANDROID SUBSYSTEMS INTEGRATION (Υποσυστήματα Android)

### 3.1 Camera Integration
- [ ] **TASK: Integrate camera functionality** (if specified in Phase 2 prototype)
  - [ ] Add `camera: ^x.x.x` to `pubspec.yaml`
  - [ ] Add permissions to `android/app/src/main/AndroidManifest.xml`:
    ```xml
    <uses-permission android:name="android.permission.CAMERA" />
    ```
  - [ ] Request runtime permissions using `permission_handler: ^x.x.x`
  - [ ] Implement camera preview widget
  - [ ] Implement photo capture and processing
  - **REFERENCE**: Laboratory workshop example
  - **VERIFICATION**: Camera opens, captures photos, and saves correctly

### 3.2 Audio Integration
- [ ] **TASK: Integrate audio functionality** (if specified)
  - [ ] Add `record: ^x.x.x` and `audioplayers: ^x.x.x` to `pubspec.yaml`
  - [ ] Add permissions:
    ```xml
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    ```
  - [ ] Implement audio recording functionality
  - [ ] Implement audio playback functionality
  - [ ] Handle permissions and error states
  - **VERIFICATION**: Audio records and plays correctly

### 3.3 Location Services
- [ ] **TASK: Integrate location services** (if applicable)
  - [ ] Add `geolocator: ^x.x.x` to `pubspec.yaml`
  - [ ] Add permissions:
    ```xml
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    ```
  - [ ] Request runtime permissions
  - [ ] Implement location retrieval
  - [ ] Handle location updates and errors
  - **VERIFICATION**: Location coordinates retrieved accurately

### 3.4 Optional: AR Integration
- [ ] **TASK: Integrate AR functionality** (if specified in Phase 2)
  - [ ] Add `ar_flutter_plugin_engine: ^1.0.0` to `pubspec.yaml`
  - [ ] Add permissions to `AndroidManifest.xml`:
    ```xml
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera.ar" />
    <uses-permission android:name="android.permission.INTERNET" />
    ```
  - [ ] Configure `android/app/build.gradle`:
    - Set `compileSdk = 36`
    - Set `ndkVersion = "27.3.13750724"`
    - Set `minSdkVersion 28`
    - Add `implementation 'com.google.ar:core:1.33.0'`
  - [ ] Implement AR object placement
  - [ ] Implement 3D model rendering
  - **REFERENCE**: Attached "Enhancing-your-Flutter-Application-with-AR_VR-Elements.pdf"
  - **VERIFICATION**: AR objects render and interact correctly

### 3.5 Optional: VR Integration
- [ ] **TASK: Integrate VR functionality** (if specified)
  - [ ] Add `vr_player: ^0.3.0` to `pubspec.yaml`
  - [ ] Add permissions:
    ```xml
    <uses-permission android:name="android.permission.INTERNET" />
    ```
  - [ ] Implement 360° video player
  - [ ] Support VR headset device motion controls
  - [ ] Test with VR gear if available
  - **REFERENCE**: Attached "Enhancing-your-Flutter-Application-with-AR_VR-Elements.pdf"
  - **VERIFICATION**: Videos play and respond to device motion

### 3.6 Optional: LLM Integration
- [ ] **TASK: Integrate LLM capabilities** (if specified)
  - [ ] Add `google_generative_ai: ^0.4.7` to `pubspec.yaml`
  - [ ] Create `api-keys.json` in project root:
    ```json
    {
      "GOOGLE_AI_KEY": "your_api_key_here"
    }
    ```
  - [ ] Create `.vscode/launch.json` with dart-define configuration
  - [ ] Obtain Google Gemini API key from https://aistudio.google.com/app/apikey
  - [ ] Implement LLM API calls for specific features (e.g., task generation)
  - [ ] Add error handling for API failures
  - [ ] Display processing indicators during API calls
  - **REFERENCE**: Attached "Incorporating-LLMS-into-your-Flutter-Application.pdf"
  - **VERIFICATION**: LLM features work and responses display correctly

---

## 📦 DELIVERABLES

### 4.1 Required Files
- [ ] **Application source files**
  - [ ] All `.dart` files in `lib/` directory
  - [ ] Configuration files (`pubspec.yaml`, `pubspec.lock`)
  - [ ] Android configuration files
  - [ ] Assets directory with images/data if used

- [ ] **ZIP Archive**
  - [ ] Create `flutter_app_phase3.zip` containing entire project
  - [ ] Exclude: `build/`, `.dart_tool/`, `.idea/`, `node_modules/`
  - [ ] Include: `lib/`, `android/`, `ios/`, `pubspec.yaml`, `README.md`

- [ ] **Release APK**
  - [ ] Build command: `flutter build apk --release`
  - [ ] File location: `build/app/outputs/flutter-apk/app-release.apk`
  - [ ] Ensure APK is debuggable on any Android device
  - [ ] Test installation on physical device or emulator

### 4.2 Documentation: README.md
Create comprehensive `README.md` with:

#### Section A: Installation & Usage Instructions
- [ ] **Clarity requirement**: Non-expert users must understand
- [ ] Step-by-step installation guide
- [ ] Prerequisite software list (Flutter version, Android SDK, etc.)
- [ ] If app requires setup (database config, API keys):
  - [ ] Keep instructions simple
  - [ ] Provide pre-configured examples
  - [ ] State if complex setup is unavoidable (disqualifies from non-expert use)
- [ ] Quick start guide for first-time users
- [ ] Main features overview

#### Section B: Technical Requirements
- [ ] Minimum/target Android SDK version
- [ ] Whether Google Play Services are required
- [ ] Supported emulator configurations
- [ ] Links to:
  - [ ] GitHub repository (if using version control)
  - [ ] APK download link (if cloud storage used)
  - [ ] Any external API endpoints or services

#### Section C: Deviations from Phase 2 (Optional)
- [ ] Document any changes from original prototype
- [ ] Explain reasons for architectural changes
- [ ] Note new features added

#### Section D: Video Demonstration (Optional but Recommended)
- [ ] Create 3-minute maximum screen recording
- [ ] Include audio narration explaining features
- [ ] Show all main workflows
- [ ] File format: MP4, WebM, or similar
- [ ] Upload to drive or embed link in README

#### Section E: Pre-testing Checklist (Must-Include)
```markdown
## Pre-evaluation Checklist

- [ ] All external services (Firebase, APIs) are active
- [ ] API keys are valid and have sufficient quota
- [ ] Database is initialized with sample data
- [ ] Test user account exists (if authentication required)
- [ ] All URLs in code are valid (no dead links)
- [ ] Services guaranteed available until: [DATE]
```

---

## ✅ IMPLEMENTATION CHECKLIST

### Code Quality Standards
- [ ] No unused imports or variables
- [ ] Consistent naming conventions (camelCase for variables, PascalCase for classes)
- [ ] Comments for complex logic
- [ ] Error handling for all user inputs
- [ ] No hardcoded sensitive data (API keys, passwords)
- [ ] Use of `.env` files or secure configuration for secrets

### Testing Checklist
- [ ] [Test on physical device OR emulator with Google APIs]
- [ ] [Test all navigation paths]
- [ ] [Test all user input fields]
- [ ] [Verify data persistence after app restart]
- [ ] [Test with poor network conditions if using remote APIs]
- [ ] [Test with runtime permissions (grant/deny scenarios)]
- [ ] [Verify AR/VR features on supported devices]
- [ ] [Test LLM API calls with different inputs]

### Build & Release Checklist
- [ ] [Run `flutter clean && flutter pub get`]
- [ ] [Run `flutter build apk --release`]
- [ ] [Verify APK installs without errors]
- [ ] [Test all features on installed APK]
- [ ] [Create application signed APK (if required)]
- [ ] [Verify ZIP archive contains all necessary files]

### Deadline Compliance
- [ ] **Critical**: All external services must be available until **February 7, 2025**
- [ ] If using Firebase, Firestore, or APIs: Ensure subscription is active
- [ ] If API keys are time-limited: Request extension if needed
- [ ] Document any service dependencies in README

---

## 🚀 STARTUP CHECKLIST FOR EVALUATORS

### Phase 3 Evaluation Process

1. **Extract and Setup**
   - [ ] Extract project from ZIP
   - [ ] Run `flutter pub get`
   - [ ] Verify Android SDK matches README requirements

2. **Installation**
   - [ ] Follow README instructions exactly
   - [ ] Install APK on device/emulator
   - [ ] Launch application

3. **Functional Testing**
   - [ ] Execute all documented features
   - [ ] Test all screen transitions
   - [ ] Create and modify data, verify persistence
   - [ ] Close and reopen app - data still exists
   - [ ] Test user authentication if applicable

4. **Integration Testing**
   - [ ] Verify AR/VR features (if implemented)
   - [ ] Test LLM features (if implemented)
   - [ ] Test camera/audio (if implemented)
   - [ ] Verify location services (if implemented)

5. **Pass/Fail Criteria**
   - ✅ **PASS**: All requirements met, app functional, data persists
   - ❌ **FAIL**: External services unavailable, crashes, data not persisting
   - ⚠️ **CONDITIONAL**: Minor UI issues but core functionality works

---

## 📝 NOTES FOR DEVELOPERS

### Best Practices for Phase 3
1. **Start with navigation**: Get screen routing working first
2. **Add data layer**: Implement persistence before UI components
3. **Integrate incrementally**: Add Android subsystems one at a time
4. **Test frequently**: Don't wait until the end to test navigation
5. **Use state management**: Choose one (Provider, GetX, Bloc) for consistency
6. **Prepare evaluators**: Include sample data so evaluators don't start from scratch

### Common Pitfalls to Avoid
- ❌ Building APK without testing on physical device
- ❌ Forgetting to add permissions to AndroidManifest.xml
- ❌ Hardcoding API keys in source code
- ❌ Not testing data persistence after app close/reopen
- ❌ Leaving external services unprepared for evaluation date
- ❌ Complex setup that requires expert configuration
- ❌ Not documenting changes from Phase 2 prototype

### Resources
- [Flutter Official Documentation](https://flutter.dev/docs)
- [Pub.dev - Flutter Packages](https://pub.dev/)
- [Laboratory Workshop Recording Link](https://helios.ntua.gr/mod/bigbluebuttonbn/view.php?id=37490)
- Attached PDF guides:
  - "Incorporating-LLMS-into-your-Flutter-Application.pdf"
  - "Enhancing-your-Flutter-Application-with-AR_VR-Elements.pdf"

---

## 📅 TIMELINE RECOMMENDATION

| Phase | Duration | Tasks |
|-------|----------|-------|
| **Week 1** | 5-7 days | Navigation + Layouts + Navigation |
| **Week 2** | 5-7 days | Data Persistence + User Input |
| **Week 3** | 3-4 days | Android Subsystems (Camera, Audio, etc.) |
| **Week 4** | 2-3 days | Optional: AR/VR/LLM Integration |
| **Week 5** | 2-3 days | Testing + Documentation + APK Building |
| **Final** | 1 day | Final review, ZIP creation, README verification |

---

**Last Updated**: January 13, 2026  
**Deadline**: February 7, 2025  
**Status**: Ready for Implementation
