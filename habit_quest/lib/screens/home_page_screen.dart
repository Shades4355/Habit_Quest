import 'package:flutter/material.dart';

import "package:habit_quest/interfaces/app_drawer.dart";
import 'package:habit_quest/interfaces/record_habit_interface_pop_up.dart';

import 'package:habit_quest/providers/habit_provider.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/providers/habit_record_provider.dart';
import 'package:habit_quest/widgets/habit_chart.dart';
import 'package:provider/provider.dart';

// ==================== HOMEPAGE SCREEN ====================

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  Widget _todaysScore(BuildContext context) {
    final score = context.watch<HabitRecordProvider>().todayScore;
    return Text(
      'Today\'s Score: $score',
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _habitTile(BuildContext context, Habit currentHabit) {
    final habitRecordProvider = context.watch<HabitRecordProvider>();
    final habitId = currentHabit.id;
    if (habitId == null) return const SizedBox.shrink();

    final isCompleted = habitRecordProvider.completedHabit[habitId] ?? false;
    if (isCompleted) return const SizedBox.shrink();
    return ListTile(
      leading: IconButton(
        icon: Icon(
          Icons.check_box_outline_blank
          // color: isCompleted ? Colors.green : null,
        ),
        onPressed: () async {
          await context.read<HabitRecordProvider>().toggleCompletedToday(habitId);
        },
      ),
      title: Text(currentHabit.habitName),
      trailing: Text(
        '${currentHabit.importanceLevel}',
        style: TextStyle(
          color: currentHabit.importanceLevel > 0
              ? Colors.green
              : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _habitsList(BuildContext context) {
    final HabitProvider habitProvider = context.watch<HabitProvider>();
    final habitRecordProvider = context.watch<HabitRecordProvider>();
  

    if (habitProvider.isLoading || habitRecordProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final topHabits = habitRecordProvider.topUncompletedHabits(habitProvider.habits);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topHabits.length,
      itemBuilder: (ctx, i) {
        final habit = topHabits[i];
        return _habitTile(context, habit);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // CALCULATE DYNAMIC HEIGHT HERE
    final double screenHeight = MediaQuery.of(context).size.height;
    final double dynamicChartHeight =
        screenHeight * 0.25; // 25% of screen height

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Habit Quest')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/extended_graph'),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: dynamicChartHeight, // DYNAMIC HEIGHT APPLIED
                  child: AbsorbPointer(
                    child: ScoreChart(chartType: ChartType.home),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _todaysScore(context),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Unrecorded Habits:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _habitsList(context),
            // Extra padding at the bottom so the FAB doesn't cover the list
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => RecordHabitInterfacePopUp(),
          ).then((_) async {
            if (!context.mounted) return;
            await context.read<HabitRecordProvider>().loadAll();
          });
        },
      ),
    );
  }
}
