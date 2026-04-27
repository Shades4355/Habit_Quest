import 'package:flutter/material.dart';
import 'package:habit_quest/database/entities/habit_record.dart';

class EditRecordInterfacePopUp extends StatefulWidget {
  final HabitRecord record;

  const EditRecordInterfacePopUp({
    super.key,
    required this.record,
  });

  @override
  State<EditRecordInterfacePopUp> createState() => _EditRecordInterfacePopUpState();
}

class _EditRecordInterfacePopUpState extends State<EditRecordInterfacePopUp> {
  late final TextEditingController _nameController;
  late int _importanceLevel;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.record.habitName);
    _importanceLevel = widget.record.importanceLevel.clamp(1, 5);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Record'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Habit Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'New score: ${widget.record.scoreDelta < 0 ? '-' : '+'}$_importanceLevel points',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedName = _nameController.text.trim();
            if (updatedName.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Habit name cannot be empty')),
              );
              return;
            }

            final updatedRecord = HabitRecord(
              recordId: widget.record.recordId,
              habitId: widget.record.habitId,
              habitName: updatedName,
              importanceLevel: _importanceLevel,
              date: widget.record.date,
              scoreDelta: widget.record.scoreDelta < 0
                  ? -_importanceLevel
                  : _importanceLevel,
            );

            Navigator.pop(context, updatedRecord);
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
