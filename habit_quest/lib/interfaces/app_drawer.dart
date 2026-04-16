import 'package:flutter/material.dart';
import 'package:habit_quest/services/tutorial_manager.dart';

// === SHARED NAVIGATION DRAWER ===

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateTo(BuildContext context, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    Navigator.pop(context); // close drawer
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The "Navigation Panel" is a pop-up (ex: drawer).
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Text('Habit Quest Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          // The "Navigation Panel" will include options: Home, Manage Habits, Habit History, and Settings.
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            // The "Home" option will take the User to the "Homepage".
            onTap: () => _navigateTo(context, '/'),
          ),
          Focus(
            focusNode: TutorialManager.drawerManageHabitsNode,
            child: ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Manage Habits'),
              // The "Manage Habits" option will take Users to the "Manage Habits" screen.
              onTap: () => _navigateTo(context, '/manage_habits'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Habit History'),
            // The "Habit History" option will take Users to the "Habit History" screen.
            onTap: () => _navigateTo(context, '/habit_history'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            // The "Settings" option will take Users to the "Settings" screen.
            onTap: () => _navigateTo(context, '/settings'),
          ),
        ],
      ),
    );
  }
}