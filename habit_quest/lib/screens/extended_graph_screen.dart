import 'package:flutter/material.dart';
import 'package:habit_quest/widgets/habit_chart.dart';
import 'package:flutter/services.dart';

// ==================== EXTENDED GRAPH SCREEN ====================

class ExtendedGraphScreen extends StatefulWidget {
  const ExtendedGraphScreen({super.key});

  @override
  State<ExtendedGraphScreen> createState() => _ExtendedGraphScreen();
}

class _ExtendedGraphScreen extends State<ExtendedGraphScreen> {

  @override
  void initState() {
    super.initState();
    // Set landscape mode when entering the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset to portrait mode when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extended Graph'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Wrap the body in a SafeArea so the sideways nav bar doesn't cover the chart
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ScoreChart(chartType: ChartType.extended)
        ),
      ),
    );
  }
}