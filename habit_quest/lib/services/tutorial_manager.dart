import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialManager {
  static final GlobalKey<OnboardingState> onboardingKey =
      GlobalKey<OnboardingState>();

  static final GlobalKey<OverlayState> overlayKey =
      GlobalKey<OverlayState>();

  static final ValueNotifier<bool> isTutorialActive =
      ValueNotifier<bool>(false);
  static final ValueNotifier<int> currentTutorialStep =
      ValueNotifier<int>(-1);

  static bool _isProcessing = false;
  static OverlayEntry? _controlsEntry;

  // Steps requiring the explicit "Next" button
  static final Set<int> stepsRequiringNextButton = {7, 12, 17};

  // ── Focus nodes ───────────────────────────────────────────────────────────

  static final FocusNode welcomeNode = FocusNode(debugLabel: 'welcome');
  static final FocusNode menuNode = FocusNode(debugLabel: 'menu');
  static final FocusNode drawerHomeNode = FocusNode(debugLabel: 'drawer_home');
  static final FocusNode drawerManageHabitsNode = FocusNode(debugLabel: 'manage_habits');
  static final FocusNode drawerHistoryNode = FocusNode(debugLabel: 'drawer_history');
  static final FocusNode addHabitNode = FocusNode(debugLabel: 'add_habit_fab');
  static final FocusNode logActivityNode = FocusNode(debugLabel: 'log_activity_fab');
  static final FocusNode wizardPanelNode = FocusNode(debugLabel: 'wizard_panel');
  static final FocusNode manageHabitsListNode = FocusNode(debugLabel: 'manage_habits_list');
  static final FocusNode recordPanelNode = FocusNode(debugLabel: 'record_panel');
  static final FocusNode recordDropdownNode = FocusNode(debugLabel: 'record_dropdown');
  static final FocusNode recordSaveNode = FocusNode(debugLabel: 'record_save');
  static final FocusNode historyItemNode = FocusNode(debugLabel: 'history_item');
  static final FocusNode fullScreenNode = FocusNode(debugLabel: 'full_screen');

  static List<FocusNode> get focusNodes => [
        welcomeNode, menuNode, drawerHomeNode, drawerManageHabitsNode,
        drawerHistoryNode, addHabitNode, logActivityNode, wizardPanelNode,
        manageHabitsListNode, recordPanelNode, recordDropdownNode,
        recordSaveNode, historyItemNode, fullScreenNode,
      ];

  // ── Controls overlay management ───────────────────────────────────────────

  static void _syncControls() {
    _controlsEntry?.remove();
    _controlsEntry = null;

    if (!isTutorialActive.value) return;
    final overlay = overlayKey.currentState;
    if (overlay == null) return;

    _controlsEntry = OverlayEntry(builder: _buildControlsWidget);
    overlay.insert(_controlsEntry!);
  }

  static Widget _buildControlsWidget(BuildContext ctx) {
    final step = currentTutorialStep.value;
    final cs = Theme.of(ctx).colorScheme;
    final needsNext = stepsRequiringNextButton.contains(step);

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          children: [
            // Skip button (Top Right)
            Positioned(
              top: 12,
              right: 12,
              child: _TutorialChip(
                label: 'Skip Tutorial',
                icon: Icons.close_rounded,
                filled: false,
                colorScheme: cs,
                onTap: endTutorial,
              ),
            ),
            // Pulsing Next button (Bottom Right - Shifted up to clear Save button)
            if (needsNext)
              Positioned(
                bottom: 32, 
                right: 20,
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

        WidgetsBinding.instance.addPostFrameCallback((_) => _syncControls());
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

  static void nextStep() {
    if (_isProcessing) return;
    _isProcessing = true;

    currentTutorialStep.value++;

    if (currentTutorialStep.value >= 18) {
      endTutorial();
    } else {
      onboardingKey.currentState?.hide();
      Future.delayed(const Duration(milliseconds: 400), () {
        onboardingKey.currentState?.showFromIndex(currentTutorialStep.value);
        WidgetsBinding.instance.addPostFrameCallback((_) => _syncControls());
      });
    }
    Future.delayed(const Duration(milliseconds: 800), () => _isProcessing = false);
  }

  static void endTutorial() {
    currentTutorialStep.value = -1;
    isTutorialActive.value = false;
    _isProcessing = false;
    Future.delayed(Duration.zero, () {
      onboardingKey.currentState?.hide();
      _controlsEntry?.remove();
      _controlsEntry = null;
    });
  }

  // ── Tutorial steps ────────────────────────────────────────────────────────

  static List<OnboardingStep> getSteps(BuildContext context) {
    return [
      OnboardingStep(
        focusNode: welcomeNode,
        titleText: 'Welcome to Habit Quest!',
        bodyText: 'The habit tracker that helps you build habits and rewards you with points!\n\nTap the highlighted graph to begin.',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.opaque,
        onTapCallback: (area, next, close) { if (area == TapArea.hole) nextStep(); },
      ),
      OnboardingStep(
        focusNode: menuNode,
        titleText: 'Dashboard & Navigation',
        bodyText: 'Let\'s head to the Habit Manager. Tap the menu icon!',
        shape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {}, // Blocks tap-to-advance
      ),
      OnboardingStep(
        focusNode: drawerManageHabitsNode,
        titleText: 'Habit Manager',
        bodyText: 'Tap "Manage Habits" to open the habit management screen.',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {}, // Blocks tap-to-advance
      ),
      OnboardingStep(
        focusNode: addHabitNode,
        titleText: 'Create a Habit',
        bodyText: 'Let\'s add a new habit. Tap the highlighted button!',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {}, // Blocks tap-to-advance
      ),
      OnboardingStep(
        focusNode: wizardPanelNode,
        titleText: 'Start or Break?',
        bodyText: 'Choose "START", then press the wizard\'s Next button.',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {}, // Blocks tap-to-advance
      ),
      OnboardingStep(
        focusNode: wizardPanelNode,
        titleText: 'Name Your Habit',
        bodyText: 'Type a name, then press the Next button.',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {}, // <--- This fixes the "skip" issue
      ),
      OnboardingStep(
        focusNode: wizardPanelNode,
        titleText: 'Set the Importance',
        bodyText: 'Scale from 1–5. Press Finish & Save to create it!',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {}, // Blocks tap-to-advance
      ),
      OnboardingStep(
        focusNode: manageHabitsListNode,
        titleText: '🎉 Your Habit is Saved!',
        bodyText: 'Your habit is in the list. Tap Next → to continue.',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {}, // Wait for floating Next button
      ),
      OnboardingStep(
        focusNode: menuNode,
        titleText: 'Return Home',
        bodyText: 'Let\'s head back home. Tap the menu.',
        shape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      OnboardingStep(
        focusNode: drawerHomeNode,
        titleText: 'Go Home',
        bodyText: 'Tap "Home".',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      OnboardingStep(
        focusNode: logActivityNode,
        titleText: 'Log Activity',
        bodyText: 'Let\'s record an activity. Tap the button.',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      OnboardingStep(
        focusNode: recordDropdownNode,
        titleText: 'Select Your Habit',
        bodyText: 'Pick your habit from the dropdown.',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      OnboardingStep(
        focusNode: recordPanelNode,
        titleText: 'Select Date & Time',
        bodyText: 'You can change the time here. Tap Next → when done.',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {}, // Wait for floating Next button
      ),
      OnboardingStep(
        focusNode: recordSaveNode,
        titleText: 'Save the Record',
        bodyText: 'Tap Save Record to log it!',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      OnboardingStep(
        focusNode: welcomeNode,
        titleText: 'Watch the Graph!',
        bodyText: 'Your activity appears on the graph! Tap it to continue.',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        overlayBehavior: HitTestBehavior.opaque,
        onTapCallback: (area, next, close) { if (area == TapArea.hole) nextStep(); },
      ),
      OnboardingStep(
        focusNode: menuNode,
        titleText: 'One Last Stop',
        bodyText: 'Tap the menu one final time.',
        shape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      OnboardingStep(
        focusNode: drawerHistoryNode,
        titleText: 'Habit History',
        bodyText: 'Tap "Habit History".',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
      ),
      OnboardingStep(
        focusNode: historyItemNode,
        titleText: '✅ Tutorial Complete!',
        bodyText: 'Tap the entry to finish.',
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        overlayBehavior: HitTestBehavior.opaque,
        onTapCallback: (area, next, close) { if (area == TapArea.hole) endTutorial(); },
      ),
    ];
  }
}

// ── Pulsing Tutorial Chip ──────────────────────────────────────────────────

class _TutorialChip extends StatefulWidget {
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
  State<_TutorialChip> createState() => _TutorialChipState();
}

class _TutorialChipState extends State<_TutorialChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Next button uses Tertiary color to contrast with the Save button underneath
    final baseColor = widget.filled 
        ? widget.colorScheme.tertiary 
        : widget.colorScheme.surface.withOpacity(0.95);
        
    final contentColor = widget.filled 
        ? widget.colorScheme.onTertiary 
        : widget.colorScheme.onSurface;

    return ScaleTransition(
      scale: widget.filled ? _scale : const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: contentColor.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.iconTrailing
                ? [
                    Text(widget.label, style: _textStyle(contentColor)),
                    const SizedBox(width: 8),
                    Icon(widget.icon, size: 20, color: contentColor),
                  ]
                : [
                    Icon(widget.icon, size: 20, color: contentColor),
                    const SizedBox(width: 8),
                    Text(widget.label, style: _textStyle(contentColor)),
                  ],
          ),
        ),
      ),
    );
  }

  TextStyle _textStyle(Color color) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: color,
      );
}