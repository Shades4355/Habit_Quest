/*
Honor Statement

Academic achievement is ordinarily evaluated based on work that a student produces independently. Infringement of this Code of Honor entails penalties ranging from reprimand to suspension, dismissal, or expulsion from the University.

Your name on any exercise is regarded as assurance and certification that what you are submitting for that exercise is the result of your thoughts and study. Where collaboration is authorized, you should state very clearly which parts of any assignment were performed with collaboration and name your collaborators.

In writing examinations and quizzes, you are expected and required to respond entirely based on your memory and capacity, without any assistance whatsoever except such as what is specifically authorized by the instructor.

I certify that the work submitted with this assignment is mine and was generated in a manner consistent with this document, the course academic policy on the course website, and the UMass Lowell academic code.

Date: 02-April-2026
Names: Shades Meyers, Luca Azevedo, Miguel Echeverry, Marvens Luc
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:habit_quest/database/app_database.dart';
import 'package:habit_quest/repositories/habit_repository.dart';
import 'package:sqlite_inspector/sqlite_inspector.dart';

import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:habit_quest/services/notification_service.dart';

import 'package:onboarding_overlay/onboarding_overlay.dart';
import 'package:habit_quest/services/tutorial_manager.dart';

import 'package:habit_quest/providers/theme_provider.dart';
import 'package:habit_quest/providers/habit_provider.dart';
import 'package:habit_quest/providers/habit_record_provider.dart';
import 'package:provider/provider.dart';

import 'package:habit_quest/screens/home_page_screen.dart';
import 'package:habit_quest/screens/extended_graph_screen.dart';
import 'screens/manage_habits_screen.dart';
import 'package:habit_quest/screens/habit_history_screen.dart';
import 'package:habit_quest/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz_data.initializeTimeZones();
  final String timeZoneName =
      await FlutterNativeTimezoneLatest.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  await NotificationService().initNotification();

  if (kDebugMode) {
    await SqliteInspector.start();
  }

  final database = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .addMigrations(AppDatabase.migrations)
      .build();

  HabitRepository.initialize(
    habitDao: database.habitDao,
    habitRecordDao: database.habitRecordDao,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => HabitRecordProvider()),
      ],
      child: const HabitQuestApp(),
    ),
  );
}

class HabitQuestApp extends StatelessWidget {
  const HabitQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Habit Quest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: themeProvider.flutterThemeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePageScreen(),
        '/extended_graph': (context) => const ExtendedGraphScreen(),
        '/manage_habits': (context) => const ManageHabitsScreen(),
        '/habit_history': (context) => const HabitHistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      builder: (context, child) {
        // We use TutorialManager.overlayKey here so TutorialManager can insert
        // the controls OverlayEntry directly into this overlay via
        // overlayKey.currentState.a
        //
        // Why this works: showFromIndex() inserts the spotlight as a new entry
        // in this overlay. TutorialManager._syncControls() is always called
        // afterwards (via addPostFrameCallback), so the controls entry is
        // inserted LAST — making it the topmost entry, above the spotlight veil,
        // and therefore always visible and tappable regardless of HitTestBehavior.
        return Overlay(
          key: TutorialManager.overlayKey,
          initialEntries: [
            OverlayEntry(
              builder: (context) => Onboarding(
                key: TutorialManager.onboardingKey,
                steps: TutorialManager.getSteps(context),
                child: Focus(
                  focusNode: TutorialManager.fullScreenNode,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}