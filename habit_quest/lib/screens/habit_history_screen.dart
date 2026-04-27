import 'package:flutter/material.dart';
import 'package:habit_quest/interfaces/app_drawer.dart';
import 'package:habit_quest/interfaces/edit_record_interface_pop_up.dart';
import 'package:provider/provider.dart';
import 'package:habit_quest/database/entities/habit_record.dart';
import 'package:habit_quest/providers/habit_record_provider.dart';
import 'package:habit_quest/widgets/delete_button.dart';

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

  Future<void> _editRecord(HabitRecord record) async {
    final result = await showDialog<HabitRecord?>(
      context: context,
      builder: (ctx) => EditRecordInterfacePopUp(record: record),
    );

    if (result == null) return;

    if (!context.mounted) return;
    await context.read<HabitRecordProvider>().editHabitRecord(
      oldRecord: record,
      newRecord: result,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record updated')),
    );
  }

  Future<void> _deleteRecord(HabitRecord record) async {
    await context.read<HabitRecordProvider>().deleteHabitRecord(record);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record deleted')),
    );
  }

  Widget _habitRecordTile(BuildContext context, HabitRecord record) {
    return ListTile(
      leading: Icon(
        Icons.check_circle,
        color: record.scoreDelta >= 0 ? Colors.green : Colors.red,
      ),
      title: Text(record.habitName.isEmpty ? 'Unknown Habit' : record.habitName),
      subtitle: Text(
        '${record.scoreDelta > 0 ? '+' : ''}${record.scoreDelta} points',
        style: TextStyle(
          color: record.scoreDelta >= 0 ? Colors.green : Colors.red,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Edit record',
            onPressed: () => _editRecord(record),
          ),
          DeleteButton(
            deleteContext: DeleteContext.habitRecord,
            onDelete: () => _deleteRecord(record),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitRecordProvider = context.watch<HabitRecordProvider>();

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
                    color: totalScore >= 0 && records.isNotEmpty ? Colors.green : Colors.red,
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
              : records.map((record) => _habitRecordTile(context, record)).toList(),
          );
        },
      ),
    );
  }
}