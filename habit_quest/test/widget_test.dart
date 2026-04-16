import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habit_quest/main.dart';

// Screens
import 'package:habit_quest/screens/habit_history_screen.dart';
import 'package:habit_quest/screens/home_page_screen.dart';
import 'package:habit_quest/screens/manage_habits_screen.dart';

// Interfaces
import 'package:habit_quest/interfaces/add_habit_wizard_pop_up.dart';
import 'package:habit_quest/interfaces/app_drawer.dart';
import 'package:habit_quest/interfaces/edit_habit_interface_pop_up.dart';
import 'package:habit_quest/interfaces/notification_interface_pop_up.dart';
import 'package:habit_quest/interfaces/record_habit_interface_pop_up.dart';

// Database
import 'package:habit_quest/database/app_database.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/repositories/habit_repository.dart';


void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;

  Future<void> initTestDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    HabitRepository.initialize(
      habitDao: database.habitDao,
      habitRecordDao: database.habitRecordDao
    );
  }

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initTestDatabase();
  });

  testWidgets('App Has A Title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HabitQuestApp());

    // Verify that our app has a Title.
    expect(find.text("Habit Quest"), findsOneWidget);
  });

  testWidgets("Homepage containts the correct text", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const HomePageScreen()));

    expect(find.textContaining("Today's Score:"), findsOneWidget);
    expect(find.text("Todo:"), findsOneWidget);
  });

  testWidgets("The Navigation Panel contains the correct options.", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const AppDrawer()));

    // Test for "Home"
    expect(find.text("Home"), findsOneWidget);

    // Test for "Manage Habits"
    expect(find.text("Manage Habits"), findsOneWidget);

    // Test for "Habit History"
    expect(find.text("Habit History"), findsOneWidget);

    // Test for "Settings"
    expect(find.text("Settings"), findsOneWidget);
  });

  testWidgets("Each page contains the navigation 'hamburger' button", (WidgetTester tester) async {

    // Home Page Screen
    await tester.pumpWidget(MaterialApp(home: const HomePageScreen()));
    // find hamburger button
    final hamburger1 = find.byType(DrawerButton);

    expect(hamburger1, findsOneWidget);

    await tester.tap(hamburger1);
    await tester.pumpAndSettle();

    expect(find.text("Settings"), findsOneWidget);

    // Manage Habits
    await tester.pumpWidget(MaterialApp(home: const ManageHabitsScreen()));
    // find hamburger button
    final hamburger2 = find.byType(DrawerButton);

    expect(hamburger2, findsOneWidget);

    await tester.tap(hamburger2);
    await tester.pumpAndSettle();

    expect(find.text("Settings"), findsOneWidget);

    // Habit History Screen
    await tester.pumpWidget(MaterialApp(home: const HabitHistoryScreen()));
    // find hamburger button
    final hamburger3 = find.byType(DrawerButton);

    expect(hamburger3, findsOneWidget);

    await tester.tap(hamburger3);
    await tester.pumpAndSettle();

    final settingsButton = find.text("Settings");
    expect(settingsButton, findsOneWidget);

    // Settings screen
    await tester.tap(settingsButton);
    await tester.pump();
    // find hamburger button
    final hamburger4 = find.byType(DrawerButton);

    expect(hamburger4, findsOneWidget);

    await tester.tap(hamburger4);
    await tester.pump();

    final homepage = find.text("Home");
    expect(homepage, findsOneWidget);
  });

  testWidgets("Manage Habits has the correct title", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const ManageHabitsScreen()));
    expect(find.text("Manage Habits"), findsOneWidget);
  });

  testWidgets("Habit History has the correct title", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const HabitHistoryScreen()));
    expect(find.text("Habit History"), findsOneWidget);
  });

  testWidgets("Record Habit interface has the correct text", (WidgetTester tester) async {
    await tester.pumpWidget(
      Material(child: MaterialApp(home: RecordHabitInterfacePopUp()))
    );

    expect(find.text("Record A Habit"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.textContaining("Save"), findsOneWidget);
    expect(find.textContaining("Time"), findsOneWidget);
    expect(find.textContaining("Date"), findsOneWidget);
    expect(find.textContaining("Select Habit"), findsOneWidget);
    expect(find.text("Choose a habit..."), findsOneWidget);
  });

  testWidgets("Homepage contains a Record Habit button", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const HomePageScreen()));

    final plusButton = find.byType(FloatingActionButton);
    expect(plusButton, findsOneWidget);

    await tester.tap(plusButton);
    await tester.pump();

    expect(find.text("Record A Habit"), findsOneWidget);

    expect(find.text("Cancel"), findsOneWidget);
    expect(find.textContaining("Save"), findsOneWidget);
  });

  testWidgets("Add Habit Interface contains the correct text and buttons", (WidgetTester tester) async {
    await tester.pumpWidget(Material(child: MaterialApp(home: const AddHabitWizardPopUp())));

    expect(find.text("Add A New Habit (Step 1/3)"), findsOneWidget);
    expect(find.textContaining("START"), findsNWidgets(2));
    expect(find.textContaining("STOP"), findsNWidgets(2));
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);

    await tester.tap(find.text("Next"));
    await tester.pump();

    expect(find.text("Name Your Habit (Step 2/3)"), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);

    await tester.enterText(find.byType(TextField), "Jogging, 30 minutes");
    await tester.pump();

    expect(find.text("Jogging, 30 minutes"), findsOneWidget);

    // ### TODO: uncomment the below once box size is fixed ###
    // await tester.tap(find.text("Next"));
    // await tester.pump();

    // expect(find.textContaining("Habit Importance:"), findsOneWidget);
    // expect(find.textContaining("(Step 3/3)"), findsOneWidget);
    // expect(find.byType(Slider), findsOneWidget);
    // expect(find.textContaining("Importance Rating"), findsOneWidget);
    // expect(find.text("Cancel"), findsOneWidget);
    // expect(find.text("Finish & Save"), findsOneWidget);
  });

  // TODO: test Settings Screen
  testWidgets("Settings screen contains the correct options", (WidgetTester tester) async {
    // cannot directly pump Settings screen widget;
    // have to pump Homepage and navigate to Settings from there
    await tester.pumpWidget(MaterialApp(home: const HomePageScreen()));

    // open Nav. Panel
    await tester.tap(find.byType(DrawerButton));
    await tester.pumpAndSettle();

    // select Settings
    final settingsButton = find.text("Settings");
    expect(settingsButton, findsOneWidget);
    await tester.tap(settingsButton);
    await tester.pump();

    // test for screen transition
    expect(find.byType(DrawerButton), findsOneWidget);
    expect(find.text("Home"), findsNothing);

    // test for Title
    expect(find.text("Settings"), findsOneWidget);

    // test for options
    expect(find.text("Export Data"), findsOneWidget);
    expect(find.text("Save Habit History to CSV"), findsOneWidget);
    expect(find.text("Clear History"), findsOneWidget);
    expect(find.text("Notification Settings"), findsOneWidget);
    expect(find.text("Dark Mode"), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
    final credits = find.text("Credits");
    expect(credits, findsOneWidget);

    // open Credits
    await tester.tap(credits);
    await tester.pump();

    // test Credits contents
    expect(find.text("Credits"), findsOneWidget);
    expect(find.textContaining("Meyers, Shades"), findsOneWidget);
    expect(find.textContaining("Azevedo, Luca"), findsOneWidget);
    expect(find.textContaining("Echeverry, Miguel"), findsOneWidget);
    expect(find.textContaining("Luc, Marvens"), findsOneWidget);
  });

  testWidgets("Edit Habit interface contains the correct text", (WidgetTester tester) async {
    Habit mockHabit = Habit(id: 0, habitName: "Climbing, 30 minutes", importanceLevel: 4, createdAtMilliseconds: DateTime.now().millisecondsSinceEpoch, isArchived: false);

    await tester.pumpWidget(Material(child: MaterialApp(home: EditHabitInterfacePopUp(habit: mockHabit))));

    // test for interface Title
    expect(find.text("Edit Habit"), findsOneWidget);

    // test for habit re-naming field
    expect(find.byType(TextField), findsOneWidget);

    // test for habit importance slider
    expect(find.byType(Slider), findsOneWidget);

    // test for save and cancel buttons
    final cancelButton = find.byType(TextButton);
    final saveButton = find.byType(ElevatedButton);

    expect(cancelButton, findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);

    expect(saveButton, findsOneWidget);
    expect(find.text("Save Changes"), findsOneWidget);

    // test for prompts
    expect(find.text("Habit Name"), findsOneWidget);
    expect(find.text("Change Importance:"), findsOneWidget);
  });

  testWidgets("Notification interface has the correct options", (WidgetTester tester) async {
    await tester.pumpWidget(Material(child: MaterialApp(home: const NotificationInterfacePopUp())));

    // find title
    expect(find.text("Notification Settings"), findsOneWidget);

    // find Allow Daily Reminder toggle
    expect(find.text("Allow Daily Reminders"), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);

    // test Frequency dropdown
    final dropdown = find.byType(DropdownButton<String>);
    expect(find.text("Daily Reminder Frequency"), findsOneWidget);
    expect(dropdown, findsOneWidget);
    expect(find.text("1"), findsOneWidget);

    await tester.tap(dropdown);
    await tester.pump();

    expect(find.text("1"), findsNWidgets(2));
    expect(find.text("2"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);
  });
}
