import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_quest/providers/color_theme_provider.dart';

class ColorThemePicker extends StatelessWidget {
  const ColorThemePicker({super.key});
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
              Text('Colors', style: TextStyle(fontSize: 16.0)),
            ],
          ),
          const SizedBox(height: 12),
          ButtonBarTheme(
            data: ButtonBarThemeData(
              alignment: MainAxisAlignment.start,
              buttonPadding: EdgeInsets.zero,
            ),
            child: ButtonBar(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<ColorThemeProvider>().setColors([
                      Colors.blue.toString(),
                      context.read<ColorThemeProvider>().colorThemes[1],
                    ]);
                  },
                  icon: const Icon(Icons.circle, color: Colors.blue),
                  label: const Text('Positive'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<ColorThemeProvider>().setColors([
                      context.read<ColorThemeProvider>().colorThemes[0],
                      Colors.yellow.toString(),
                    ]);
                  },
                  icon: const Icon(Icons.circle, color: Colors.yellow),
                  label: const Text('Negative'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
