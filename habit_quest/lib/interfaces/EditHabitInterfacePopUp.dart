import 'package:flutter/material.dart';

// --- Edit Habit Interface [cite: 147] ---
class EditHabitInterfacePopUp extends StatelessWidget {
  const EditHabitInterfacePopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // The "Edit Habit" interface will display the text "Edit Habit" at the top[cite: 148].
      title: const Text('Edit Habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provide the User with the ability to change the habit's name[cite: 156].
          // Text field defaults to current name[cite: 157, 159].
          TextField(
            decoration: const InputDecoration(labelText: 'Habit Name'),
            controller: TextEditingController(text: 'Current Name Placeholder'),
          ),
          const SizedBox(height: 20),
          // Provide the User with the ability to change the importance[cite: 151].
          const Text('Change Importance:'),
          // Defaults to current importance[cite: 153].
          Slider(value: 3, min: 1, max: 5, divisions: 4, label: '3', onChanged: (val){}),
          const Text('Note: Changing importance only applies to future records[cite: 155].', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      actions: [
        // "Cancel" button closes without changes[cite: 160, 161].
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        // "Save" button saves changes and closes interface[cite: 163, 164, 165].
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Habit Updates Saved')));
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
