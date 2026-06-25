import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_quest/providers/theme_provider.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.palette),
              SizedBox(width: 16),
              Text('Appearance', style: TextStyle(fontSize: 16.0)),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemeModeOption>(
            expandedInsets: EdgeInsets.zero, // fills full width
            segments: const [
              ButtonSegment(
                value: ThemeModeOption.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeModeOption.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
              ButtonSegment(
                value: ThemeModeOption.system,
                label: Text('System'),
                icon: Icon(Icons.phone_android),
              ),
            ],
            selected: {context.watch<ThemeProvider>().themeMode},
            onSelectionChanged: (value) {
              context.read<ThemeProvider>().setTheme(value.first);
            },
          ),
        ],
      ),
    );
  }
  }
