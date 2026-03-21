import 'package:flutter/material.dart';

import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/repositories/habit_repository.dart';


class EditHabitInterfacePopUp extends StatefulWidget{
  const EditHabitInterfacePopUp({super.key, required this.habit});

  final Habit habit;

  @override
  State<EditHabitInterfacePopUp> createState() => _EditHabitInterfacePopUpState();
}

class _EditHabitInterfacePopUpState extends State<EditHabitInterfacePopUp> {
  late TextEditingController _habitNameController;
  late int _importanceLevel;

  HabitRepository get _habitRepo => HabitRepository.instance;

  @override
  void initState() {
    super.initState();
    _habitNameController = TextEditingController(text: widget.habit.habitName);
    _importanceLevel = widget.habit.importanceLevel;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Habit Name'),
            controller: _habitNameController,
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 20),
          const Text('Change Importance:'),
          Slider(
            value: _importanceLevel.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '$_importanceLevel',
            onChanged: (val) {
              setState(() {
                _importanceLevel = val.toInt();
              });
            },
          ),
          const Text('Note: Changing importance only applies to future records.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final updatedHabit = Habit(
              id: widget.habit.id,
              habitName: _habitNameController.text.isEmpty ? widget.habit.habitName : _habitNameController.text,
              importanceLevel: _importanceLevel,
              createdAtMilliseconds: widget.habit.createdAtMilliseconds,
              isArchived: widget.habit.isArchived,
            );
            await _habitRepo.updateHabit(updatedHabit);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit Updates Saved')));
              Navigator.pop(context);
            }
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
