import 'package:flutter/material.dart';
import 'package:habit_quest/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


// --- Notification Interface [cite: 224] ---
class NotificationInterfacePopUp extends StatefulWidget {
  const NotificationInterfacePopUp({super.key});
  @override
  State<NotificationInterfacePopUp> createState() => _NotificationInterfacePopUpState();
}


class _NotificationInterfacePopUpState extends State<NotificationInterfacePopUp> {
  bool _allowDaily = false;
  String _frequency = '1';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _allowDaily = pref.getBool('allowDaily') ?? false;
      _frequency = pref.getString('frequency') ?? '1';
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('allowDaily', _allowDaily);
    await pref.setString('frequency', _frequency);
  }

  Future<void> _handleToggle(bool val) async {
    if (val) {
      final enabled = await NotificationService().areNotificationsEnabled();
      if (!enabled) {
        final granted = await NotificationService().requestPermissions();
        if (!granted && !await NotificationService().areNotificationsEnabled()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enable notifications in system settings.'))
            );
          }
          return;
        }
      }
    }

    setState(() => _allowDaily = val);
    await _savePreferences();

    if (val) {
      await _scheduleNotifications();
    } else {
      await NotificationService().cancelAllNotifications();
    }
  }

  Future<void> _handleFrequencyChange(String? newValue) async {
    if (newValue == null) return;
    setState(() => _frequency = newValue);
    await _savePreferences();
    if (_allowDaily) {
      await NotificationService().cancelAllNotifications();
      await _scheduleNotifications();
    }
  }

  Future<void> _scheduleNotifications() async {
    final int count = int.parse(_frequency);

    // Spread notifications evenly across the day
    // 1 reminder = 8pm, 2 = 8am + 8pm, 3 = 8am + 2pm + 8pm
    final List<int> hours = switch (count) {
      1 => [20],
      2 => [8, 20],
      3 => [8, 14, 20],
      _ => [20]
    };

    for (int i = 0; i < count; i++) {
      final hour = hours[i];
      await NotificationService().scheduleDailyNotification(
        id: i,
        hour: hour,
        minute: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Notification Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // "Allow Daily Reminders" with an on/off toggle[cite: 228, 230].
          const Divider(),
          SwitchListTile(
            title: const Text('Allow Daily Reminders'),
            value: _allowDaily,
            // When on, send notifications; off, send none[cite: 232, 234].
            onChanged: (val) => _handleToggle(val),
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
              onChanged: _allowDaily ? (String? newValue) => _handleFrequencyChange(newValue) : null,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Notifications limited to: "Reminder: Record Your Habits!" [cite: 245]', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
