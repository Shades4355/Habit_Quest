import 'package:flutter/material.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/services/toast_service.dart';

import 'package:provider/provider.dart';
import 'package:habit_quest/providers/habit_provider.dart';
import 'package:habit_quest/services/tutorial_manager.dart';

enum HabitType { start, stop }

class AddHabitWizardPopUp extends StatefulWidget {
  const AddHabitWizardPopUp({super.key});
  @override
  State<AddHabitWizardPopUp> createState() => _AddHabitWizardPopUpState();
}

class _AddHabitWizardPopUpState extends State<AddHabitWizardPopUp> {
  int _currentDisplay = 1;
  String _habitName = '';
  HabitType _habitType = HabitType.start;
  double _importanceRating = 3.0;

  // We create a local node as a fallback when the tutorial is off
  final FocusNode _internalNode = FocusNode();

  @override
  void dispose() {
    _internalNode.dispose();
    super.dispose();
  }

  Future<void> _saveHabit(Habit newHabit) async {
    await context.read<HabitProvider>().addHabit(newHabit);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // FIX: Only use the Tutorial's node if the tutorial is actually running.
    // Otherwise, use our internal node so the UI doesn't "freeze".
    final effectiveNode = TutorialManager.isTutorialActive.value
        ? TutorialManager.wizardPanelNode
        : _internalNode;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Focus(
        focusNode: effectiveNode,
        child: SingleChildScrollView( // FIX: Prevents "Cannot hit test a render box with no size"
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Step 1: Start or Break ──────────────────────────────────
              if (_currentDisplay == 1) ...[
                Text(
                  'Add A New Habit (Step 1/3)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text('Are you trying to START or BREAK this habit?'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('START'),
                      selected: _habitType == HabitType.start,
                      onSelected: (_) =>
                          setState(() => _habitType = HabitType.start),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('BREAK'),
                      selected: _habitType == HabitType.stop,
                      onSelected: (_) =>
                          setState(() => _habitType = HabitType.stop),
                    ),
                  ],
                ),
              ],

              // ── Step 2: Name ────────────────────────────────────────────
              if (_currentDisplay == 2) ...[
                Text(
                  'Name Your Habit (Step 2/3)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  autofocus: true, // Automatically pops keyboard for better UX
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _habitName = val),
                ),
              ],

              // ── Step 3: Importance ──────────────────────────────────────
              if (_currentDisplay == 3) ...[
                Text(
                  'Habit Importance (Step 3/3)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Importance: ${_importanceRating.round()}',
                    style: const TextStyle(fontSize: 16)),
                Slider(
                  value: _importanceRating,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _importanceRating.round().toString(),
                  onChanged: (val) =>
                      setState(() => _importanceRating = val),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '1: Once in a while   ·   3: Most of the time   ·   5: Utmost importance',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Actions ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Only advance tutorial if active
                      if (TutorialManager.isTutorialActive.value) {
                        TutorialManager.nextStep();
                      }

                      if (_currentDisplay < 3) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() => _currentDisplay++);
                        return;
                      }

                      final habitName = _habitName.trim();
                      if (habitName.isEmpty) return;

                      final newHabit = Habit.newHabit(
                        habitName: habitName,
                        importanceLevel: _habitType == HabitType.start
                            ? _importanceRating.round()
                            : -_importanceRating.round(),
                        millisecondsSinceEpoch:
                            DateTime.now().millisecondsSinceEpoch,
                      );

                      await _saveHabit(newHabit);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ToastService.showSuccess(
                          '$habitName Saved with ${newHabit.importanceLevel} score',
                        );
                      }
                    },
                    child:
                        Text(_currentDisplay < 3 ? 'Next' : 'Finish & Save'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}