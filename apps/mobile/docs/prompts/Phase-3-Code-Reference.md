# Phase 3 Quick Reference Guide
## Executable Commands & Code Snippets for Agentic Implementation

---

## 🔧 SETUP & INITIALIZATION

### Initial Flutter Project Setup
```bash
# Create new Flutter project
flutter create my_app
cd my_app

# Get dependencies
flutter pub get

# Run on emulator/device
flutter run

# Build release APK
flutter build apk --release
```

### Adding Dependencies to pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Navigation
  go_router: ^13.2.0
  
  # State Management
  provider: ^6.0.0
  
  # Local Database
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  
  # Remote Database
  firebase_core: ^25.0.0
  cloud_firestore: ^5.0.0
  
  # User Input & Forms
  intl: ^0.19.0
  
  # Camera
  camera: ^0.10.0
  image_picker: ^1.0.0
  
  # Audio
  record: ^5.0.0
  audioplayers: ^6.0.0
  
  # Location
  geolocator: ^11.0.0
  
  # Permissions
  permission_handler: ^11.0.0
  
  # AR (Optional)
  ar_flutter_plugin_engine: ^1.0.0
  vector_math: ^2.1.4
  
  # VR (Optional)
  vr_player: ^0.3.0
  
  # LLM (Optional)
  google_generative_ai: ^0.4.7
  flutter_markdown: ^0.7.7+1
  url_launcher: ^6.3.2
```

### Android Permissions (AndroidManifest.xml)
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.app">
    
    <!-- Camera & AR -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera.ar" />
    
    <!-- Audio -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <!-- Location -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Network -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application>
        <!-- Your application configuration -->
    </application>
</manifest>
```

### Gradle Configuration (android/app/build.gradle)
```gradle
android {
    compileSdk = 36
    ndkVersion = "27.3.13750724"
    
    defaultConfig {
        applicationId "com.example.app"
        minSdkVersion 28
        targetSdkVersion 36
        versionCode 1
        versionName "1.0"
    }
    
    buildTypes {
        release {
            shrinkResources false
            minifyEnabled false
        }
    }
}

dependencies {
    // AR Core Library (if using AR)
    implementation 'com.google.ar:core:1.33.0'
}
```

---

## 🧭 NAVIGATION PATTERNS

### Simple Navigation with Navigator
```dart
// Navigate to new screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DetailScreen()),
);

// Navigate with named routes
Navigator.pushNamed(context, '/details');

// Pop with result
Navigator.pop(context, result);

// Replace current screen
Navigator.pushReplacementNamed(context, '/home');
```

### Named Routes Setup (main.dart)
```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Name',
      home: HomeScreen(),
      routes: {
        '/details': (context) => DetailScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
```

### Gesture-Based Navigation
```dart
GestureDetector(
  onHorizontalDragEnd: (DragEndDetails details) {
    if (details.primaryVelocity! < 0) {
      // Swiped left - go to next screen
      Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
    } else if (details.primaryVelocity! > 0) {
      // Swiped right - go to previous screen
      Navigator.pop(context);
    }
  },
  child: YourContentWidget(),
)
```

### PageView for Swipeable Screens
```dart
PageView(
  children: [
    Screen1(),
    Screen2(),
    Screen3(),
  ],
)
```

---

## 💾 DATA PERSISTENCE PATTERNS

### Using StatefulWidget
```dart
class DataScreen extends StatefulWidget {
  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  String myData = "Initial value";
  
  void updateData(String newValue) {
    setState(() {
      myData = newValue;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(myData),
          ElevatedButton(
            onPressed: () => updateData("Updated value"),
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}
```

### Local Database with SQLite
```dart
// Model Class
class Task {
  final int? id;
  final String title;
  final String description;
  
  Task({this.id, required this.title, required this.description});
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
  };
  
  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    description: map['description'],
  );
}

// Database Service
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  
  static Database? _database;
  
  DatabaseService._init();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }
  
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');
  }
  
  // CRUD Operations
  Future<Task> createTask(Task task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }
  
  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;
    final maps = await db.query('tasks');
    return List.from(maps.map((map) => Task.fromMap(map)));
  }
  
  Future<Task?> getTaskById(int id) async {
    final db = await instance.database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Task.fromMap(maps.first);
    return null;
  }
  
  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }
  
  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
```

### Firebase Firestore Integration
```dart
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> createDocument(String collection, String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(id).set(data);
    } catch (e) {
      print('Error creating document: $e');
    }
  }
  
  Stream<List<Task>> getTasks() {
    return _firestore.collection('tasks').snapshots().map(
      (snapshot) => snapshot.docs
        .map((doc) => Task.fromMap(doc.data()))
        .toList(),
    );
  }
  
  Future<void> updateDocument(String collection, String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(id).update(data);
    } catch (e) {
      print('Error updating document: $e');
    }
  }
  
  Future<void> deleteDocument(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}
```

---

## 📝 USER INPUT PATTERNS

### Form with Validation
```dart
class TaskForm extends StatefulWidget {
  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Task Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
            onSaved: (value) => _title = value ?? '',
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Description'),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
            onSaved: (value) => _description = value ?? '',
          ),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Create Task'),
          ),
        ],
      ),
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Process form data
      print('Title: $_title, Description: $_description');
    }
  }
}
```

### Time & Date Picker
```dart
// Show date picker
void _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  
  if (picked != null && picked != selectedDate) {
    setState(() {
      selectedDate = picked;
    });
  }
}

// Show time picker
void _selectTime(BuildContext context) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  
  if (picked != null) {
    setState(() {
      selectedTime = picked;
    });
  }
}
```

---

## 📸 ANDROID SUBSYSTEMS

### Camera Integration
```dart
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  
  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
      );
      
      if (photo != null) {
        setState(() {
          _imageFile = photo;
        });
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageFile != null)
              Image.file(File(_imageFile!.path))
            else
              Text('No image selected'),
            ElevatedButton(
              onPressed: _takePicture,
              child: Text('Take Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Audio Recording
```dart
import 'package:record/record.dart';

class AudioRecorderScreen extends StatefulWidget {
  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();
        setState(() => _isRecording = true);
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }
  
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Recorder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_isRecording ? 'Recording...' : 'Not recording'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Location Services
```dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
    
    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }
    
    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }
}
```

### LLM Integration (Google Gemini)
```dart
import 'package:google_generative_ai/google_generative_ai.dart';

class LLMService {
  late final GenerativeModel _model;
  
  LLMService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }
  
  Future<String> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response';
    } catch (e) {
      print('Error generating content: $e');
      return 'Error: $e';
    }
  }
  
  // Use from environment variable
  static String getApiKey() {
    return const String.fromEnvironment('GOOGLE_AI_KEY');
  }
}

// Usage in widget
class LLMInputScreen extends StatefulWidget {
  final String apiKey;
  
  LLMInputScreen({required this.apiKey});
  
  @override
  State<LLMInputScreen> createState() => _LLMInputScreenState();
}

class _LLMInputScreenState extends State<LLMInputScreen> {
  late LLMService _llmService;
  String _response = '';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _llmService = LLMService(widget.apiKey);
  }
  
  Future<void> _generateContent(String prompt) async {
    setState(() => _isLoading = true);
    
    final response = await _llmService.generateContent(prompt);
    
    setState(() {
      _response = response;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LLM Generator')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _isLoading
                  ? CircularProgressIndicator()
                  : Text(_response),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _generateContent('Generate a task description'),
              child: Text('Generate with LLM'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ✨ COMMON PATTERNS

### FutureBuilder for Async Data
```dart
FutureBuilder<List<Task>>(
  future: DatabaseService.instance.getAllTasks(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }
    
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text('No tasks found'));
    }
    
    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(snapshot.data![index].title));
      },
    );
  },
)
```

### StreamBuilder for Real-time Data
```dart
StreamBuilder<List<Task>>(
  stream: FirebaseService().getTasks(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }
    
    return ListView.builder(
      itemCount: snapshot.data?.length ?? 0,
      itemBuilder: (context, index) {
        final task = snapshot.data![index];
        return ListTile(title: Text(task.title));
      },
    );
  },
)
```

---

## 🚀 BUILD & DEPLOYMENT

### Build Debug APK
```bash
flutter build apk --debug
```

### Build Release APK
```bash
flutter build apk --release
```

### Install on Device
```bash
flutter install
```

### Run on Physical Device
```bash
flutter devices          # List connected devices
flutter run -d <device_id>
```

### Create ZIP Archive
```bash
# On macOS/Linux
zip -r flutter_app_phase3.zip . -x "build/*" ".dart_tool/*" ".idea/*" "node_modules/*"

# On Windows
# Use Windows Explorer: right-click > Send to > Compressed folder
```

---

## ✅ TESTING CHECKLIST

### Functionality Tests
- [ ] All screens load without errors
- [ ] Navigation transitions work smoothly
- [ ] Data persists after app close/reopen
- [ ] User input validation works
- [ ] All buttons and UI elements are responsive

### Integration Tests
- [ ] Camera captures images correctly
- [ ] Audio records and plays correctly
- [ ] Location services retrieve coordinates
- [ ] LLM API calls return responses
- [ ] AR objects render properly (if implemented)

### Deployment Tests
- [ ] APK installs on physical device
- [ ] APK installs on emulator
- [ ] No crashes during normal usage
- [ ] All permissions are properly requested
- [ ] External services are accessible

---

**Date**: January 13, 2026  
**Status**: Ready for Implementation  
**Version**: 1.0
