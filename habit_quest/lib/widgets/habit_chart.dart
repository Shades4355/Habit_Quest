import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_quest/repositories/habit_repository.dart';

class ScoreChart extends StatelessWidget{
  final HabitRepository habitRepo;
  final double maxY;
  final bool isHomePage;

  const ScoreChart({
    super.key,
    required this.habitRepo,
    required this.isHomePage,
    required this.maxY,
  });



  Future<List<FlSpot>> _getDataPoints() async {
    final days = isHomePage ? 7 : 30;
    final data = await habitRepo.getScoreForLastNDays(days);

    return List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index]?.toDouble() ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlSpot>>(
      future: _getDataPoints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final spots = snapshot.data ?? [];

        if (spots.isEmpty) {
          return const Center(child: Text('No score data available'));
        }

        return LineChart(
          LineChartData(
            minX: 0,
            maxX: isHomePage? 6 : 30,
            minY: -maxY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              verticalInterval: 1,
              horizontalInterval: 5),
            borderData: FlBorderData(show: true),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  reservedSize: 30
                )
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text("");
                  },
                ),
              ),
            ),
            lineBarsData: [
                  LineChartBarData(
                    // get raid of everything under here
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
          ),
        );
      },
    );
  }
}