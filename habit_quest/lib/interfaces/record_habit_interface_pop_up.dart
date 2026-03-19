import 'package:flutter/material.dart';

import 'package:habit_quest/widgets/date_picker.dart';
import 'package:habit_quest/widgets/time_picker.dart';

import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/repositories/habit_repository.dart';


// --- Record Habit Interface [cite: 33] ---
class RecordHabitInterfacePopUp extends StatefulWidget {
  const RecordHabitInterfacePopUp({super.key});

  @override
  State<RecordHabitInterfacePopUp> createState() => _RecordHabitInterfacePopUpState();
}

class _RecordHabitInterfacePopUpState extends State<RecordHabitInterfacePopUp> {
  int? _selectedHabitId;

  HabitRepository get _habitRepo => HabitRepository.instance;

  Future<void> _saveSelection() async {
    final selectedHabitId = _selectedHabitId;
    if (selectedHabitId == null) {
      return;
    }

    await _habitRepo.toggleCompletedToday(selectedHabitId);

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit recorded for today')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding for bottom sheet to avoid keyboard overlap if necessary
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The prompt will display "Record A Habit"[cite: 36].
          const Text('Record A Habit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          // Allow user to select a date[cite: 38].
          // Defaults to current day[cite: 39]. Users can select from pop-up calendar[cite: 43].
          DatePicker(),
          // ListTile(
          //   leading: const Icon(Icons.calendar_today),
          //   title: const Text('Date: Today (Placeholder)'),
          //   trailing: const Icon(Icons.edit),
          //   onTap: () {
          //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Date Picker Pop-up')));
          //   },
          // ),
          // Allow selecting a time[cite: 45]. Defaults to current time[cite: 46].
          TimePicker(),
          
          // ListTile(
          //   leading: const Icon(Icons.access_time),
          //   title: const Text('Time: Now (Placeholder)'),
          //   trailing: const Icon(Icons.edit),
          //   onTap: () {
          //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Time Picker Pop-up')));
          //   },
          // ),
          const SizedBox(height: 20),
          // The interface will prompt the User for the completed habit[cite: 47].
          const Text('Select Habit Completed:'),
          // The User will select a habit from a drop down list of all current habits[cite: 49].
          FutureBuilder<List<Habit>>(
            future: _habitRepo.getActiveHabits(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                );
              }

              final habits = snapshot.data ?? [];
              final selectableHabits = habits.where((habit) => habit.id != null).toList();

              if (selectableHabits.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No active habits available.'),
                );
              }

              final ids = selectableHabits.map((habit) => habit.id!).toSet();
              final currentValue = ids.contains(_selectedHabitId) ? _selectedHabitId : null;

              return DropdownButton<int>(
                isExpanded: true,
                value: currentValue,
                hint: const Text('Choose a habit...'),
                items: selectableHabits
                    .map(
                      (habit) => DropdownMenuItem<int>(
                        value: habit.id,
                        child: Text(habit.habitName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHabitId = value;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // The interface will have a "Cancel" button[cite: 54].
              // It closes the interface without saving and returns to Homepage[cite: 55, 56].
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              // The interface will have a "save" button[cite: 50].
              // It saves the habit, updates score, closes interface, returns to Homepage[cite: 51, 52, 53].
              ElevatedButton(
                onPressed: _selectedHabitId == null ? null : _saveSelection,
                child: const Text('Save Record'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
