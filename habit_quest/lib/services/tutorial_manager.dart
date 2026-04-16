import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialManager {
  // I use this key to control the tutorial overlay from anywhere in my app
  static final GlobalKey<OnboardingState> onboardingKey = GlobalKey<OnboardingState>();
  
  // I keep track of my skip button so I can remove it later
  static OverlayEntry? _skipButtonEntry;

  static final FocusNode welcomeNode = FocusNode(debugLabel: 'welcome');
  static final FocusNode menuNode = FocusNode(debugLabel: 'menu');
  static final FocusNode drawerManageHabitsNode = FocusNode(debugLabel: 'manage_habits');
  static final FocusNode addHabitNode = FocusNode(debugLabel: 'add_habit');

  static List<FocusNode> get focusNodes => [
    welcomeNode,
    menuNode,
    drawerManageHabitsNode,
    addHabitNode,
  ];

  static Future<void> checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_tutorial') ?? false;
    
    if (!hasSeen) {
      // I give the screen a tiny delay to finish loading before starting the tutorial
      Future.delayed(const Duration(milliseconds: 800), () {
        onboardingKey.currentState?.show();
        _showSkipButton(); // Spawns my floating button on top of the dark curtain!
        prefs.setBool('has_seen_tutorial', true);
      });
    }
  }

  // I use BuildContext here so I can safely navigate the user before resetting
  static Future<void> resetTutorial(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tutorial', false);
    
    if (context.mounted) {
      // Navigating back triggers the Home screen to load, which naturally runs my checkAndShowTutorial
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  // I use this helper to spawn my skip button at the very top of the UI stack
  static void _showSkipButton() {
    if (_skipButtonEntry != null) return;
    final context = onboardingKey.currentContext;
    if (context == null) return;

    _skipButtonEntry = OverlayEntry(
      builder: (context) => SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              color: Colors.transparent,
              child: ElevatedButton.icon(
                onPressed: endTutorial,
                icon: const Icon(Icons.skip_next, size: 18),
                label: const Text('Skip Tutorial', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                  elevation: 6,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // I use a microtask to insert my button slightly after the tutorial overlay draws, 
    // guaranteeing my button sits on the absolute top layer!
    Future.microtask(() {
      Overlay.of(context).insert(_skipButtonEntry!);
    });
  }

  static void _hideSkipButton() {
    _skipButtonEntry?.remove();
    _skipButtonEntry = null;
  }

  // I call this when the user explicitly hits skip, or finishes the tutorial early
  static void endTutorial() {
    _hideSkipButton();
    onboardingKey.currentState?.hide(); 
  }

  static List<OnboardingStep> getSteps(BuildContext context) {
    return [
      OnboardingStep(
        focusNode: welcomeNode,
        titleText: 'Welcome to Habit Quest!',
        bodyText: 'The habit tracker app that will help you manage habits you want to either start or break, rewarding you with points every time you do! If there\'s a bad habit, it will take points away instead!\n\n(Tap anywhere to continue)',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        margin: const EdgeInsets.all(16),
        overlayBehavior: HitTestBehavior.translucent, 
        onTapCallback: (TapArea area, VoidCallback next, VoidCallback close) {
          // For my welcome message, tapping anywhere is fine
          next();
        },
      ),
      OnboardingStep(
        focusNode: menuNode,
        titleText: 'Dashboard & Navigation',
        bodyText: 'This is currently the home screen dashboard. Let\'s go to the habit manager to get started. Just tap here!',
        shape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent, 
        onTapCallback: (TapArea area, VoidCallback next, VoidCallback close) {
          // I'm forcing the user to tap exactly inside the highlighted hole to proceed!
          if (area == TapArea.hole) {
            Future.delayed(const Duration(milliseconds: 400), next);
          }
        },
      ),
      OnboardingStep(
        focusNode: drawerManageHabitsNode,
        titleText: 'Habit Manager',
        bodyText: 'Tap here and on the option that says "Manage Habits".',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (TapArea area, VoidCallback next, VoidCallback close) {
          if (area == TapArea.hole) {
            Future.delayed(const Duration(milliseconds: 500), next);
          }
        },
      ),
      OnboardingStep(
        focusNode: addHabitNode,
        titleText: 'Create a Habit',
        bodyText: 'Let\'s add a new habit to get started. Tap this button to configure a new habit.',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (TapArea area, VoidCallback next, VoidCallback close) {
          if (area == TapArea.hole) {
            _hideSkipButton(); // I hide the skip button here because the tutorial is officially over
            next(); 
          }
        },
      ),
    ];
  }
}