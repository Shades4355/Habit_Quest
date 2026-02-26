import 'package:flutter/material.dart';


// --- Record Habit Interface [cite: 33] ---
class RecordHabitInterfacePopUp extends StatelessWidget {
  const RecordHabitInterfacePopUp({super.key});

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
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date: Today (Placeholder)'),
            trailing: const Icon(Icons.edit),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Date Picker Pop-up')));
            },
          ),
          // Allow selecting a time[cite: 45]. Defaults to current time[cite: 46].
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Time: Now (Placeholder)'),
            trailing: const Icon(Icons.edit),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Time Picker Pop-up')));
            },
          ),
          const SizedBox(height: 20),
          // The interface will prompt the User for the completed habit[cite: 47].
          const Text('Select Habit Completed:'),
          // The User will select a habit from a drop down list of all current habits[cite: 49].
          DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Choose a habit...'),
            items: <String>['Habit A', 'Habit B', 'Habit C'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (_) {},
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
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Habit Recorded & Saved')));
                },
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
