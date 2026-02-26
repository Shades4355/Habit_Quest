import 'package:flutter/material.dart';

import '../interfaces/AppDrawer.dart';


// ==================== HABIT HISTORY SCREEN ====================

class HabitHistoryScreen extends StatelessWidget {
  const HabitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Habit History')),
      // The "Habit History" screen will display daily accomplished habits going back at least 30 days[cite: 170].
      // Displayed Habits will be displayed in reverse recorded order[cite: 173].
      // Displayed habits will be grouped by day[cite: 174].
      body: ListView.builder(
        itemCount: 3, // Placeholder for number of days
        itemBuilder: (ctx, dayIndex) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date Placeholder (Day ${dayIndex + 1})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    // Each group will display the total score for that day[cite: 175].
                    const Text('Total Score: +8', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ],
                ),
              ),
              // Each group will display a breakdown of the score for that day[cite: 176].
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3, // Placeholder habits per day
                itemBuilder: (ctx, habitIndex) => const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Recorded Habit Name'),
                  trailing: Text('+2 points'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
