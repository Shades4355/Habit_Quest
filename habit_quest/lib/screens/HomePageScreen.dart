import 'package:flutter/material.dart';

import "../interfaces/AppDrawer.dart";
import '../interfaces/RecordHabitInterfacePopUp.dart';

// ==================== HOMEPAGE SCREEN ====================

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

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
              child: Container(
                height: 200,
                color: Colors.indigo.shade100,
                child: const Center(child: Text('Placeholder: 7-Day Score Line Graph (Tap to Expand)')),
              ),
            ),
            const SizedBox(height: 20),
            // The "Homepage" will display the User's current daily score[cite: 19].
            const Text('Today\'s Score: +5', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(alignment: Alignment.centerLeft, child: Text('Unrecorded Habits:', style: TextStyle(fontWeight: FontWeight.bold))),
            ),
            // The "Homepage" will display a list of unrecorded habits[cite: 20].
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (ctx, i) => ListTile(
                leading: const Icon(Icons.check_box_outline_blank),
                title: Text('Habit Name Placeholder ${i + 1}'),
                subtitle: const Text('Deadline: 10:00 AM'),
              ),
            ),
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
              builder: (ctx) => const RecordHabitInterfacePopUp()
          );
        },
      ),
    );
  }
}
