import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Database and Repository imports
import 'package:habit_quest/database/app_database.dart';
import 'package:habit_quest/repositories/habit_repository.dart';

// For SQLite Inspector (Debugging tool)
import 'package:flutter/foundation.dart';
import 'package:sqlite_inspector/sqlite_inspector.dart';

// Notification Service
import 'package:habit_quest/services/notification_service.dart';

// Shared Preferences
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import './screens/HomePageScreen.dart';
import './screens/ExtendedGraphScreen.dart';
import './screens/ManageHabitsScreen.dart';
import './screens/HabitHistoryScreen.dart';
import './screens/SettingsScreen.dart';

void main() async {
  // Ensure plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notification Service
  await NotificationService().initNotification();

  // Start SQLite Inspector in debug mode
  if (kDebugMode) {
    await SqliteInspector.start();
  }

  // Initialize database
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();

  // Initialize the repository
  final habitRepo = HabitRepository(
    habitDao: database.habitDao,
    habitRecordDao: database.habitRecordDao
  );

  // Lock the app to Portrait (Source: Document Section 1.D)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(HabitQuestApp(habitRepo: habitRepo));
}

class HabitQuestApp extends StatefulWidget {
  const HabitQuestApp({super.key, required this.habitRepo});

  final HabitRepository habitRepo;
  @override
  State<HabitQuestApp> createState() => _HabitQuestAppState();
}

class _HabitQuestAppState extends State<HabitQuestApp> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = pref.getBool('darkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Quest',
      // Define the Light Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Define the Dark Theme
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Tell the app which one to use based on our state
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        // When the User launches the app, they will be on the homepage[cite: 3].
        '/': (context) => HomePageScreen(habitRepo: widget.habitRepo),
        '/extended_graph': (context) => ExtendedGraphScreen(habitRepo: widget.habitRepo),
        '/manage_habits': (context) => ManageHabitsScreen(habitRepo: widget.habitRepo),
        '/habit_history': (context) => HabitHistoryScreen(/*habitRepo: habitRepo*/),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}