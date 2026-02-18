import 'package:flutter/material.dart';

void main() {
  runApp(const HabitQuestApp());
}

class HabitQuestApp extends StatelessWidget {
  const HabitQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The app will display its name on the top bar[cite: 6].
    // Usually locked to portrait, except for specific screens[cite: 7].
    return MaterialApp(
      title: 'Habit Quest',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // When the User launches the app, they will be on the homepage[cite: 3].
        '/': (context) => const HomePageScreen(),
        '/extended_graph': (context) => const ExtendedGraphScreen(),
        '/manage_habits': (context) => const ManageHabitsScreen(),
        '/habit_history': (context) => const HabitHistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

// ==================== SHARED NAVIGATION DRAWER ====================

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // The "Navigation Panel" is a pop-up (ex: drawer)[cite: 62].
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Text('Habit Quest Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          // The "Navigation Panel" will include options: Home, Manage Habits, Habit History, and Settings[cite: 63].
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            // The "Home" option will take the User to the "Homepage"[cite: 64].
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Manage Habits'),
            // The "Manage Habits" option will take Users to the "Manage Habits" screen[cite: 65, 66].
            onTap: () => Navigator.pushReplacementNamed(context, '/manage_habits'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Habit History'),
            // The "Habit History" option will take Users to the "Habit History" screen[cite: 67].
            onTap: () => Navigator.pushReplacementNamed(context, '/habit_history'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            // The "Settings" option will take Users to the "Settings" screen[cite: 68].
            onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }
}

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
              child: Align(alignment: Alignment.centerLeft, child: Text('Unrecorded Habits (Pending):', style: TextStyle(fontWeight: FontWeight.bold))),
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

// ==================== EXTENDED GRAPH SCREEN ====================

class ExtendedGraphScreen extends StatelessWidget {
  const ExtendedGraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTE: The document states this screen should lock to landscape mode[cite: 27].
    // Orientation locking requires device-specific configuration outside the scope of a simple UI mockup.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extended Graph'),
        // There will be a back button... which will take Users back to the "Homepage"[cite: 29].
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        // The "Extended Graph" screen will display a line graph showing User scores over the last 30 days[cite: 28].
        child: Container(
          height: 300,
          width: double.infinity,
          color: Colors.indigo.shade200,
          child: const Center(child: Text('Placeholder: 30-Day Score Line Graph (Landscape View)')),
        ),
      ),
    );
  }
}

// ==================== MANAGE HABITS SCREEN ====================

class ManageHabitsScreen extends StatelessWidget {
  const ManageHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      // The "Manage Habits" screen will display the text "Manage Habits" at the top[cite: 70].
      appBar: AppBar(title: const Text('Manage Habits')),
      // The "Manage Habits" screen will display all current habits[cite: 72].
      body: ListView.builder(
        itemCount: 5, // Placeholder count
        itemBuilder: (ctx, i) => ListTile(
          leading: CircleAvatar(child: Text('${i + 1}')), // Placeholder for score value
          title: Text('Current Habit Name ${i + 1}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Each habit will have an "Edit" button attached to its display[cite: 77].
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                // The "Edit" button will bring up the "Edit Habit" interface[cite: 79].
                onPressed: () {
                   showDialog(
                    context: context,
                    builder: (ctx) => const EditHabitInterfacePopUp()
                  );
                },
              ),
              // Each habit will have a "Delete" button attached to its display[cite: 81].
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Delete Habit')));
                },
              ),
            ],
          ),
        ),
      ),
      // The "Manage Habits" screen will include the ability to add new habits... button at the bottom center[cite: 73, 74].
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // This button will bring up the "Add Habit" interface[cite: 75].
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => const AddHabitWizardPopUp()
          );
        },
        label: const Text('Add New Habit'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

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

// ==================== SETTINGS SCREEN ====================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // "Export Data" option[cite: 180].
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Save Habit History to CSV'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Exporting data... [cite: 185]')));
            },
          ),
          const Divider(),
          // "Clear History" option[cite: 191].
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear History', style: TextStyle(color: Colors.red)),
            // The "Clear History" button will prompt the User to confirm... with a pop-up[cite: 193].
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text('Are you sure you want to clear your entire habit history?'),
                  actions: [
                    TextButton(
                      // If the User clicks "Cancel", close the pop-up[cite: 198].
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      // If the User confirms, delete the entire Habit History[cite: 196].
                      onPressed: () {
                         Navigator.pop(ctx);
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: History Cleared')));
                      },
                      child: const Text('Confirm', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                )
              );
            },
          ),
          const Divider(),
          // "Notification Settings" option[cite: 202].
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            // The "Notification Settings" option will open the "Notifications" interface[cite: 204].
            onTap: () {
               showModalBottomSheet(
                context: context,
                builder: (ctx) => const NotificationInterfacePopUp()
              );
            },
          ),
          const Divider(),
          // "Dark Mode" with an on/off slider[cite: 205, 207].
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
                // Slider presents different colors in on/off positions [cite: 218] (handled by material switch default).
              });
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dark Mode set to: $_darkMode')));
            },
          ),
          const Divider(),
          // "Credits" option[cite: 219].
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Credits'),
            // The "Credits" option will open a pop-up[cite: 220].
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => const AlertDialog(
                  title: Text('Credits'),
                  // Displays team names [cite: 222] and thanks the user[cite: 223].
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('The Team:\n- Meyers, Shades\n- Azevedo, Luca\n- Echeverry, Miguel\n- Luc, Marvens'),
                      SizedBox(height: 20),
                      Text('Thank you for using Habit Quest!'),
                    ],
                  ),
                )
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================== INTERFACES (POP-UPS) ====================

// --- Record Habit Interface [cite: 33] ---
class RecordHabitInterfacePopUp extends StatelessWidget {
  const RecordHabitInterfacePopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding for bottom sheet to avoid keyboard overlap if necessary
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The prompt will display "Record A Habit"[cite: 36].
          const Text('Record A Habit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          // Allow user to select a date[cite: 38].
          // Defaults to current day[cite: 39]. Users can select from pop-up calendar[cite: 43].
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date: Today (Placeholder)'),
            trailing: const Icon(Icons.edit),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Date Picker Pop-up')));
            },
          ),
          // Allow selecting a time[cite: 45]. Defaults to current time[cite: 46].
           ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Time: Now (Placeholder)'),
            trailing: const Icon(Icons.edit),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Time Picker Pop-up')));
            },
          ),
          const SizedBox(height: 20),
          // The interface will prompt the User for the completed habit[cite: 47].
          const Text('Select Habit Completed:'),
          // The User will select a habit from a drop down list of all current habits[cite: 49].
          DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Choose a habit...'),
            items: <String>['Habit A', 'Habit B', 'Habit C'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // The interface will have a "Cancel" button[cite: 54].
              // It closes the interface without saving and returns to Homepage[cite: 55, 56].
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
               // The interface will have a "save" button[cite: 50].
               // It saves the habit, updates score, closes interface, returns to Homepage[cite: 51, 52, 53].
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Habit Recorded & Saved')));
                },
                child: const Text('Save Record'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- Add Habit Wizard Pop-up (General [cite: 89]) ---
class AddHabitWizardPopUp extends StatefulWidget {
  const AddHabitWizardPopUp({super.key});
  @override
  State<AddHabitWizardPopUp> createState() => _AddHabitWizardPopUpState();
}

class _AddHabitWizardPopUpState extends State<AddHabitWizardPopUp> {
  int _currentDisplay = 1;
  String _habitType = 'Start'; // Placeholder for Display 1 choice
  double _importanceRating = 3.0; // Placeholder for Display 3 scale [cite: 122]

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Display 1 content ---
          if (_currentDisplay == 1) ...[
            // Display 1 will display the prompt "Add A New Habit"[cite: 94].
            const Text('Add A New Habit (Step 1/3)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Prompt the User to select whether they are creating a habit they wish to start or stop[cite: 95].
            const Text('Are you trying to START or STOP this habit?'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(label: const Text('START'), selected: _habitType == 'Start', onSelected: (b) => setState(() => _habitType = 'Start')),
                const SizedBox(width: 10),
                ChoiceChip(label: const Text('STOP'), selected: _habitType == 'Stop', onSelected: (b) => setState(() => _habitType = 'Stop')),
              ],
            ),
          ],

          // --- Display 2 content ---
          if (_currentDisplay == 2) ...[
             // Display 2 will replace Display 1[cite: 104].
             // Prompt the User for the name of the new habit[cite: 105].
            const Text('Name Your Habit (Step 2/3)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Provide a text field for the User to enter the habit's name[cite: 107].
            const TextField(decoration: InputDecoration(labelText: 'Habit Name', border: OutlineInputBorder())),
          ],

           // --- Display 3 content ---
          if (_currentDisplay == 3) ...[
            // Display 3 will display the new habit's name[cite: 120].
            const Text('Habit Importance: [Name Placeholder] (Step 3/3)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Prompt Users to select an importance rating... scale ranging from 1 to 5[cite: 121, 122].
            Text('Importance Rating: ${_importanceRating.round()}'),
            Slider(
              value: _importanceRating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _importanceRating.round().toString(),
              onChanged: (val) => setState(() => _importanceRating = val),
            ),
            // Below the scale... provide an explanation for the numbers' corresponding importances[cite: 123].
            const Padding(
              padding: EdgeInsets.all(8.0),
              // Explanations for 1-5[cite: 124, 125, 126, 127, 128, 129].
              child: Text('1: Once in a while\n3: Most of the time\n5: Utmost importance', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            ),
          ],

          const SizedBox(height: 20),
          // --- Wizard Navigation Buttons ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // "Cancel" button behavior changes slightly per display, but generally closes the interface and returns to Manage Habits[cite: 97, 99, 108, 110, 130, 132, 133].
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              // "Save" button behavior advances displays or finalizes[cite: 100, 114, 134].
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_currentDisplay < 3) {
                      // Advances the interface to next display[cite: 102, 117].
                      _currentDisplay++;
                    } else {
                      // Final Save: Create new habit, apply score logic, close interface[cite: 135, 140, 142].
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: New Habit Saved with calculated score')));
                    }
                  });
                },
                child: Text(_currentDisplay < 3 ? 'Next' : 'Finish & Save'),
              ),
            ],
          ),
           const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- Edit Habit Interface [cite: 147] ---
class EditHabitInterfacePopUp extends StatelessWidget {
  const EditHabitInterfacePopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // The "Edit Habit" interface will display the text "Edit Habit" at the top[cite: 148].
      title: const Text('Edit Habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provide the User with the ability to change the habit's name[cite: 156].
          // Text field defaults to current name[cite: 157, 159].
          TextField(
            decoration: const InputDecoration(labelText: 'Habit Name'),
            controller: TextEditingController(text: 'Current Name Placeholder'),
          ),
          const SizedBox(height: 20),
          // Provide the User with the ability to change the importance[cite: 151].
          const Text('Change Importance:'),
          // Defaults to current importance[cite: 153].
          Slider(value: 3, min: 1, max: 5, divisions: 4, label: '3', onChanged: (val){}),
          const Text('Note: Changing importance only applies to future records[cite: 155].', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      actions: [
        // "Cancel" button closes without changes[cite: 160, 161].
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        // "Save" button saves changes and closes interface[cite: 163, 164, 165].
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Habit Updates Saved')));
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}

// --- Notification Interface [cite: 224] ---
class NotificationInterfacePopUp extends StatefulWidget {
  const NotificationInterfacePopUp({super.key});
  @override
  State<NotificationInterfacePopUp> createState() => _NotificationInterfacePopUpState();
}

class _NotificationInterfacePopUpState extends State<NotificationInterfacePopUp> {
  bool _allowDaily = true;
  String _frequency = '1';

  @override
  Widget build(BuildContext context) {
    return Padding(
       padding: const EdgeInsets.all(16.0),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           const Text('Notification Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
           const SizedBox(height: 20),
           // "Allow Daily Reminders" with an on/off toggle[cite: 228, 230].
           SwitchListTile(
             title: const Text('Allow Daily Reminders'),
             value: _allowDaily,
             // When on, send notifications; off, send none[cite: 232, 234].
             onChanged: (val) => setState(() => _allowDaily = val),
           ),
           const Divider(),
           // "Daily Reminder Frequency" with a dropdown list (1, 2, 3)[cite: 236, 238, 239].
           ListTile(
             title: const Text('Daily Reminder Frequency'),
             // Grayed out when "Allow Daily Reminders" is off[cite: 243].
             enabled: _allowDaily,
             trailing: DropdownButton<String>(
               value: _frequency,
               // The app will send 1/2/3 reminder(s) depending on selection[cite: 241].
               items: ['1', '2', '3'].map((String value) {
                 return DropdownMenuItem<String>(value: value, child: Text(value));
               }).toList(),
               onChanged: _allowDaily ? (String? newValue) => setState(() => _frequency = newValue!) : null,
             ),
           ),
           const SizedBox(height: 20),
           const Text('Notifications limited to: "Reminder: Record Your Habits!" [cite: 245]', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
         ],
       ),
    );
  }
}