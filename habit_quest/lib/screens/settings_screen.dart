import 'package:flutter/material.dart';
// Providers
import 'package:provider/provider.dart';
import 'package:habit_quest/providers/habit_provider.dart';
import 'package:habit_quest/providers/habit_record_provider.dart';
// Services
import 'package:habit_quest/services/export_service.dart';
import 'package:habit_quest/services/toast_service.dart';
// Interfaces and Widgets
import 'package:habit_quest/widgets/theme_picker.dart';
import 'package:habit_quest/interfaces/app_drawer.dart';
import 'package:habit_quest/interfaces/notification_interface_pop_up.dart';
import 'package:habit_quest/services/tutorial_manager.dart';

// ==================== SETTINGS SCREEN ====================

class SettingsScreen extends StatefulWidget {
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
            onTap: () async {
              await ExportService().exportData(context);
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import Data'),
            subtitle: const Text('Load Habit History from CSV'),
            onTap: () async {
              await ExportService().importData(context);
              if (!context.mounted) return;
              await context.read<HabitProvider>().loadHabits();
              await context.read<HabitRecordProvider>().loadAll();
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
                            onPressed: () async {
                              final habitRecordProvider = context.read<HabitRecordProvider>();
                              await habitRecordProvider.clearAllRecords();
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (!context.mounted) return;
                              ToastService.showToast('Habit history cleared');
                            },
                            child: const Text('Confirm',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ));
            },
          ),
          const Divider(),

          // "Reset Tutorial" option. (Only ONE button now, wired up correctly)
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Reset Tutorial'),
            onTap: () async {
              ToastService.showInfo('Restarting tutorial...');
              await TutorialManager.resetTutorial(context);
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