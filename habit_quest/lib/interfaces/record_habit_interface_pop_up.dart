import 'package:flutter/material.dart';
import 'package:habit_quest/widgets/date_picker.dart';
import 'package:habit_quest/widgets/time_picker.dart';
import 'package:provider/provider.dart';
import 'package:habit_quest/providers/habit_provider.dart';
import 'package:habit_quest/providers/habit_record_provider.dart';
import 'package:habit_quest/services/tutorial_manager.dart';

class RecordHabitInterfacePopUp extends StatefulWidget {
  const RecordHabitInterfacePopUp({super.key});

  @override
  State<RecordHabitInterfacePopUp> createState() =>
      _RecordHabitInterfacePopUpState();
}

class _RecordHabitInterfacePopUpState
    extends State<RecordHabitInterfacePopUp> {
  int? _selectedHabitId;
  DateTime _date = DateTime.now();

  String get formattedDate =>
      '${_date.month.toString().padLeft(2, '0')}/${_date.day.toString().padLeft(2, '0')}/${_date.year}';

  Future<void> _saveSelection() async {
    final selectedHabitId = _selectedHabitId;
    if (selectedHabitId == null) return;

    await context
        .read<HabitRecordProvider>()
        .recordHabit(selectedHabitId, _date);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Habit recorded for $formattedDate'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final selectableHabits = habitProvider.activeHabits;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Focus(
        focusNode: TutorialManager.recordPanelNode,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Handle bar ─────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Title ───────────────────────────────────────────────────
            Text(
              'Record Activity',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: TutorialManager.isTutorialActive,
              builder: (ctx, isActive, _) {
                if (!isActive) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      'Log an occurrence for one of your habits. You can record for today or any date in the past.',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Date & Time ─────────────────────────────────────────────
            Text(
              'When did it happen?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                letterSpacing: 0.4,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: TutorialManager.isTutorialActive,
              builder: (ctx, isActive, _) {
                if (!isActive) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Tap the date or time below to change them — past dates are supported.',
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            DatePicker(
              onDateChanged: (date) => setState(() => _date = date),
            ),
            TimePicker(),
            const SizedBox(height: 20),

            // ── Habit dropdown ──────────────────────────────────────────
            Text(
              'Which habit?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),

            if (habitProvider.isLoading)
              const LinearProgressIndicator()
            else if (selectableHabits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No active habits available.',
                  style: TextStyle(color: colorScheme.outline),
                ),
              )
            else
              Focus(
                focusNode: TutorialManager.recordDropdownNode,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedHabitId,
                      hint: const Text('Choose a habit…'),
                      items: selectableHabits
                          .map((habit) => DropdownMenuItem<int>(
                                value: habit.id,
                                child: Text(habit.habitName),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedHabitId = value);
                        // Step 12 auto-advances when the user selects a habit.
                        // Step 12 is intentionally NOT in stepsRequiringNextButton,
                        // so no floating Next button competes with this call.
                        if (TutorialManager.isTutorialActive.value) {
                          TutorialManager.nextStep();
                        }
                      },
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 28),

            // ── Actions ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Focus(
                    focusNode: TutorialManager.recordSaveNode,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: const Text('Save Record'),
                      onPressed: _selectedHabitId == null
                          ? null
                          : () async {
                              // Native handshake — advance BEFORE pop so the
                              // spotlight transitions cleanly to the next screen.
                              if (TutorialManager.isTutorialActive.value) {
                                TutorialManager.nextStep();
                              }
                              await _saveSelection();
                            },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}