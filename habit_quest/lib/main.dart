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

// State Management
import 'package:habit_quest/providers/theme_provider.dart';
import 'package:provider/provider.dart';

// Screens
import 'package:habit_quest/screens/home_page_screen.dart';
import 'package:habit_quest/screens/extended_graph_screen.dart';
import 'screens/manage_habits_screen.dart';
import 'package:habit_quest/screens/habit_history_screen.dart';
import 'package:habit_quest/screens/settings_screen.dart';

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
  HabitRepository.initialize(
    habitDao: database.habitDao,
    habitRecordDao: database.habitRecordDao
  );

  // Lock the app to Portrait (Source: Document Section 1.D)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const HabitQuestApp(),
    ),
);
}
class HabitQuestApp extends StatelessWidget {  // change to StatelessWidget
  const HabitQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Habit Quest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePageScreen(),
        '/extended_graph': (context) => const ExtendedGraphScreen(),
        '/manage_habits': (context) => const ManageHabitsScreen(),
        '/habit_history': (context) => const HabitHistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}