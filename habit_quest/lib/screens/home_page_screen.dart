import 'package:flutter/material.dart';

import "package:habit_quest/interfaces/app_drawer.dart";
import 'package:habit_quest/interfaces/record_habit_interface_pop_up.dart';

import 'package:habit_quest/providers/habit_provider.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/providers/habit_record_provider.dart';
import 'package:habit_quest/widgets/habit_chart.dart';
import 'package:provider/provider.dart';
import 'package:habit_quest/services/tutorial_manager.dart';

// ==================== HOMEPAGE SCREEN ====================

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger tutorial check when the home screen loads!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialManager.checkAndShowTutorial();
    });
  }

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
        icon: const Icon(
          Icons.check_box_outline_blank
        ),
        onPressed: () async {
          await context.read<HabitRecordProvider>().recordHabitToday(habitId);
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

    final topHabits = habitRecordProvider.topUncompletedHabits(habitProvider.activeHabits);

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
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Habit Quest'),
        // OVERRIDE LEADING: Wrap the Hamburger menu in our FocusNode
        leading: Focus(
          focusNode: TutorialManager.menuNode,
          child: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // WELCOME NODE: Wraps the graph so the first step highlights the top of the screen
            Focus(
              focusNode: TutorialManager.welcomeNode,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/extended_graph'),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: 1.5, // Keeps the graph perfectly proportioned on all screens
                    child: AbsorbPointer(
                      child: ScoreChart(chartType: ChartType.home),
                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.task_alt),
        label: const Text('Log Activity'),
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true, 
            builder: (ctx) {
              // Grab the system padding to push the UI above the navigation bar
              final bottomPadding = MediaQuery.of(ctx).padding.bottom;
              
              return Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: const RecordHabitInterfacePopUp(),
              );
            },
          ).then((_) async {
            if (!context.mounted) return;
            await context.read<HabitRecordProvider>().loadAll();
          });
        },
      ),
    );
  }
}