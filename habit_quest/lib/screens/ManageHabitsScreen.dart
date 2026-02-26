import 'package:flutter/material.dart';

import "../interfaces/AppDrawer.dart";
import '../interfaces/EditHabitInterfacePopUp.dart';
import '../interfaces/AddHabitWizardPopUp.dart';

// ==================== MANAGE HABITS SCREEN ====================

class ManageHabitsScreen extends StatelessWidget {
  const ManageHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      // The "Manage Habits" screen will display the text "Manage Habits" at the top[cite: 70].
      appBar: AppBar(title: const Text('Manage Habits')),
      // The "Manage Habits" screen will display all current habits[cite: 72].
      body: ListView.builder(
        itemCount: 5, // Placeholder count
        itemBuilder: (ctx, i) => ListTile(
          leading: CircleAvatar(child: Text('${i + 1}')), // Placeholder for score value
          title: Text('Current Habit Name ${i + 1}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Each habit will have an "Edit" button attached to its display[cite: 77].
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                // The "Edit" button will bring up the "Edit Habit" interface[cite: 79].
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => const EditHabitInterfacePopUp()
                  );
                },
              ),
              // Each habit will have a "Delete" button attached to its display[cite: 81].
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Delete Habit')));
                },
              ),
            ],
          ),
        ),
      ),
      // The "Manage Habits" screen will include the ability to add new habits... button at the bottom center[cite: 73, 74].
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // This button will bring up the "Add Habit" interface[cite: 75].
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (ctx) => const AddHabitWizardPopUp()
          );
        },
        label: const Text('Add New Habit'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
