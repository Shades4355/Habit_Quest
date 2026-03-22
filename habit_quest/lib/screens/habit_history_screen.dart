import 'package:flutter/material.dart';
import 'package:habit_quest/interfaces/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:habit_quest/providers/habit_record_provider.dart';
import 'package:habit_quest/providers/habit_provider.dart';

class HabitHistoryScreen extends StatelessWidget {
  const HabitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitRecordProvider = context.watch<HabitRecordProvider>();
    final habitProvider = context.watch<HabitProvider>();

    if (habitRecordProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Generate last 30 days in reverse order (most recent first)
    final days = List.generate(30, (i) => 
      DateTime.now().subtract(Duration(days: i))
    );

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Habit History')),
      body: ListView.builder(
        itemCount: days.length,
        itemBuilder: (ctx, dayIndex) {
          final date = days[dayIndex];
          final records = habitRecordProvider.getRecordsForDaySync(date);

          // if (records.isEmpty) return const Text();

          final totalScore = records.fold(0, (sum, r) => sum + r.scoreDelta);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${date.month}/${date.day}/${date.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text(
                      'Total Score: $totalScore',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: totalScore >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                itemBuilder: (ctx, habitIndex) {
                  final record = records[habitIndex];
                  // Find habit name from provider
                  final habit = habitProvider.habits
                      .where((h) => h.id == record.habitId)
                      .firstOrNull;
                  return ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: record.scoreDelta >= 0 ? Colors.green : Colors.red,
                    ),
                    title: Text(habit?.habitName ?? 'Unknown Habit'),
                    trailing: Text(
                      '${record.scoreDelta > 0 ? '+' : ''}${record.scoreDelta} points',
                      style: TextStyle(
                        color: record.scoreDelta >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}