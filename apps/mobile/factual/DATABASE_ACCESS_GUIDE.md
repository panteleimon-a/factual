# Accessing Database Activity Tracking

To track user activity from the **factual** app's SQLite database, you have several options:

## Option 1: Export Database via App Feature (Recommended)

Add a debug feature to export the database to a shareable location:

```dart
// In SettingsScreen or a debug menu
Future<void> exportDatabase() async {
  final db = await DatabaseService().database;
  final dbPath = db.path;
  
  // Copy to external storage or share via platform channel
  // For Android: use path_provider to get external storage
  // For iOS: use share dialog
}
```

## Option 2: Use Platform Tools

### Android (Emulator/Rooted Device)
```bash
# Via ADB
adb shell
run-as com.example.factual
cd databases
sqlite3 factual.db

# Export to computer
adb exec-out run-as com.example.factual cat databases/factual.db > factual.db
```

### Android (Non-rooted Device)
```bash
# Use adb backup (requires user confirmation)
adb backup -f factual.ab -noapk com.example.factual
# Convert backup to tar, then extract
```

### iOS Simulator
```bash
# Find app container
xcrun simctl get_app_container booted com.example.factual data

# Navigate to database
cd $(xcrun simctl get_app_container booted com.example.factual data)/Library/Application\ Support/databases/
open factual.db  # Opens in DB Browser for SQLite if installed
```

## Option 3: Add Analytics Export Endpoint

Create a simple HTTP endpoint to query and export data:

```dart
// In a new service or debug screen
Future<Map<String, dynamic>> getAnalytics(String userId) async {
  final db = DatabaseService();
  
  return {
    'user': userId,
    'topTopics': await db.getTopInterestedTopics(userId),
    'searchHistory': await db.getUserSearchHistory(userId),
    'totalArticleViews': await _getArticleViewCount(userId),
  };
}
```

## Recommended Approach for Development

1. **Add a Debug Menu** to your app (available in development builds only)
2. **Include a "View Analytics" button** that displays:
   - Total article views
   - Top interested topics
   - Recent searches with sentiment
   - Popular searches by region
3. **Add an "Export Data" button** that creates a JSON file and shares it

Would you like me to implement this debug analytics screen for you?
