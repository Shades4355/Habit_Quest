import 'package:flutter/material.dart';

import 'package:habit_quest/repositories/habit_repository.dart';

import "package:habit_quest/interfaces/app_drawer.dart";
import 'package:habit_quest/interfaces/edit_habit_interface_pop_up.dart';
import 'package:habit_quest/interfaces/add_habit_wizard_pop_up.dart';

// ==================== MANAGE HABITS SCREEN ====================

class ManageHabitsScreen extends StatelessWidget {
  const ManageHabitsScreen({super.key});

  HabitRepository get _habitRepo => HabitRepository.instance;

  Widget _currentHabitsList() {
    return FutureBuilder(
      future: _habitRepo.getActiveHabits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final habits = snapshot.data ?? [];
        return ListView.builder(
          // Pushes the list up so it's not hidden behind the FloatingActionButton
          padding: const EdgeInsets.only(bottom: 100, top: 10), 
          itemCount: habits.length,
          itemBuilder: (ctx, i) => ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text(habits[i].habitName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => EditHabitInterfacePopUp(habit: habits[i])
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await habitRepo.archiveHabit(habits[i].id!);
                    // Refresh UI logic here if needed
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      // The "Manage Habits" screen will display the text "Manage Habits" at the top[cite: 70].
      appBar: AppBar(title: const Text('Manage Habits')),
      // The "Manage Habits" screen will display all current habits[cite: 72].
      body: _currentHabitsList(),
      // The "Manage Habits" screen will include the ability to add new habits... button at the bottom center[cite: 73, 74].
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // This button will bring up the "Add Habit" interface[cite: 75].
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (ctx) => AddHabitWizardPopUp()
          );
        },
        label: const Text('Add New Habit'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
