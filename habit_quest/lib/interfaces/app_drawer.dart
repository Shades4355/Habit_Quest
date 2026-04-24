import 'package:flutter/material.dart';
import 'package:habit_quest/services/tutorial_manager.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateTo(BuildContext context, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    Navigator.pop(context);
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    return Drawer(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
                  child: Icon(Icons.track_changes_rounded,
                      size: 30, color: colorScheme.onPrimary),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Habit Quest',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Build better habits',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Nav Items ────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              children: [
                Focus(
                  focusNode: TutorialManager.drawerHomeNode,
                  child: _DrawerItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: currentRoute == '/',
                    onTap: () {
                      if (TutorialManager.isTutorialActive.value) {
                        TutorialManager.nextStep();
                      }
                      _navigateTo(context, '/');
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Focus(
                  focusNode: TutorialManager.drawerManageHabitsNode,
                  child: _DrawerItem(
                    icon: Icons.edit_note_rounded,
                    label: 'Manage Habits',
                    isSelected: currentRoute == '/manage_habits',
                    onTap: () {
                      if (TutorialManager.isTutorialActive.value) {
                        TutorialManager.nextStep();
                      }
                      _navigateTo(context, '/manage_habits');
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Focus(
                  focusNode: TutorialManager.drawerHistoryNode,
                  child: _DrawerItem(
                    icon: Icons.history_rounded,
                    label: 'Habit History',
                    isSelected: currentRoute == '/habit_history',
                    onTap: () {
                      if (TutorialManager.isTutorialActive.value) {
                        TutorialManager.nextStep();
                      }
                      _navigateTo(context, '/habit_history');
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(thickness: 1),
                ),
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: currentRoute == '/settings',
                  onTap: () => _navigateTo(context, '/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}