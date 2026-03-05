import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore all orientations when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
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
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 29,
            minY: 0,
            maxY: 20,
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  getTitlesWidget: (value, meta) {
                    return Text('Day ${value.toInt() + 1}');
                  },
                ),
              ),
            ),
            // date belongs here!!!!
            lineBarsData: [
              LineChartBarData(
                // get raid of everything under here
                spots: List.generate(
                  30,
                  (index) => FlSpot(
                    index.toDouble(),
                    (index % 10 + 5).toDouble(),
                  ),
                ),
                isCurved: true,
                barWidth: 3,
                dotData: FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}