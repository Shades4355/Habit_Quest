import 'package:flutter/material.dart';


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
