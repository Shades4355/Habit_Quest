import 'package:flutter/material.dart';

import "../interfaces/AppDrawer.dart";
import '../interfaces/RecordHabitInterfacePopUp.dart';

import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/repositories/habit_repository.dart';
import 'package:habit_quest/widgets/habit_chart.dart';

// ==================== HOMEPAGE SCREEN ====================

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, required this.habitRepo});

  final HabitRepository habitRepo;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  Widget _todaysScore() {
    return FutureBuilder<int?>(
      future: widget.habitRepo.getScoreForDate(DateTime.now()),
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

  // Widget _emptyHabitListPlaceholder() {

  Widget _habitsList() {
    return FutureBuilder<List<Habit>>(
      future: widget.habitRepo.getActiveHabits(), //getUnrecordedHabitsToday(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final habit = snapshot.data ?? [];

        // if (habit.isEmpty) {
        //   return const Text('All habits recorded for today!');
        // }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: habit.length,
          itemBuilder: (ctx, i) {
            final currentHabit = habit[i];
            final habitId = currentHabit.id;
            if (habitId == null) return const SizedBox.shrink();

            return FutureBuilder<bool>(
              future: widget.habitRepo.isCompletedToday(habitId),
              builder: (context, completionSnapshot) {
                final isCompleted = completionSnapshot.data ?? false;

                return ListTile(
                  leading: IconButton(
                    icon: Icon(
                      isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                    ),
                    onPressed: () async {
                      await widget.habitRepo.toggleCompletedToday(habitId);
                      setState(() {});
                    },
                  ),
                  title: Text(currentHabit.habitName,),
                  // TODO: Using SharedPreferences, use a boolean to check if deadlines are enabled
                  // subtitle: Text('Deadline: No deadline'),
                  trailing: Text(
                    '${currentHabit.importanceLevel}', 
                    style: TextStyle(color: currentHabit.importanceLevel > 0 ? Colors.green : Colors.red)
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
    return Scaffold(
      // There will be a "hamburger" button at the top left... displaying a navigation panel[cite: 8].
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Habit Quest')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // The "Homepage" will display a line graph showing User scores over the last 7 days[cite: 11].
            InkWell(
              // Clicking on the graph will take the user to the "Extended Graph" screen[cite: 12].
              onTap: () => Navigator.pushNamed(context, '/extended_graph'),
              child: Padding(padding: const EdgeInsets.all(16.0),
                child:
                SizedBox(
                  height: 200,
                  child:AbsorbPointer( 
                    child: ScoreChart(
                      isHomePage: true,
                      habitRepo: widget.habitRepo,
                      maxY:20,
                    ),
                  )
                ),
              ),
            ),
            const SizedBox(height: 20),
            // The "Homepage" will display the User's current daily score[cite: 19].
            _todaysScore(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(alignment: Alignment.centerLeft, child: Text('Unrecorded Habits:', style: TextStyle(fontWeight: FontWeight.bold))),
            ),
            // The "Homepage" will display a list of unrecorded habits[cite: 20].
            _habitsList(),
          ],
        ),
      ),
      // There will be a circular button with a plus sign centered... at the bottom of the homepage[cite: 13, 15, 16].
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        // When the User clicks on the plus button... they will be taken to the "Record Habit" interface[cite: 17].
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (ctx) => RecordHabitInterfacePopUp(habitRepo: widget.habitRepo)
          );
        },
      ),
    );
  }
}
