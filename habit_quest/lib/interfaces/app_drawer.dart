import 'package:flutter/material.dart';

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
    // The "Navigation Panel" is a pop-up (ex: drawer)[cite: 62].
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Text('Habit Quest Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          // The "Navigation Panel" will include options: Home, Manage Habits, Habit History, and Settings[cite: 63].
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            // The "Home" option will take the User to the "Homepage"[cite: 64].
            onTap: () => _navigateTo(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Manage Habits'),
            // The "Manage Habits" option will take Users to the "Manage Habits" screen[cite: 65, 66].
            onTap: () => _navigateTo(context, '/manage_habits'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Habit History'),
            // The "Habit History" option will take Users to the "Habit History" screen[cite: 67].
            onTap: () => _navigateTo(context, '/habit_history'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            // The "Settings" option will take Users to the "Settings" screen[cite: 68].
            onTap: () => _navigateTo(context, '/settings'),
          ),
        ],
      ),
    );
  }
}
