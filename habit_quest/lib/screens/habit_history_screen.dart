import 'package:flutter/material.dart';
import 'package:habit_quest/interfaces/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:habit_quest/database/entities/habit_record.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/providers/habit_record_provider.dart';
import 'package:habit_quest/providers/habit_provider.dart';
import 'package:habit_quest/services/tutorial_manager.dart';

class HabitHistoryScreen extends StatefulWidget {
  const HabitHistoryScreen({super.key});

  @override
  State<HabitHistoryScreen> createState() => _HabitHistoryScreenState();
}

class _HabitHistoryScreenState extends State<HabitHistoryScreen> {
  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitRecordProvider>().loadAll();
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${_monthNames[date.month]} ${date.day}, ${date.year}';
  }

  Widget _habitRecordTile(BuildContext context, HabitRecord record) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = record.scoreDelta >= 0;
    final scoreColor = isPositive ? Colors.green.shade600 : Colors.red.shade600;
    final scoreLabel =
        '${record.scoreDelta > 0 ? '+' : ''}${record.scoreDelta} pts';

    return ListTile(
      dense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(
        isPositive
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded,
        color: scoreColor,
        size: 22,
      ),
      title: Text(
        record.habitName.isEmpty ? 'Unknown Habit' : record.habitName,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: (isPositive ? Colors.green : Colors.red).withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          scoreLabel,
          style: TextStyle(
            color: scoreColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitRecordProvider = context.watch<HabitRecordProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final days = List.generate(
      30,
      (i) => DateTime.now().subtract(Duration(days: i)),
    );

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Habit History'),
      ),
      body: habitRecordProvider.isLoading
          ? Focus(
              focusNode: TutorialManager.historyItemNode,
              child: const Center(child: CircularProgressIndicator()),
            )
          : ListView.separated(
        itemCount: days.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        itemBuilder: (ctx, dayIndex) {
          final date = days[dayIndex];
          final records = habitRecordProvider.getRecordsForDaySync(date);
          final totalScore =
              records.fold<int>(0, (sum, r) => sum + r.scoreDelta);
          final hasRecords = records.isNotEmpty;

          final scoreColor = totalScore > 0
              ? Colors.green.shade600
              : totalScore < 0
                  ? Colors.red.shade600
                  : colorScheme.outline;

          Widget expansionTile = Theme(
            // Remove the default dividers inside ExpansionTile
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor:
                  colorScheme.surfaceContainerHighest,
              collapsedBackgroundColor:
                  colorScheme.surfaceContainerHigh,
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              title: Row(
                children: [
                  // Date column
                  SizedBox(
                    width: 48,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          _monthNames[date.month].toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.outline,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Label
                  Expanded(
                    child: Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // Score badge
                  if (hasRecords)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            (totalScore >= 0 ? Colors.green : Colors.red)
                                .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${totalScore > 0 ? '+' : ''}$totalScore',
                        style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    Text(
                      'No records',
                      style: TextStyle(
                          fontSize: 12, color: colorScheme.outline),
                    ),
                ],
              ),
              children: hasRecords
                  ? records.map((record) {
                      // ignore: unused_local_variable
                      final habit = habitProvider.habits
                          .where((h) => h.id == record.habitId)
                          .firstOrNull;
                      return _habitRecordTile(context, record);
                    }).toList()
                  : [
                      ListTile(
                        dense: true,
                        title: Text(
                          'No habits completed this day.',
                          style: TextStyle(
                              color: colorScheme.outline, fontSize: 13),
                        ),
                      ),
                    ],
            ),
          );

          // ── Tutorial spotlight on today's entry (index 0) ─────────────
          if (dayIndex == 0) {
            return Focus(
              focusNode: TutorialManager.historyItemNode,
              child: expansionTile,
            );
          }

          return expansionTile;
        },
      ),
    );
  }
}