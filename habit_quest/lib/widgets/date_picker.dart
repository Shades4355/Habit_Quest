import 'package:flutter/material.dart';
class DatePicker extends StatefulWidget {
  const DatePicker({super.key});

  @override
  State<DatePicker> createState() => _DatePickerState();
}
class _DatePickerState extends State<DatePicker> {
  DateTime dateSelection = DateTime.now();

Future<void> pickDate() async {
    final TextEditingController textController = TextEditingController(
      text:'${dateSelection.month.toString().padLeft(2, '0')}/'
            '${dateSelection.day.toString().padLeft(2, '0')}/'
            '${dateSelection.year}',
    );
    DateTime tempDate = dateSelection;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Date'),
          content: SizedBox(
            width: 360,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Enter date (DD/MM/YYYY)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit_calendar),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      try {
                        final parts = value.split('/');
                        if (parts.length == 3 &&
                            parts[0].length == 2 &&
                            parts[1].length == 2 &&
                            parts[2].length == 4) {
                          final parsed = DateTime(
                            int.parse(parts[2]),
                            int.parse(parts[1]),
                            int.parse(parts[0]),
                          );
                          if (parsed.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                            setDialogState(() => tempDate = parsed);
                          }
                        }
                      } catch (_) {}
                    },
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const Text('Or pick from calendar:'),
                  const SizedBox(height: 8),
                  CalendarDatePicker(
                    key: ValueKey(tempDate.toString()),
                    initialDate: tempDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    onDateChanged: (date) {
                      setDialogState(() {
                        tempDate = date;
                        textController.text =
                          '${date.month.toString().padLeft(2, '0')}/'
                          '${date.day.toString().padLeft(2, '0')}/'
                          '${date.year}';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => dateSelection = tempDate);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  String get formattedDate =>
      '${dateSelection.month.toString().padLeft(2, '0')}/'
      '${dateSelection.day.toString().padLeft(2, '0')}/'
      '${dateSelection.year}';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: Text('Select Date: $formattedDate'),
      trailing: const Icon(Icons.edit),
      onTap: pickDate,
    );
  }
}