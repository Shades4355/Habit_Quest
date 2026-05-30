import 'package:flutter/material.dart';

// Interfaces
import "package:habit_quest/interfaces/app_drawer.dart";
import 'package:habit_quest/interfaces/edit_habit_interface_pop_up.dart';
import 'package:habit_quest/interfaces/add_habit_wizard_pop_up.dart';

// Widgets
import 'package:habit_quest/widgets/edit_button.dart';
import 'package:habit_quest/widgets/delete_button.dart';

// Providers
import 'package:provider/provider.dart';
import 'package:habit_quest/providers/habit_provider.dart';
import 'package:habit_quest/services/tutorial_manager.dart';

class ManageHabitsScreen extends StatelessWidget {
  const ManageHabitsScreen({super.key});

  Widget _body(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    // KEY FIX: Focus(manageHabitsListNode) is kept permanently attached by placing
    // it in a Stack. We restrict its height to the top portion of the screen so that
    // the tutorial plugin has enough space below to render the text box without clipping.
    return Stack(
      children: [
        Positioned.fill(
          child: Builder(
            builder: (context) {
              if (habitProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final habits = habitProvider.activeHabits;

              if (habits.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 64, color: colorScheme.outlineVariant),
                      const SizedBox(height: 16),
                      Text(
                        'No active habits yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the button below to add your first habit.',
                        style:
                            TextStyle(fontSize: 13, color: colorScheme.outline),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                // itemCount: habits.length + 1,
                itemCount: habits.length,
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: TutorialManager.isTutorialActive,
                      builder: (ctx, isActive, _) {
                        if (!isActive) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                          child: Text(
                            'These are your active habits. Tap the pencil to edit or the trash to delete. The number badge shows the importance level.',
                            style: TextStyle(fontSize: 13, color: colorScheme.outline),
                          ),
                        );
                      },
                    );
                  }
                  final habit = habits[i - 1];
                  final isPositive = habit.importanceLevel > 0;
                  // final badgeColor = isPositive
                  //     ? Colors.green
                  //     : Colors.red;
                  final badgeColor = Colors.white;
                  final badgeBg =
                      isPositive ? Colors.green : Colors.red;

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                          color: colorScheme.outlineVariant, width: 1),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: badgeBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${habit.importanceLevel}',
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        habit.habitName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        isPositive ? 'Building habit' : 'Breaking habit',
                        style:
                            TextStyle(fontSize: 12, color: colorScheme.outline),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EditButton(
                            editInterface: EditHabitInterfacePopUp(habit: habit),
                          ),
                          DeleteButton(
                            onDelete: () async {
                              await context.read<HabitProvider>().removeHabit(habit);
                            },
                            deleteContext: DeleteContext.habit,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // The dummy focus target that highlights the top area of the list
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          height: 140,
          child: IgnorePointer(
            child: Focus(
              focusNode: TutorialManager.manageHabitsListNode,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Manage Habits'),
        leading: Focus(
          focusNode: TutorialManager.menuNode,
          child: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(ctx).openDrawer();
                // THE NATIVE HANDSHAKE
                if (TutorialManager.isTutorialActive.value) {
                  TutorialManager.nextStep();
                }
              },
            ),
          ),
        ),
      ),
      body: _body(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Focus(
        focusNode: TutorialManager.addHabitNode,
        child: FloatingActionButton.extended(
          onPressed: () async {
            // THE NATIVE HANDSHAKE
            if (TutorialManager.isTutorialActive.value) {
              TutorialManager.nextStep();
            }
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (ctx) {
                final bottomPadding = MediaQuery.of(ctx).padding.bottom;
                return Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: const AddHabitWizardPopUp(),
                );
              },
            );
          },
          label: const Text('Add New Habit'),
          icon: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}