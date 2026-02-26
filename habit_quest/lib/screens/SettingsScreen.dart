import 'package:flutter/material.dart';

import '../interfaces/AppDrawer.dart';
import '../interfaces/NotificationInterfacePopUp.dart';


// ==================== SETTINGS SCREEN ====================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // "Export Data" option[cite: 180].
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Save Habit History to CSV'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Exporting data... [cite: 185]')));
            },
          ),
          const Divider(),
          // "Clear History" option[cite: 191].
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear History', style: TextStyle(color: Colors.red)),
            // The "Clear History" button will prompt the User to confirm... with a pop-up[cite: 193].
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: const Text('Are you sure you want to clear your entire habit history?'),
                    actions: [
                      TextButton(
                        // If the User clicks "Cancel", close the pop-up[cite: 198].
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        // If the User confirms, delete the entire Habit History[cite: 196].
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: History Cleared')));
                        },
                        child: const Text('Confirm', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
              );
            },
          ),
          const Divider(),
          // "Notification Settings" option[cite: 202].
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            // The "Notification Settings" option will open the "Notifications" interface[cite: 204].
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (ctx) => const NotificationInterfacePopUp()
              );
            },
          ),
          const Divider(),
          // "Dark Mode" with an on/off slider[cite: 205, 207].
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
                // Slider presents different colors in on/off positions [cite: 218] (handled by material switch default).
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dark Mode set to: $_darkMode')));
            },
          ),
          const Divider(),
          // "Credits" option[cite: 219].
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Credits'),
            // The "Credits" option will open a pop-up[cite: 220].
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) => const AlertDialog(
                    title: Text('Credits'),
                    // Displays team names [cite: 222] and thanks the user[cite: 223].
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('The Team:\n- Meyers, Shades\n- Azevedo, Luca\n- Echeverry, Miguel\n- Luc, Marvens'),
                        SizedBox(height: 20),
                        Text('Thank you for using Habit Quest!'),
                      ],
                    ),
                  )
              );
            },
          ),
        ],
      ),
    );
  }
}
