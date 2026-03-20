import 'package:flutter/material.dart';

import "package:habit_quest/interfaces/app_drawer.dart";
import 'package:habit_quest/interfaces/record_habit_interface_pop_up.dart';

import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/repositories/habit_repository.dart';
import 'package:habit_quest/widgets/habit_chart.dart';

// ==================== HOMEPAGE SCREEN ====================

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  HabitRepository get _habitRepo => HabitRepository.instance;

  Widget _todaysScore() {
    return FutureBuilder<int?>(
      future: _habitRepo.getScoreForDate(DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final score = snapshot.data ?? 0;
        return Text(
          'Today\'s Score: $score',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _habitsList() {
    return FutureBuilder<List<Habit>>(
      future: widget.habitRepo.getActiveHabits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final habits = snapshot.data ?? [];

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: habits.length,
          itemBuilder: (ctx, i) {
            final currentHabit = habits[i];
            final habitId = currentHabit.id;
            if (habitId == null) return const SizedBox.shrink();

            return FutureBuilder<bool>(
              future: _habitRepo.isCompletedToday(habitId),
              builder: (context, completionSnapshot) {
                final isCompleted = completionSnapshot.data ?? false;

                return ListTile(
                  leading: IconButton(
                    icon: Icon(
                      isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isCompleted ? Colors.green : null,
                    ),
                    onPressed: () async {
                      await _habitRepo.toggleCompletedToday(habitId);
                      setState(() {});
                    },
                  ),
                  title: Text(currentHabit.habitName),
                  trailing: Text(
                    '${currentHabit.importanceLevel}',
                    style: TextStyle(
                      color: currentHabit.importanceLevel > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                );
              },
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // CALCULATE DYNAMIC HEIGHT HERE
    final double screenHeight = MediaQuery.of(context).size.height;
    final double dynamicChartHeight = screenHeight * 0.25; // 25% of screen height

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
                    child: ScoreChart(
                      isHomePage: true,
                      habitRepo: widget.habitRepo,
                      maxY: 20,
                    ),
                  )
                ),
              ),
            ),
            const SizedBox(height: 20),
            _todaysScore(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft, 
                child: Text('Unrecorded Habits:', style: TextStyle(fontWeight: FontWeight.bold))
              ),
            ),
            _habitsList(),
            // Extra padding at the bottom so the FAB doesn't cover the list
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (ctx) => RecordHabitInterfacePopUp()
          );
        },
      ),
    );
  }
}