import 'package:flutter/material.dart';

import 'package:flutter/services.dart'; // Required for SystemChrome

import "./interfaces/AppDrawer.dart";
import './interfaces/NotificationInterfacePopUp.dart';

import './screens/HomePageScreen.dart';
import './screens/ExtendedGraphScreen.dart';
import './screens/ManageHabitsScreen.dart';
import './screens/HabitHistoryScreen.dart';
import './screens/SettingsScreen.dart';


void main() async {
  // 1. Ensure plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Lock the app to Portrait (Source: Document Section 1.D)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const HabitQuestApp());
}

class HabitQuestApp extends StatelessWidget {
  const HabitQuestApp({super.key});

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
        '/': (context) => const HomePageScreen(),
        '/extended_graph': (context) => const ExtendedGraphScreen(),
        '/manage_habits': (context) => const ManageHabitsScreen(),
        '/habit_history': (context) => const HabitHistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
