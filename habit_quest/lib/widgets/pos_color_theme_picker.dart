import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_quest/providers/color_theme_provider.dart';

class PosColorThemePicker extends StatelessWidget {
  const PosColorThemePicker({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.palette),
              SizedBox(width: 16),
              Text('Positive Color', style: TextStyle(fontSize: 16.0)),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<Color>(
            expandedInsets: EdgeInsets.zero, // fills full width
            segments: [
                ButtonSegment(
                  value: Color(Colors.green.toARGB32()),
                  label: Text('Green'),
                  icon: Icon(Icons.circle, color: Colors.green),),
                ButtonSegment(
                  value: Color(Colors.blue.toARGB32()),
                  label: Text('Blue'),
                  icon: Icon(Icons.circle, color: Colors.blue),),
                ButtonSegment(
                  value: Color(Colors.teal.toARGB32()),
                  label: Text('Teal'),
                  icon: Icon(Icons.circle, color: Colors.teal),),
            ],
            selected: {Color(context.watch<ColorThemeProvider>().colorThemes[0])},
            onSelectionChanged: (value) {
              final newColorVal = value.first.toARGB32();
              final currentNegColor = context.read<ColorThemeProvider>().colorThemes[1];
              context.read<ColorThemeProvider>().setColors([
                newColorVal,
                currentNegColor]);
            },
          ),
        ],
      ),
    );
  }
}
