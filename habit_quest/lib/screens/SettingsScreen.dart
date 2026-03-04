import 'package:flutter/material.dart';

import '../interfaces/AppDrawer.dart';
import '../interfaces/NotificationInterfacePopUp.dart';

// ==================== SETTINGS SCREEN ====================

class SettingsScreen extends StatelessWidget {
  // These are the parameters passed from main.dart to control the theme
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

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
            title: const Text('Clear History',
                style: TextStyle(color: Colors.red)),
            // The "Clear History" button will prompt the User to confirm... with a pop-up.
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text(
                            'Are you sure you want to clear your entire habit history?'),
                        actions: [
                          TextButton(
                            // If the User clicks "Cancel", close the pop-up.
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            // If the User confirms, delete the entire Habit History.
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
            // The "Notification Settings" option will open the "Notifications" interface.
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (ctx) => const NotificationInterfacePopUp());
            },
          ),
          const Divider(),
          // "Dark Mode" with an on/off slider.
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            // Uses the value passed from the parent (main.dart)
            value: isDarkMode,
            onChanged: (bool value) {
              // Calls the function in main.dart to update the entire app
              onThemeChanged(value);
              
              // Slider presents different colors in on/off positions (handled by material switch default).
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dark Mode set to: $value')));
            },
          ),
          const Divider(),
          // "Credits" option.
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Credits'),
            // The "Credits" option will open a pop-up.
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) => const AlertDialog(
                        title: Text('Credits'),
                        // Displays team names and thanks the user.
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