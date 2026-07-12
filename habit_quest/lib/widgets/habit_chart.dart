import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_quest/providers/habit_record_provider.dart';
import 'package:provider/provider.dart';

enum ChartType { home, extended }

class ScoreChart extends StatelessWidget {
  final ChartType chartType;

  const ScoreChart({
    super.key,
    required this.chartType,
  });

  List<FlSpot> _getDataPoints(BuildContext context) {
    final data = chartType == ChartType.home
        ? context.read<HabitRecordProvider>().weekScores
        : context.read<HabitRecordProvider>().monthScores;
    return List.generate(
      data.length,
      (index) => FlSpot(index.toDouble(), data[index]?.toDouble() ?? 0),
    );
  }

  double _axisInterval(List<FlSpot> data) {
    if (data.isEmpty) {
      return 5;
    }

    final minY = data.reduce((a, b) => a.y < b.y ? a : b).y;
    final maxY = data.reduce((a, b) => a.y > b.y ? a : b).y;
    final span = (maxY - minY).abs();

    if (span <= 20) return 5;
    if (span <= 50) return 10;
    if (span <= 100) return 20;
    if (span <= 250) return 50;
    return 100;
  }

  double _clampDown(double value, double interval) {
    return (value / interval).floor() * interval;
  }

  double _clampUp(double value, double interval) {
    return (value / interval).ceil() * interval;
  }

  // Formula for dynamic axis scaling
  List<double> _axisScalingFormula(List<FlSpot> data) {
    // Default range [-20, 20]
    if (data.isEmpty) {
      return [-20, 20];
    }

    // min and max y values
    double minY = data.reduce((a, b) => a.y < b.y ? a : b).y;
    double maxY = data.reduce((a, b) => a.y > b.y ? a : b).y;
    final interval = _axisInterval(data);

    if (minY == maxY) {
      minY -= interval;
      maxY += interval;
    }

    if (minY > -20 && maxY < 20) {
      return [-20, 20];
    }

    final padding = (interval * 2).toDouble();
    minY = _clampDown(minY - padding, interval);
    maxY = _clampUp(maxY + padding, interval);

    return [minY, maxY];
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getDataPoints(context);
    final yScale = _axisScalingFormula(spots);
    final yInterval = _axisInterval(spots);
    final provider = context.watch<HabitRecordProvider>();

    if (spots.isEmpty) {
      return const Center(child: Text('No score data available'));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: chartType == ChartType.home ? 6 : 29,
        minY: yScale.first,
        maxY: yScale.last,
        gridData: const FlGridData(
          show: true,
          verticalInterval: 1,
        ).copyWith(horizontalInterval: yInterval),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval,
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: chartType == ChartType.home ? 1 : 5,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final days = chartType == ChartType.home ? 7 : 30;
                final date = DateTime.now().subtract(
                  Duration(days: days - 1 - value.toInt()),
                );
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(fontSize: 10),
                  ),
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
            dotData: const FlDotData(show: true),
            color: Colors.blue,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot touchedSpot) => 
                Colors.blueGrey.withValues(alpha: 0.9),
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final days = chartType == ChartType.home ? 7 : 30;
                final date = DateTime.now().subtract(
                  Duration(days: days - 1 - index),
                );
                final dateStr = '${date.month}/${date.day}';

                final int posPoints = provider.getPositivePointsForDate(date);
                final int negPoints = provider.getNegativePointsForDate(date);
                final int totalScore = spot.y.toInt();

                return LineTooltipItem(
                  '$dateStr\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '+$posPoints\n',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '$negPoints\n',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Total: $totalScore',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}