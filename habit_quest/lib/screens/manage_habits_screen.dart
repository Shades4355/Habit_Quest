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

// ==================== MANAGE HABITS SCREEN ====================

class ManageHabitsScreen extends StatelessWidget {
  const ManageHabitsScreen({super.key});

  Widget _currentHabitsList(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    if (habitProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final habits = habitProvider.activeHabits;
    if (habits.isEmpty) {
      return const Center(child: Text('No active habits yet.'));
    }

    return ListView.builder(
      // Pushes the list up so it's not hidden behind the FloatingActionButton
      padding: const EdgeInsets.only(bottom: 100, top: 10),
      itemCount: habits.length,
      itemBuilder: (ctx, i) => ListTile(
        // Circle with Importance level
        leading: CircleAvatar(
          backgroundColor: habits[i].importanceLevel > 0 ? Colors.green : Colors.red,
          child: Text('${habits[i].importanceLevel}'),
        ),
        
        // Habit Name
        title: Text(habits[i].habitName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Edit Button
            EditButton(
              editInterface: EditHabitInterfacePopUp(habit: habits[i]),
            ),

            // Delete Button
            DeleteButton(
              onDelete: () async {
                await context.read<HabitProvider>().removeHabit(habits[i]);
              },
              deleteContext: DeleteContext.habit,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      // The "Manage Habits" screen will display the text "Manage Habits" at the top.
      appBar: AppBar(title: const Text('Manage Habits')),
      // The "Manage Habits" screen will display all current habits.
      body: _currentHabitsList(context),
      // The "Manage Habits" screen will include the ability to add new habits... button at the bottom center.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // This button will bring up the "Add Habit" interface.
          await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true, // <-- Added this
              builder: (ctx) {
                // <-- Added dynamic bottom padding
                final bottomPadding = MediaQuery.of(ctx).padding.bottom;
                return Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: const AddHabitWizardPopUp(),
                );
              });
        },
        label: const Text('Add New Habit'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}