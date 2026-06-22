# Phase 3 Agentic Task Breakdown & Coordination Guide
## Executable Task Queue for AI Agents/Development Teams

---

## 🎯 OVERVIEW

This document provides a structured task breakdown for coordinating Phase 3 Flutter app development. Each task is:
- **Atomic**: Can be completed independently
- **Verifiable**: Has clear acceptance criteria
- **Actionable**: Contains specific implementation details
- **Prioritized**: Grouped by execution order

---

## 📊 EXECUTION FLOW DIAGRAM

```
START
  ↓
[SETUP] Gradle & Dependencies
  ↓
[FOUNDATION] Navigation Architecture
  ↓
[CORE] Data Models & Persistence
  ↓
[UI] Screen Layouts & Components
  ↓
[INTERACTION] User Input & Forms
  ↓
[SUBSYSTEMS] Camera, Audio, Location (as needed)
  ↓
[INTEGRATION] AR/VR/LLM (as needed)
  ↓
[TESTING] Comprehensive Testing
  ↓
[DOCUMENTATION] README & Deliverables
  ↓
[DELIVERY] APK Building & Distribution
  ↓
END
```

---

## 🏗️ TASK CATEGORIES & EXECUTION ORDER

### PHASE 3.1: PROJECT SETUP (Duration: 2-3 hours)

#### Task 3.1.1: Gradle & Build Configuration
**Objective**: Configure Android build system for Phase 3 features

**ACCEPTANCE CRITERIA**:
- [ ] Gradle version matches Java version
- [ ] `compileSdk = 36` set in `build.gradle`
- [ ] `ndkVersion = "27.3.13750724"` set
- [ ] `minSdkVersion 28` configured
- [ ] `flutter clean && flutter pub get` executes without errors
- [ ] `flutter doctor` shows no errors

**IMPLEMENTATION**:
1. Find Java version: `flutter doctor -v` → check Java
2. Consult Gradle Compatibility Matrix
3. Update `android/gradle/wrapper/gradle-wrapper.properties`:
   ```
   distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-all.zip
   ```
4. Update `android/app/build.gradle`:
   ```gradle
   android {
       compileSdk = 36
       ndkVersion = "27.3.13750724"
       defaultConfig {
           minSdkVersion 28
       }
   }
   ```
5. Update `android/settings.gradle`:
   ```
   id "com.android.application" version "8.3.2"
   ```

**VERIFICATION**:
```bash
flutter clean
flutter pub get
flutter doctor -v
# Should show no errors
```

---

#### Task 3.1.2: Add Required Dependencies
**Objective**: Add all necessary packages to `pubspec.yaml`

**REQUIRED PACKAGES** (mandatory):
- `provider` - State management
- `sqflite` + `path_provider` - Local database
- `intl` - Date/time formatting

**CONDITIONAL PACKAGES** (based on Phase 2 specs):
- Camera: `camera`, `image_picker`
- Audio: `record`, `audioplayers`
- Location: `geolocator`, `permission_handler`
- AR: `ar_flutter_plugin_engine`, `vector_math`
- VR: `vr_player`
- LLM: `google_generative_ai`, `flutter_markdown`, `url_launcher`
- Navigation: `go_router` (if complex routing needed)

**IMPLEMENTATION**:
1. Open `pubspec.yaml`
2. Add packages under `dependencies:`
3. Run `flutter pub get`
4. Verify no conflicts in console output

**VERIFICATION**:
```bash
flutter pub get
# Check: no error messages, all packages downloaded
flutter analyze
# Check: no import errors
```

---

#### Task 3.1.3: Configure AndroidManifest.xml
**Objective**: Add all required permissions for Phase 3 features

**MANDATORY PERMISSIONS**:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**CONDITIONAL PERMISSIONS** (based on features):
- Camera: `android.permission.CAMERA`, `android.hardware.camera.ar`
- Audio: `android.permission.RECORD_AUDIO`, `android.permission.WRITE_EXTERNAL_STORAGE`
- Location: `android.permission.ACCESS_FINE_LOCATION`, `android.permission.ACCESS_COARSE_LOCATION`

**IMPLEMENTATION**:
1. Open `android/app/src/main/AndroidManifest.xml`
2. Add all required `<uses-permission>` tags
3. Add `<uses-feature>` tags for AR if needed

**VERIFICATION**:
```bash
grep -c "uses-permission" android/app/src/main/AndroidManifest.xml
# Should match number of required permissions
```

---

### PHASE 3.2: NAVIGATION & ROUTING (Duration: 3-4 hours)

#### Task 3.2.1: Define Navigation Architecture
**Objective**: Choose and configure navigation system

**DECISION TREE**:
```
Is routing complex (5+ screens with multiple flows)?
├─ YES → Use `go_router`
│   └─ [Task 3.2.1.A]
├─ NO → Use named routes with Navigator
│   └─ [Task 3.2.1.B]
└─ SIMPLE (3-4 screens, linear flow) → Use direct Navigator.push
    └─ [Task 3.2.1.C]
```

**Task 3.2.1.A: Setup go_router (if applicable)**
```dart
// lib/main.dart
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) => DetailScreen(
        id: state.pathParameters['id'],
      ),
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'App Name',
    );
  }
}
```

**Task 3.2.1.B: Setup Named Routes (if applicable)**
```dart
// lib/main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      routes: {
        '/details': (context) => DetailScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

// Usage in widgets
Navigator.pushNamed(context, '/details');
```

**Task 3.2.1.C: Direct Navigation Setup (if applicable)**
```dart
// Simply use Navigator.push() in each screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NextScreen()),
);
```

**DOCUMENTATION**:
- [ ] Record chosen approach in `README.md`
- [ ] Document all routes/screens in navigation diagram
- [ ] List transition patterns (button vs. gesture)

---

#### Task 3.2.2: Implement Button-Based Navigation
**Objective**: Create navigation buttons for screen transitions

**IMPLEMENTATION**:
```dart
// Generic navigation button
ElevatedButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => NextScreen()),
  ),
  child: Text('Go to Next Screen'),
)
```

**ACCEPTANCE CRITERIA**:
- [ ] All navigation buttons have descriptive labels
- [ ] All button taps successfully navigate to target screen
- [ ] No console errors during navigation
- [ ] Back button works correctly on all screens

**VERIFICATION**:
- [ ] Tap each button on each screen
- [ ] Verify navigation occurs
- [ ] Press Android back button
- [ ] Verify previous screen appears

---

#### Task 3.2.3: Implement Gesture-Based Navigation (if applicable)
**Objective**: Add swipe/gesture-based navigation if specified in Phase 2

**IMPLEMENTATION - Option A: Horizontal Swipe**
```dart
GestureDetector(
  onHorizontalDragEnd: (DragEndDetails details) {
    if (details.primaryVelocity! < 0) {
      // Swiped left
      Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
    } else if (details.primaryVelocity! > 0) {
      // Swiped right
      Navigator.pop(context);
    }
  },
  child: YourScreenContent(),
)
```

**IMPLEMENTATION - Option B: PageView**
```dart
class GestureNavigationScreen extends StatefulWidget {
  @override
  State<GestureNavigationScreen> createState() => _GestureNavigationScreenState();
}

class _GestureNavigationScreenState extends State<GestureNavigationScreen> {
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: [
        Screen1(),
        Screen2(),
        Screen3(),
      ],
    );
  }
}
```

**ACCEPTANCE CRITERIA** (if implemented):
- [ ] Swipe gestures recognized consistently
- [ ] Navigation animations are smooth
- [ ] Both directions work correctly
- [ ] No gesture conflicts with other UI elements

---

### PHASE 3.3: DATA LAYER (Duration: 4-6 hours)

#### Task 3.3.1: Define Data Models
**Objective**: Create model classes for all domain entities

**EXAMPLE - Task Model**:
```dart
// lib/models/task.dart
class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isCompleted;
  
  Task({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isCompleted = false,
  });
  
  // Serialization for database
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted ? 1 : 0,
  };
  
  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    createdAt: DateTime.parse(map['createdAt']),
    isCompleted: map['isCompleted'] == 1,
  );
  
  // JSON serialization (for Firebase)
  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted,
  };
  
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    title: json['title'],
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
    isCompleted: json['isCompleted'] ?? false,
  );
}
```

**REQUIREMENTS**:
- [ ] All models include required fields
- [ ] All models have `toMap()` or `toJson()` methods
- [ ] All models have factory constructors from `fromMap()` or `fromJson()`
- [ ] Models reflect Phase 2 data specifications

**VERIFICATION**:
```bash
flutter analyze
# Check: no type errors, all models valid
```

---

#### Task 3.3.2: Implement Local Database (SQLite/Hive)
**Objective**: Create database service for persistence

**IMPLEMENTATION - SQLite**:
```dart
// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  
  static Database? _database;
  
  DatabaseService._init();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
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
        description TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isCompleted INTEGER DEFAULT 0
      )
    ''');
  }
  
  // CRUD Operations
  Future<Task> create(Task task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return task;  // In production, return with id
  }
  
  Future<Task?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }
  
  Future<List<Task>> readAll() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return List.from(result.map((map) => Task.fromMap(map)));
  }
  
  Future<int> update(Task task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
  
  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
```

**ACCEPTANCE CRITERIA**:
- [ ] Database initializes on app startup
- [ ] All CRUD operations work correctly
- [ ] Data persists after app close/reopen
- [ ] No database errors in console

**VERIFICATION**:
```dart
// Test in main.dart or test file
void testDatabase() async {
  final db = DatabaseService.instance;
  
  // Create
  final task = Task(title: 'Test', description: 'Test task', createdAt: DateTime.now());
  await db.create(task);
  
  // Read all
  final tasks = await db.readAll();
  assert(tasks.isNotEmpty, 'Task should be saved');
  
  // Read specific
  final readTask = await db.read(tasks.first.id!);
  assert(readTask?.title == 'Test', 'Task should match');
  
  // Update
  await db.update(readTask!);
  
  // Delete
  await db.delete(readTask.id!);
  
  final finalTasks = await db.readAll();
  assert(finalTasks.isEmpty, 'Task should be deleted');
}
```

---

#### Task 3.3.3: Implement Remote Database (Firebase - Optional)
**Objective**: Setup Firestore for cloud persistence

**IMPLEMENTATION**:
```dart
// lib/services/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() {
    return _instance;
  }
  
  FirebaseService._internal();
  
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Create
  Future<void> createTask(Task task) async {
    try {
      await _firestore.collection('tasks').add(task.toJson());
    } catch (e) {
      rethrow;
    }
  }
  
  // Read all (Stream for real-time)
  Stream<List<Task>> getTasks() {
    return _firestore.collection('tasks').snapshots().map(
      (snapshot) => snapshot.docs
        .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
        .toList(),
    );
  }
  
  // Update
  Future<void> updateTask(String id, Task task) async {
    try {
      await _firestore.collection('tasks').doc(id).update(task.toJson());
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete
  Future<void> deleteTask(String id) async {
    try {
      await _firestore.collection('tasks').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}

// Initialize in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const MyApp());
}
```

**ACCEPTANCE CRITERIA**:
- [ ] Firebase initialized without errors
- [ ] Data syncs to Firestore collection
- [ ] Real-time updates work (StreamBuilder)
- [ ] Offline data handled gracefully

---

### PHASE 3.4: USER INTERFACE (Duration: 6-8 hours)

#### Task 3.4.1: Create Screen Widgets
**Objective**: Build all screen layouts from Phase 2 prototype

**TEMPLATE - List Screen**:
```dart
// lib/screens/task_list_screen.dart
class TaskListScreen extends StatefulWidget {
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> _tasks;
  
  @override
  void initState() {
    super.initState();
    _tasks = DatabaseService.instance.readAll();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TaskCreateScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final tasks = snapshot.data ?? [];
          
          if (tasks.isEmpty) {
            return Center(child: Text('No tasks. Create one to get started!'));
          }
          
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(task: task),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

**TEMPLATE - Detail Screen**:
```dart
// lib/screens/task_detail_screen.dart
class TaskDetailScreen extends StatelessWidget {
  final Task task;
  
  const TaskDetailScreen({required this.task});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Details')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            Text(task.description),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**ACCEPTANCE CRITERIA**:
- [ ] All screens from Phase 2 are implemented
- [ ] All screens have appropriate AppBar
- [ ] All screens handle loading states (if async)
- [ ] All screens handle error states (if async)
- [ ] No hardcoded placeholder text without context

---

#### Task 3.4.2: Implement StatefulWidgets for Data Modification
**Objective**: Create screens that modify data with UI updates

**REQUIREMENT**: Identify all screens where data changes:
- [ ] Task creation screens
- [ ] Task editing screens
- [ ] User profile modification
- [ ] Settings/preferences screens

**IMPLEMENTATION**:
```dart
class TaskCreateScreen extends StatefulWidget {
  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;
  
  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    
    setState(() => _isSaving = true);
    
    try {
      final task = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
      );
      
      await DatabaseService.instance.create(task);
      
      Navigator.pop(context, task);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving task: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Task')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveTask,
              child: _isSaving
                ? CircularProgressIndicator()
                : Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
```

**ACCEPTANCE CRITERIA**:
- [ ] StatefulWidget updates UI on data changes
- [ ] `setState()` called at appropriate times
- [ ] Controllers/streams properly disposed
- [ ] UI reflects modified data immediately

---

### PHASE 3.5: USER INPUT (Duration: 3-4 hours)

#### Task 3.5.1: Implement Forms with Validation
**Objective**: Create validated input forms

**IMPLEMENTATION**:
```dart
class TaskFormScreen extends StatefulWidget {
  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _dueDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Form')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                if (value.length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
              onSaved: (value) => _title = value ?? '',
            ),
            SizedBox(height: 16),
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
            SizedBox(height: 32),
            Row(
              children: [
                Text('Due Date: ${_dueDate.toLocal().toString().split(' ')[0]}'),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _selectDate,
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _dueDate) {
      setState(() => _dueDate = picked);
    }
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Process form data
      print('Title: $_title, Description: $_description, Due: $_dueDate');
      Navigator.pop(context);
    }
  }
}
```

**ACCEPTANCE CRITERIA**:
- [ ] Form validation triggers on submit
- [ ] Error messages display for invalid inputs
- [ ] Form submission clears after success
- [ ] All required fields validated

---

#### Task 3.5.2: Add Time/Date Pickers
**Objective**: Implement specialized input widgets

**TIME PICKER**:
```dart
Future<void> _selectTime() async {
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

**DATE PICKER**:
```dart
Future<void> _selectDate() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  
  if (picked != null) {
    setState(() {
      selectedDate = picked;
    });
  }
}
```

**ACCEPTANCE CRITERIA** (if date/time input in Phase 2):
- [ ] Date picker opens on button tap
- [ ] Time picker opens on button tap
- [ ] Selected values display correctly
- [ ] Format is user-friendly (not raw ISO strings)

---

### PHASE 3.6: ANDROID SUBSYSTEMS (Duration: 5-8 hours - only required features)

#### Task 3.6.1: Camera Integration (if required)
**Objective**: Implement photo capture

**IMPLEMENTATION**:
```dart
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
        setState(() => _imageFile = photo);
        // Save to database or upload
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
              Image.file(File(_imageFile!.path), height: 200)
            else
              Text('No image captured'),
            SizedBox(height: 32),
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

**ACCEPTANCE CRITERIA**:
- [ ] Camera opens when button tapped
- [ ] Photo captures correctly
- [ ] Photo displays in UI after capture
- [ ] Android camera permission granted
- [ ] No crashes when canceling camera

**TESTING**:
```bash
# Verify permission request appears
# Verify camera app opens
# Verify captured photo displays
```

---

#### Task 3.6.2: Audio Integration (if required)
**Objective**: Implement recording and playback

**IMPLEMENTATION - Recording**:
```dart
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Microphone permission denied')),
        );
      }
    } catch (e) {
      print('Error: $e');
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
      print('Error: $e');
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
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 64,
              color: _isRecording ? Colors.red : Colors.grey,
            ),
            SizedBox(height: 16),
            Text(_isRecording ? 'Recording...' : 'Not recording'),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop' : 'Start'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**ACCEPTANCE CRITERIA**:
- [ ] Audio recording starts/stops correctly
- [ ] Microphone permission granted
- [ ] Recording file saved
- [ ] Recording time displayed (optional)

---

#### Task 3.6.3: Location Services (if required)
**OBJECTIVE**: Implement location retrieval

**IMPLEMENTATION**:
```dart
class LocationService {
  static final LocationService _instance = LocationService._internal();
  
  factory LocationService() => _instance;
  
  LocationService._internal();
  
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is disabled.');
    }
    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permanently disabled');
    }
    
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }
}

// Usage in widget
class LocationScreen extends StatefulWidget {
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _position;
  
  Future<void> _getLocation() async {
    try {
      final position = await LocationService().getCurrentLocation();
      setState(() => _position = position);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_position != null)
              Text(
                'Lat: ${_position!.latitude.toStringAsFixed(4)}\n'
                'Lon: ${_position!.longitude.toStringAsFixed(4)}',
                textAlign: TextAlign.center,
              )
            else
              Text('Location not retrieved'),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _getLocation,
              child: Text('Get Location'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**ACCEPTANCE CRITERIA**:
- [ ] Location permission granted
- [ ] Current location retrieved
- [ ] Coordinates displayed
- [ ] Error handling for disabled location service

---

### PHASE 3.7: OPTIONAL INTEGRATIONS (Duration: varies)

#### Task 3.7.1: AR Integration (if required)
**Reference**: Attached "Enhancing-your-Flutter-Application-with-AR_VR-Elements.pdf"

**PRIORITY CHECKLIST**:
- [ ] Add `ar_flutter_plugin_engine: ^1.0.0` to pubspec.yaml
- [ ] Configure AndroidManifest.xml with AR permissions
- [ ] Update build.gradle with ARCore dependency
- [ ] Implement AR object placement
- [ ] Test on AR-capable device

---

#### Task 3.7.2: LLM Integration (if required)
**Reference**: Attached "Incorporating-LLMS-into-your-Flutter-Application.pdf"

**SETUP**:
```bash
# 1. Get Gemini API key
# Visit: https://aistudio.google.com/app/apikey

# 2. Create api-keys.json
cat > api-keys.json << EOF
{
  "GOOGLE_AI_KEY": "your_key_here"
}
EOF

# 3. Setup .vscode/launch.json
mkdir -p .vscode
cat > .vscode/launch.json << EOF
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--dart-define-from-file", "api-keys.json"]
    }
  ]
}
EOF
```

**IMPLEMENTATION**:
```dart
class LLMService {
  late final GenerativeModel _model;
  
  LLMService(String apiKey) {
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  }
  
  Future<String> generate(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
```

**ACCEPTANCE CRITERIA**:
- [ ] API key properly configured
- [ ] LLM API calls successful
- [ ] Responses display in UI
- [ ] Error handling for API failures
- [ ] Rate limiting considered

---

### PHASE 3.8: TESTING (Duration: 3-4 hours)

#### Task 3.8.1: Functional Testing
**CHECKLIST**:
- [ ] All screens load without crashes
- [ ] Navigation works (buttons and gestures)
- [ ] Data persists after app restart
- [ ] User input validation works
- [ ] No console errors

**TEST PROCEDURE**:
```
1. Launch app: flutter run
2. For each screen:
   - Verify loads correctly
   - Verify all buttons work
   - Verify data displays correctly
3. Close app and reopen: flutter run
4. Verify persisted data appears
5. Test all error scenarios
```

---

#### Task 3.8.2: Integration Testing
**CHECKLIST** (for implemented features):
- [ ] Camera captures and saves
- [ ] Audio records and plays
- [ ] Location retrieves successfully
- [ ] LLM API returns responses
- [ ] AR objects render
- [ ] Database syncs correctly

---

### PHASE 3.9: BUILD & DEPLOYMENT (Duration: 2-3 hours)

#### Task 3.9.1: Release APK Building
**IMPLEMENTATION**:
```bash
# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Verify APK was created
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

**ACCEPTANCE CRITERIA**:
- [ ] APK builds without errors
- [ ] APK file size reasonable (<500 MB)
- [ ] APK installs on physical device
- [ ] All features work on installed APK

---

#### Task 3.9.2: Project Archiving
**IMPLEMENTATION**:
```bash
# Create ZIP with proper exclusions
zip -r flutter_app_phase3.zip . \
  -x "build/*" ".dart_tool/*" ".idea/*" ".vscode/*" ".git/*" "*.swp"

# Verify ZIP contents
unzip -l flutter_app_phase3.zip | head -20
```

**VERIFICATION**:
- [ ] ZIP contains all source files
- [ ] ZIP contains pubspec.yaml
- [ ] ZIP contains android configuration
- [ ] ZIP file size reasonable

---

### PHASE 3.10: DOCUMENTATION (Duration: 2-3 hours)

#### Task 3.10.1: Write README.md
**REQUIRED SECTIONS**:
- [ ] Installation instructions (clear for non-experts)
- [ ] Quick start guide
- [ ] Feature overview
- [ ] Android SDK requirements
- [ ] Links to resources/repositories

**OPTIONAL SECTIONS**:
- [ ] Video demonstration (3-minute max)
- [ ] Deviations from Phase 2 prototype
- [ ] Development notes

**TEMPLATE**:
```markdown
# [App Name] - Phase 3 Implementation

## Installation

1. Prerequisites:
   - Flutter version: [X.X.X]
   - Android SDK: [version]
   - Java: [version]

2. Setup:
   \`\`\`bash
   flutter pub get
   flutter run
   \`\`\`

3. Build APK:
   \`\`\`bash
   flutter build apk --release
   \`\`\`

## Features

- [Feature 1]
- [Feature 2]
- [Feature 3]

## Requirements Met

- [✓] Layout & Navigation
- [✓] Data Persistence
- [✓] User Input Handling
- [✓] Android Subsystems

## Notes

- External services required: [list if any]
- Guaranteed availability until: February 7, 2025
```

---

## 🎯 TASK PRIORITY MATRIX

| Priority | Duration | Task | Blocking |
|----------|----------|------|----------|
| 🔴 CRITICAL | 2-3h | Gradle & Build Config | All subsystems |
| 🔴 CRITICAL | 3-4h | Navigation Architecture | UI development |
| 🔴 CRITICAL | 4-6h | Data Models & Persistence | Feature implementation |
| 🟡 HIGH | 6-8h | Screen Layouts & UI | Feature testing |
| 🟡 HIGH | 3-4h | User Input & Forms | Testing |
| 🟢 MEDIUM | 5-8h | Android Subsystems | Only if required |
| 🟢 MEDIUM | Varies | AR/VR/LLM Integration | Only if required |
| 🟣 LOW | 3-4h | Testing | Deployment |
| 🟣 LOW | 2-3h | Build & Archive | Delivery |
| 🟣 LOW | 2-3h | Documentation | Evaluation |

---

## ⚠️ CRITICAL DEPENDENCIES

```
Gradle Config
    ↓
Dependencies
    ↓
AndroidManifest.xml
    ↓
Navigation Architecture ← BLOCKS → Data Layer
    ↓                              ↓
Screen Layouts ←←←←←←←←←←←←←←← User Input
    ↓
Android Subsystems
    ↓
Optional: AR/VR/LLM
    ↓
Testing
    ↓
Build & Deployment
    ↓
Documentation
```

---

## 📋 SIGN-OFF CHECKLIST

Before final submission:

- [ ] All required tasks completed
- [ ] All acceptance criteria met
- [ ] Code builds without warnings
- [ ] APK builds successfully
- [ ] APK installs and runs on device
- [ ] All features tested
- [ ] README complete and accurate
- [ ] External services confirmed active until deadline
- [ ] ZIP archive created and verified
- [ ] All files present in submission

---

**Generated**: January 13, 2026  
**Status**: Ready for Development  
**Last Updated**: January 13, 2026

