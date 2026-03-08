import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemChrome

// Database and Repository imports
import 'package:habit_quest/database/app_database.dart';
import 'package:habit_quest/repositories/habit_repository.dart';

// For SQLite Inspector (Debugging tool)
import 'package:flutter/foundation.dart';
import 'package:sqlite_inspector/sqlite_inspector.dart';

// Notification Service
import 'package:habit_quest/services/notification_service.dart';

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

class HabitQuestApp extends StatelessWidget {
  const HabitQuestApp({super.key, required this.habitRepo});

  final HabitRepository habitRepo;
  @override
  Widget build(BuildContext context) {
    // The app will display its name on the top bar[cite: 6].
    // Usually locked to portrait, except for specific screens[cite: 7].
    return MaterialApp(
      title: 'Habit Quest',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // When the User launches the app, they will be on the homepage[cite: 3].
        '/': (context) => HomePageScreen(habitRepo: habitRepo),
        '/extended_graph': (context) => ExtendedGraphScreen(habitRepo: habitRepo),
        '/manage_habits': (context) => ManageHabitsScreen(habitRepo: habitRepo),
        '/habit_history': (context) => HabitHistoryScreen(/*habitRepo: habitRepo*/),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
