# Database File Location

The **factual** app uses SQLite for local data storage via the `sqflite` package.

## Persistence

**The database is PERSISTENT** - all data remains on the device even after the app is closed. Data persists until:
- The user uninstalls the app
- The user manually clears app data from device settings
- The app explicitly deletes data (e.g., via "Clear History" features)

## Database Path

The database file is named `factual.db` and is stored at:

```
<appDataDirectory>/databases/factual.db
```

### Platform-Specific Locations

- **Android**: `/data/data/com.example.factual/databases/factual.db`
- **iOS**: `<Application Support Directory>/databases/factual.db`
- **macOS**: `~/Library/Containers/com.example.factual/Data/Library/Application Support/databases/factual.db`

## Tracked Data

The database tracks the following user activities:

### `user_interactions` Table
- `userId`: The user identifier (currently using mock `'default_user'`)
- `articleId`: The ID of the viewed article
- `topics`: Comma-separated list of article topics
- `timestamp`: ISO 8601 timestamp of the interaction

### `search_queries` Table
- `id`: Unique query ID
- `userId`: The user identifier
- `query`: The search query text
- `sentiment`: Sentiment analysis result (positive/negative/neutral)
- `timestamp`: ISO 8601 timestamp of the search
- `location`: User's location at time of search
- `relatedArticleIds`: Comma-separated article IDs
- `metadata`: Additional metadata in JSON format

## Accessing the Database

To inspect the database on a development device:

### Android
```bash
adb shell
run-as com.example.factual
cd databases
cat factual.db  # or use sqlite3 factual.db
```

### iOS/macOS
Use a tool like [DB Browser for SQLite](https://sqlitebrowser.org/) to open the database file directly from the Application Support directory.

## Privacy Note

All data is stored locally on the device. No interaction data is transmitted to external servers unless explicitly configured in future updates.
