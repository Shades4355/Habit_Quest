import 'package:flutter/material.dart';


// --- Notification Interface [cite: 224] ---
class NotificationInterfacePopUp extends StatefulWidget {
  const NotificationInterfacePopUp({super.key});
  @override
  State<NotificationInterfacePopUp> createState() => _NotificationInterfacePopUpState();
}


class _NotificationInterfacePopUpState extends State<NotificationInterfacePopUp> {
  bool _allowDaily = true;
  String _frequency = '1';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Notification Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // "Allow Daily Reminders" with an on/off toggle[cite: 228, 230].
          SwitchListTile(
            title: const Text('Allow Daily Reminders'),
            value: _allowDaily,
            // When on, send notifications; off, send none[cite: 232, 234].
            onChanged: (val) => setState(() => _allowDaily = val),
          ),
          const Divider(),
          // "Daily Reminder Frequency" with a dropdown list (1, 2, 3)[cite: 236, 238, 239].
          ListTile(
            title: const Text('Daily Reminder Frequency'),
            // Grayed out when "Allow Daily Reminders" is off[cite: 243].
            enabled: _allowDaily,
            trailing: DropdownButton<String>(
              value: _frequency,
              // The app will send 1/2/3 reminder(s) depending on selection[cite: 241].
              items: ['1', '2', '3'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: _allowDaily ? (String? newValue) => setState(() => _frequency = newValue!) : null,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Notifications limited to: "Reminder: Record Your Habits!" [cite: 245]', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
