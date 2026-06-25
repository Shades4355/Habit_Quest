import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_quest/providers/color_theme_provider.dart';

class NegColorThemePicker extends StatelessWidget {
  const NegColorThemePicker({super.key});
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
              Text('Negative Color', style: TextStyle(fontSize: 16.0)),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<Color>(
            expandedInsets: EdgeInsets.zero, // fills full width
            segments: [
                ButtonSegment(
                  value: Color(Colors.red.toARGB32()),
                  label: Text('Red'),
                  icon: Icon(Icons.circle, color: Colors.red),),
                ButtonSegment(
                  value: Color(Colors.yellow.toARGB32()),
                  label: Text('Yellow'),
                  icon: Icon(Icons.circle, color: Colors.yellow),),
                ButtonSegment(
                  value: Color(Colors.purple.toARGB32()),
                  label: Text('Purple'),
                  icon: Icon(Icons.circle, color: Colors.purple),),
            ],
            selected: {Color(context.watch<ColorThemeProvider>().colorThemes[1])},
            onSelectionChanged: (value) {
              final newColorVal = value.first.toARGB32();
              final currentPosColor = context.read<ColorThemeProvider>().colorThemes[0];
              context.read<ColorThemeProvider>().setColors([
                currentPosColor,
                newColorVal]);
            },
          ),
        ],
      ),
    );
  }
}
