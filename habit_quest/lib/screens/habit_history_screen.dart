import 'package:flutter/material.dart';
import 'package:habit_quest/interfaces/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:habit_quest/database/entities/habit_record.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/providers/habit_record_provider.dart';
import 'package:habit_quest/providers/habit_provider.dart';

class HabitHistoryScreen extends StatefulWidget {
  const HabitHistoryScreen({super.key});

  @override
  State<HabitHistoryScreen> createState() => _HabitHistoryScreenState();
}

class _HabitHistoryScreenState extends State<HabitHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitRecordProvider>().loadAll();
    });
  }

  Widget _habitRecordTile(BuildContext context, HabitRecord record, Habit? habit) {
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
  }

  @override
  Widget build(BuildContext context) {
    final habitRecordProvider = context.watch<HabitRecordProvider>();
    final habitProvider = context.watch<HabitProvider>();

    if (habitRecordProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final days = List.generate(30, (i) => 
      DateTime.now().subtract(Duration(days: i))
    );

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Habit History')),
      // CHANGED: Swapped ListView.builder for ListView.separated
      body: ListView.separated(
        itemCount: days.length,
        // CHANGED: Added the divider here
        separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
        itemBuilder: (ctx, dayIndex) {
          final date = days[dayIndex];
          final records = habitRecordProvider.getRecordsForDaySync(date);

          final totalScore = records.fold(0, (sum, r) => sum + r.scoreDelta);

          return ExpansionTile(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            // CHANGED: Put both Date and Score into a Row inside the title
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.month}/${date.day}/${date.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Score: $totalScore',
                  style: TextStyle(                
                    color: totalScore >= 0 ? Colors.green : Colors.red,
                    fontSize: 14, // Slightly scaled down so it fits nicely next to the arrow
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            // CHANGED: Removed the 'trailing' property entirely. 
            // This allows the default animated chevron ("V") to return!
            children: records.isEmpty
              ? [const ListTile(title: Text('No habits completed'))]
              : records.map((record) {
                final habit = habitProvider.habits
                    .where((h) => h.id == record.habitId)
                    .firstOrNull;
                return _habitRecordTile(context, record, habit);
              }).toList(),
          );
        },
      ),
    );
  }
}