import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:habit_quest/providers/habit_record_provider.dart';
import 'package:provider/provider.dart';

enum ChartType { home, extended }
class ScoreChart extends StatelessWidget{
  final ChartType chartType;

  const ScoreChart({
    super.key,
    required this.chartType,
  });

  List<FlSpot> _getDataPoints(BuildContext context) {
    final data = chartType == ChartType.home
      ? context.read<HabitRecordProvider>().weekScores
      : context.read<HabitRecordProvider>().monthScores;
    return List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index]?.toDouble() ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getDataPoints(context);

    if (spots.isEmpty) {
      return const Center(child: Text('No score data available'));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: chartType == ChartType.home ? 6 : 29,
        minY: -20,
        maxY: 20,
        gridData: FlGridData(
          show: true,
          verticalInterval: 1,
          horizontalInterval: 5
        ),
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
              interval: chartType == ChartType.home ? 1 : 5,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final days = chartType == ChartType.home ? 7 : 30;
                final date = DateTime.now().subtract(Duration(days: days - value.toInt()));
                final label = '${date.month}/${date.day}';
                return Text(
                  label,
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final days = chartType == ChartType.home ? 7 : 30;
                final date = DateTime.now().subtract(
                  Duration(days: days - 1 - spot.x.toInt())
                );
                final dateStr = '${date.month}/${date.day}';
                final score = spot.y.toInt();
                return LineTooltipItem(
                  '($dateStr, $score)',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}