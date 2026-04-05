import 'package:flutter/material.dart';

// Interfaces
import 'package:habit_quest/widgets/theme_picker.dart';
import 'package:habit_quest/interfaces/app_drawer.dart';
import 'package:habit_quest/interfaces/notification_interface_pop_up.dart';

// ==================== SETTINGS SCREEN ====================

class SettingsScreen extends StatefulWidget {
  // Properties passed from main.dart

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // "Export Data" option.
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Save Habit History to CSV'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Placeholder: Exporting data...')));
            },
          ),
          const Divider(),

          // "Clear History" option.
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title:
                const Text('Clear History', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text(
                            'Are you sure you want to clear your entire habit history?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Placeholder: History Cleared')));
                            },
                            child: const Text('Confirm',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ));
            },
          ),
          const Divider(),

          // "Notification Settings" option.
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (ctx) => const NotificationInterfacePopUp());
            },
          ),
          const Divider(),
          // "Dark Mode" with an on/off slider.
          // SwitchListTile(
          //   secondary: const Icon(Icons.dark_mode),
          //   title: const Text('Dark Mode'),
          //   value: context.watch<ThemeProvider>().darkMode,
          //   onChanged: (bool value) {
          //     context.read<ThemeProvider>().toggleDarkMode(value);
          //   },
          // ),
          const ThemePicker(),
          const Divider(),

          // "Credits" option.
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Credits'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) => const AlertDialog(
                        title: Text('Credits'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'The Team:\n- Meyers, Shades\n- Azevedo, Luca\n- Echeverry, Miguel\n- Luc, Marvens'),
                            SizedBox(height: 20),
                            Text('Thank you for using Habit Quest!'),
                          ],
                        ),
                      ));
            },
          ),
        ],
      ),
    );
  }
}