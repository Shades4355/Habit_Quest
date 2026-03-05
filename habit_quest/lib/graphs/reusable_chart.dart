import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ScoreChart extends StatelessWidget{
  final List<double> scores;
  final double maxY;

  const ScoreChart({
    super.key,
    required this.scores,
    required this.maxY,
  });

@override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: scores.length - 1,
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)
          ),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1,
          getTitlesWidget: (value, meta) {
            return Text('D${value.toInt()+ 1}');

          },
          ),
          ),
        ),
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
    );
  }
}