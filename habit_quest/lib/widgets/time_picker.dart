import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  const TimePicker({super.key});

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  TimeOfDay timeSelection = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title:  Text('Time: ${timeSelection.format(context)}'),
      trailing: const Icon(Icons.edit),
      onTap: () async {
        final picked  = await showTimePicker(
        context: context, 
        initialTime: timeSelection,
        );
        if(!mounted) return;
        if(picked != null){
          setState(() {
            timeSelection = picked;
          });
        }
      },
    );
  }
}