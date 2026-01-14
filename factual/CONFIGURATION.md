# Factual App - Configuration Guide

## API Keys Required

### 1. Google Gemini AI (LLM)
- **Service**: Natural language processing, fact-checking
- **Get Key**: https://aistudio.google.com/app/apikey
- **Configuration**:
  - Update `lib/services/llm_service.dart`
  - Replace `'Enter your API Key Here'` with your actual key

### 2. Google Maps API
- **Service**: Geographic filtering, map interface
- **Get Key**: https://console.cloud.google.com/apis/credentials
- **Enable APIs**: Maps SDK for Android, Geocoding API
- **Configuration**:
  - Open `android/app/src/main/AndroidManifest.xml`
  - Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual key

### 3. News API (Optional)
- **Service**: News aggregation
- **Get Key**: https://newsapi.org/register
- **Create**: `lib/services/news_api_service.dart`

### 4. Firebase (Optional - Cloud Sync)
- **Service**: Cloud database, authentication
- **Setup**:
  1. Go to https://console.firebase.google.com/
  2. Create new project
  3. Add Android app
  4. Download `google-services.json`
  5. Place in `android/app/google-services.json`
  6. Update `android/build.gradle` and `android/app/build.gradle`

## Dependencies Installed

### Navigation
- ✅ `go_router` - Declarative routing

### State Management
- ✅ `provider` - Simple state management

### LLM & AI
- ✅ `google_generative_ai` - Gemini AI integration

### Database
- ✅ `sqflite` - SQL database
- ✅ `hive` - NoSQL key-value store
- ✅ `shared_preferences` - Simple persistent storage

### Location & Maps
- ✅ `geolocator` - GPS location services
- ✅ `google_maps_flutter` - Google Maps widget

### Voice & Audio
- ✅ `speech_to_text` - Voice input
- ✅ `permission_handler` - Runtime permissions

### Network
- ✅ `http` - Simple HTTP client
- ✅ `dio` - Advanced HTTP client

### Firebase (Optional)
- ✅ `firebase_core` - Firebase SDK
- ✅ `cloud_firestore` - Cloud database
- ✅ `firebase_auth` - Authentication

### Utilities
- ✅ `intl` - Internationalization & date formatting
- ✅ `cached_network_image` - Image caching

## Android Permissions Configured

All required permissions are now in `AndroidManifest.xml`:

- ✅ `INTERNET` - API calls, news fetching
- ✅ `ACCESS_FINE_LOCATION` - GPS location
- ✅ `ACCESS_COARSE_LOCATION` - Network-based location
- ✅ `RECORD_AUDIO` - Speech-to-text
- ✅ `CAMERA` - Future AR features
- ✅ `POST_NOTIFICATIONS` - Push notifications

## Runtime Permission Handling

Some permissions require runtime request. Update your code to request permissions:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  // Location permission
  await Permission.location.request();
  
  // Microphone permission
  await Permission.microphone.request();
  
  // Camera permission (if using AR)
  await Permission.camera.request();
}
```

## Next Steps

1. **Add API keys** to the configuration files
2. **Test permissions** on a physical device or emulator
3. **Implement services** using the installed packages
4. **Firebase setup** (optional) for cloud features

## Important Notes

> [!WARNING]
> Never commit API keys to version control. Use environment variables or `.gitignore` for sensitive files.

> [!IMPORTANT]
> Location permissions require user consent on Android 6.0+. Always request at runtime.

## Testing Permissions

Run the app and test each permission:
```bash
flutter run
```

Check logcat for permission issues:
```bash
adb logcat | grep -i permission
```
