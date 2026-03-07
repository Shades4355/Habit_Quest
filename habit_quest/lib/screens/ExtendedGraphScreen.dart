import 'package:flutter/material.dart';
import 'package:habit_quest/repositories/habit_repository.dart';
import 'package:habit_quest/widgets/habit_chart.dart';
import 'package:flutter/services.dart';

// ==================== EXTENDED GRAPH SCREEN ====================

class ExtendedGraphScreen extends StatefulWidget {
  final HabitRepository habitRepo;

  const ExtendedGraphScreen({super.key, required this.habitRepo});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extended Graph'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ScoreChart(
          isHomePage: false,
          habitRepo: widget.habitRepo,
          maxY: 20,
        )
      ),
    );
  }
}