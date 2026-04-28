import 'package:flutter/material.dart';

import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/services/toast_service.dart';

import 'package:provider/provider.dart';
import 'package:habit_quest/providers/habit_provider.dart';

class EditHabitInterfacePopUp extends StatefulWidget{
  const EditHabitInterfacePopUp({super.key, required this.habit});

  final Habit habit;

  @override
  State<EditHabitInterfacePopUp> createState() => _EditHabitInterfacePopUpState();
}

class _EditHabitInterfacePopUpState extends State<EditHabitInterfacePopUp> {
  late TextEditingController _habitNameController;
  late int _importanceLevel;

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
            value: _importanceLevel.abs().toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '${_importanceLevel.abs()}',
            onChanged: (val) {
              setState(() {
                final sign = _importanceLevel < 0 ? -1 : 1;
                _importanceLevel = val.toInt() * sign;
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
            await context.read<HabitProvider>().updateHabit(updatedHabit);

            if (context.mounted) {
              ToastService.showSuccess('Habit Successfully Updated');
              Navigator.pop(context);
            }
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
