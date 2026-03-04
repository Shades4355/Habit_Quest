import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

import './screens/HomePageScreen.dart';
import './screens/ExtendedGraphScreen.dart';
import './screens/ManageHabitsScreen.dart';
import './screens/HabitHistoryScreen.dart';
import './screens/SettingsScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const HabitQuestApp());
}

class HabitQuestApp extends StatefulWidget {
  const HabitQuestApp({super.key});

  @override
  State<HabitQuestApp> createState() => _HabitQuestAppState();
}

class _HabitQuestAppState extends State<HabitQuestApp> {
  // This variable tracks if we are in light or dark mode
  ThemeMode _themeMode = ThemeMode.light;

  // This function will be passed to the Settings screen to change the mode
  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Quest',
      // Define the Light Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
        useMaterial3: true,
      ),
      // Define the Dark Theme
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      // Tell the app which one to use based on our state
      themeMode: _themeMode, 
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePageScreen(),
        '/extended_graph': (context) => const ExtendedGraphScreen(),
        '/manage_habits': (context) => const ManageHabitsScreen(),
        '/habit_history': (context) => const HabitHistoryScreen(),
        // We pass the current state and the toggle function to Settings
        '/settings': (context) => SettingsScreen(
          isDarkMode: _themeMode == ThemeMode.dark,
          onThemeChanged: _toggleTheme,
        ),
      },
    );
  }
}