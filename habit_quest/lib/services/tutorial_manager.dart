import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialManager {
  static final GlobalKey<OnboardingState> onboardingKey =
      GlobalKey<OnboardingState>();

  // Key for the custom Overlay widget in main.dart.
  // We insert the controls entry into THIS overlay so we control the stacking order.
  static final GlobalKey<OverlayState> overlayKey =
      GlobalKey<OverlayState>();

  static final ValueNotifier<bool> isTutorialActive =
      ValueNotifier<bool>(false);
  static final ValueNotifier<int> currentTutorialStep =
      ValueNotifier<int>(-1);

  static bool _isProcessing = false;

  // The overlay entry that renders Skip / Next buttons.
  // It is (re)inserted into overlayKey AFTER every showFromIndex() call so that
  // it is always the topmost entry — above the spotlight veil.
  static OverlayEntry? _controlsEntry;

  // Steps where NO native UI widget calls nextStep() on its own.
  // The floating Next → button is shown only for these indices.
  //
  //  Step  7  – habit list confirmation (no tappable element to advance)
  //  Step 12  – date/time: system pickers open above the app; user needs an
  //              explicit "done" action to tell the tutorial they're finished
  //
  // Steps intentionally excluded:
  //  4,5,6  – wizard's own Next/Finish button calls nextStep()
  //  11     – dropdown auto-advances via onChanged → nextStep()
  //  13     – Save Record button calls nextStep()
  //  0,14   – graph tap (opaque overlay, TapArea.hole)
  //  17     – history item tap ends tutorial
  //  1,8,15 – AppBar menu button calls nextStep()
  //  2,9,16 – Drawer ListTile onTap calls nextStep()
  //  3,10   – FAB onPressed calls nextStep()
  static final Set<int> stepsRequiringNextButton = {7, 12, 17};

  // ── Focus nodes ───────────────────────────────────────────────────────────

  static final FocusNode welcomeNode = FocusNode(debugLabel: 'welcome');
  static final FocusNode menuNode = FocusNode(debugLabel: 'menu');
  static final FocusNode drawerHomeNode =
      FocusNode(debugLabel: 'drawer_home');
  static final FocusNode drawerManageHabitsNode =
      FocusNode(debugLabel: 'manage_habits');
  static final FocusNode drawerHistoryNode =
      FocusNode(debugLabel: 'drawer_history');
  static final FocusNode addHabitNode =
      FocusNode(debugLabel: 'add_habit_fab');
  static final FocusNode logActivityNode =
      FocusNode(debugLabel: 'log_activity_fab');
  static final FocusNode wizardPanelNode =
      FocusNode(debugLabel: 'wizard_panel');
  static final FocusNode manageHabitsListNode =
      FocusNode(debugLabel: 'manage_habits_list');
  static final FocusNode recordPanelNode =
      FocusNode(debugLabel: 'record_panel');
  static final FocusNode recordDropdownNode =
      FocusNode(debugLabel: 'record_dropdown');
  static final FocusNode recordSaveNode =
      FocusNode(debugLabel: 'record_save');
  static final FocusNode historyItemNode =
      FocusNode(debugLabel: 'history_item');
  static final FocusNode fullScreenNode =
      FocusNode(debugLabel: 'full_screen');

  static List<FocusNode> get focusNodes => [
        welcomeNode,
        menuNode,
        drawerHomeNode,
        drawerManageHabitsNode,
        drawerHistoryNode,
        addHabitNode,
        logActivityNode,
        wizardPanelNode,
        manageHabitsListNode,
        recordPanelNode,
        recordDropdownNode,
        recordSaveNode,
        historyItemNode,
        fullScreenNode,
      ];

  // ── Controls overlay management ───────────────────────────────────────────

  /// Removes the old controls entry and inserts a fresh one at the TOP of the
  /// overlay stack. Always called via addPostFrameCallback so it runs AFTER
  /// showFromIndex() has inserted/updated the spotlight entry.
  static void _syncControls() {
    _controlsEntry?.remove();
    _controlsEntry = null;

    if (!isTutorialActive.value) return;
    final overlay = overlayKey.currentState;
    if (overlay == null) return;

    _controlsEntry = OverlayEntry(builder: _buildControlsWidget);
    overlay.insert(_controlsEntry!);
  }

  /// Builds the Skip + (optional) Next buttons rendered in the controls entry.
  /// Called with the Overlay's BuildContext, which inherits Theme & MediaQuery
  /// from MaterialApp — so Theme.of(ctx) and SafeArea both work correctly.
  static Widget _buildControlsWidget(BuildContext ctx) {
    final step = currentTutorialStep.value;
    final cs = Theme.of(ctx).colorScheme;
    final needsNext = stepsRequiringNextButton.contains(step);

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          children: [
            // Always-visible Skip button
            Positioned(
              top: 8,
              right: 12,
              child: _TutorialChip(
                label: 'Skip Tutorial',
                icon: Icons.close_rounded,
                filled: false,
                colorScheme: cs,
                onTap: endTutorial,
              ),
            ),
            // Floating Next button — only for steps with no native advance action
            if (needsNext)
              Positioned(
                bottom: 24,
                right: 16,
                child: _TutorialChip(
                  label: 'Next',
                  icon: Icons.arrow_forward_rounded,
                  iconTrailing: true,
                  filled: true,
                  colorScheme: cs,
                  onTap: nextStep,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Tutorial lifecycle ────────────────────────────────────────────────────

  static Future<void> checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_tutorial') ?? false;

    if (!hasSeen) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _isProcessing = false;
        currentTutorialStep.value = 0;
        isTutorialActive.value = true;
        onboardingKey.currentState?.show();

        // Insert controls AFTER the spotlight (postFrameCallback ensures ordering).
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _syncControls());

        prefs.setBool('has_seen_tutorial', true);
      });
    }
  }

  static Future<void> resetTutorial(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tutorial', false);

    _isProcessing = false;
    endTutorial();

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  /// Advance the tutorial by one step. Called by native UI widgets (drawer
  /// taps, FAB presses, wizard buttons, etc.) and by the floating Next button
  /// for steps in [stepsRequiringNextButton].
  static void nextStep() {
    if (_isProcessing) return;
    _isProcessing = true;

    currentTutorialStep.value++;

    if (currentTutorialStep.value >= 18) {
      endTutorial();
    } else {
      onboardingKey.currentState?.hide();

      // Give native UI 400 ms to animate (e.g. drawer slide) before the
      // next spotlight appears.
      Future.delayed(const Duration(milliseconds: 400), () {
        onboardingKey.currentState
            ?.showFromIndex(currentTutorialStep.value);

        // Re-insert controls AFTER showFromIndex() so our entry is always
        // the topmost entry in the overlay — above the spotlight veil.
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _syncControls());
      });
    }

    Future.delayed(
        const Duration(milliseconds: 800), () => _isProcessing = false);
  }

  static void endTutorial() {
    currentTutorialStep.value = -1;
    isTutorialActive.value = false;
    _isProcessing = false;
    // Defer the cleanup to the next event loop tick completely outside of the
    // Flutter frame rendering pipeline. This prevents 'debugNeedsLayout' assertions
    // that can occur if overlay entries are manipulated mid- or post-frame.
    Future.delayed(Duration.zero, () {
      onboardingKey.currentState?.hide();
      _controlsEntry?.remove();
      _controlsEntry = null;
    });
  }

  // ── Tutorial steps ────────────────────────────────────────────────────────

  static List<OnboardingStep> getSteps(BuildContext context) {
    return [
      // Step 0 ── Welcome
      OnboardingStep(
        focusNode: welcomeNode,
        titleText: 'Welcome to Habit Quest!',
        bodyText:
            'The habit tracker that helps you build habits you want to start — or break ones you want to stop — and rewards you with points!\n\nTap the highlighted graph to begin.',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.opaque,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) nextStep();
        },
      ),
      // Step 1 ── Open menu (home)
      OnboardingStep(
        focusNode: menuNode,
        titleText: 'Dashboard & Navigation',
        bodyText:
            'Let\'s head to the Habit Manager. Tap the highlighted menu icon!',
        shape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 2 ── Manage Habits drawer item
      OnboardingStep(
        focusNode: drawerManageHabitsNode,
        titleText: 'Habit Manager',
        bodyText: 'Tap "Manage Habits" to open the habit management screen.',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 3 ── Add Habit FAB
      OnboardingStep(
        focusNode: addHabitNode,
        titleText: 'Create a Habit',
        bodyText: 'Let\'s add a new habit. Tap the highlighted button!',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 4 ── Wizard page 1: Start or Break  [native: wizard Next button]
      OnboardingStep(
        focusNode: wizardPanelNode,
        titleText: 'Start or Break?',
        bodyText:
            'Choose whether to start a new habit or break a bad one. Tap "START", then press the wizard\'s Next button.',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 5 ── Wizard page 2: Name  [native: wizard Next button]
      OnboardingStep(
        focusNode: wizardPanelNode,
        titleText: 'Name Your Habit',
        bodyText:
            'Type something like "doing homework". Don\'t worry, you can remove it later! Press the wizard\'s Next button when ready.',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 6 ── Wizard page 3: Importance  [native: wizard Finish & Save button]
      OnboardingStep(
        focusNode: wizardPanelNode,
        titleText: 'Set the Importance',
        bodyText:
            'Scale from 1–5: 1 is "once in a while", 5 is "utmost importance". For breaking habits, 5 means more points lost. Press Finish & Save to create it!',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 7 ── Habit list confirmation  [floating Next → button]
      OnboardingStep(
        focusNode: manageHabitsListNode,
        titleText: '🎉 Your Habit is Saved!',
        bodyText:
            'Your new habit now appears right here in this list. This is where all your active habits live — you can edit or delete them any time.\n\nTap Next → to continue.',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 8 ── Open menu (manage habits screen)  [native: menu button]
      OnboardingStep(
        focusNode: menuNode,
        titleText: 'Return Home',
        bodyText:
            'Habit added! Let\'s head back to the home screen. Tap the menu.',
        shape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 9 ── Home drawer item  [native: drawer ListTile]
      OnboardingStep(
        focusNode: drawerHomeNode,
        titleText: 'Go Home',
        bodyText: 'Tap "Home".',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 10 ── Log Activity FAB  [native: FAB onPressed]
      OnboardingStep(
        focusNode: logActivityNode,
        titleText: 'Log Activity',
        bodyText:
            'Let\'s record some activity for the habit you just created. Tap the highlighted button.',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 11 ── Habit dropdown  [native: auto-advances via onChanged]
      OnboardingStep(
        focusNode: recordDropdownNode,
        titleText: 'Select Your Habit',
        bodyText:
            'Tap the dropdown and pick the habit you just created. The tutorial will move forward automatically when you select one.',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 12 ── Date / time pickers  [floating Next → button]
      OnboardingStep(
        focusNode: recordPanelNode,
        titleText: 'Select Date & Time',
        bodyText:
            'You can also change when the activity happened. These open system menus so the whole screen is illuminated.\n\nTap Next → when you\'re done.',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 13 ── Save record  [native: Save Record button]
      OnboardingStep(
        focusNode: recordSaveNode,
        titleText: 'Save the Record',
        bodyText:
            'Tap Save Record to log the activity. The tutorial continues automatically once saved!',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 14 ── Watch the graph  [native: graph tap]
      OnboardingStep(
        focusNode: welcomeNode,
        titleText: 'Watch the Graph!',
        bodyText:
            'Your activity now appears on the graph! Let\'s check the history next. Tap the highlighted graph to continue.',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.opaque,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) nextStep();
        },
      ),
      // Step 15 ── Open menu (home)  [native: menu button]
      OnboardingStep(
        focusNode: menuNode,
        titleText: 'One Last Stop',
        bodyText: 'Tap the menu one final time.',
        shape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 16 ── History drawer item  [native: drawer ListTile]
      OnboardingStep(
        focusNode: drawerHistoryNode,
        titleText: 'Habit History',
        bodyText: 'Tap "Habit History".',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      // Step 17 ── History item (tutorial complete)  [native: item tap]
      OnboardingStep(
        focusNode: historyItemNode,
        titleText: '✅ Tutorial Complete!',
        bodyText:
            'Here is today\'s activity safely logged! Tap the highlighted entry to finish the tutorial.',
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        overlayBehavior: HitTestBehavior.opaque,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) endTutorial();
        },
      ),
    ];
  }
}

// ── Tutorial chip button ───────────────────────────────────────────────────

class _TutorialChip extends StatelessWidget {
  const _TutorialChip({
    required this.label,
    required this.icon,
    required this.filled,
    required this.colorScheme,
    required this.onTap,
    this.iconTrailing = false,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final bool iconTrailing;

  @override
  Widget build(BuildContext context) {
    final contentColor = filled
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withOpacity(0.85);

    final iconWidget = Icon(icon, size: 16, color: contentColor);
    final labelWidget = Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: contentColor,
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: filled
              ? colorScheme.primary
              : colorScheme.surface.withOpacity(0.93),
          borderRadius: BorderRadius.circular(24),
          border: filled
              ? null
              : Border.all(
                  color: colorScheme.outline.withOpacity(0.4),
                  width: 1,
                ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: iconTrailing
              ? [labelWidget, const SizedBox(width: 6), iconWidget]
              : [iconWidget, const SizedBox(width: 6), labelWidget],
        ),
      ),
    );
  }
}