import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habit_quest/main.dart';

import 'package:habit_quest/screens/HabitHistoryScreen.dart';
import 'package:habit_quest/screens/HomePageScreen.dart';
import 'package:habit_quest/screens/ManageHabitsScreen.dart';

import 'package:habit_quest/interfaces/AppDrawer.dart';
import 'package:habit_quest/interfaces/RecordHabitInterfacePopUp.dart';
import 'package:habit_quest/interfaces/AddHabitWizardPopUp.dart';
import 'package:habit_quest/interfaces/EditHabitInterfacePopUp.dart';


void main() {
  testWidgets('App Has A Title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HabitQuestApp());

    // Verify that our app has a Title.
    expect(find.text("Habit Quest"), findsOne);
  });

  testWidgets("Homepage containts the correct text", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const HomePageScreen()));

    expect(find.textContaining("Today's Score:"), findsOneWidget);
    expect(find.text("Unrecorded Habits:"), findsOneWidget);
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
    await tester.pump();

    expect(find.text("Settings"), findsOneWidget);

    // Manage Habits
    await tester.pumpWidget(MaterialApp(home: const ManageHabitsScreen()));
    // find hamburger button
    final hamburger2 = find.byType(DrawerButton);

    expect(hamburger2, findsOneWidget);

    await tester.tap(hamburger2);
    await tester.pump();

    expect(find.text("Settings"), findsOneWidget);

    // Habit History Screen
    await tester.pumpWidget(MaterialApp(home: const HabitHistoryScreen()));
    // find hamburger button
    final hamburger3 = find.byType(DrawerButton);

    expect(hamburger3, findsOneWidget);

    await tester.tap(hamburger3);
    await tester.pump();

    expect(find.text("Settings"), findsOneWidget);
  });

  testWidgets("Manage Habits has the correct title", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const ManageHabitsScreen()));
    expect(find.text("Manage Habits"), findsOneWidget);
  });

  testWidgets("Habit History", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const HabitHistoryScreen()));
    expect(find.text("Habit History"), findsOneWidget);
  });

  testWidgets("Record Habit Interface", (WidgetTester tester) async {
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

  testWidgets("Homepage contains a record habit button", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const HomePageScreen()));
    final plusButton = find.byType(FloatingActionButton);
    expect(plusButton, findsOneWidget);

    await tester.tap(plusButton);
    await tester.pump();

    expect(find.text("Record A Habit"), findsOneWidget);

    final cancelButton = find.text("Cancel");
    final saveButton = find.textContaining("Save");

    expect(cancelButton, findsOneWidget);
    expect(saveButton, findsOneWidget);
  });

  testWidgets("Add Habit Interface", (WidgetTester tester) async {
    await tester.pumpWidget(Material(child: MaterialApp(home: const AddHabitWizardPopUp())));

    expect(find.text("Add A New Habit (Step 1/3)"), findsOneWidget);
    expect(find.textContaining("START"), findsExactly(2));
    expect(find.textContaining("STOP"), findsExactly(2));
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);

    await tester.tap(find.text("Next"));
    await tester.pump();

    expect(find.text("Name Your Habit (Step 2/3)"), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);

    await tester.enterText(find.byType(TextField), "Jogging, 30 minutes");
    await tester.pump();

    expect(find.text("Jogging, 30 minutes"), findsOne);

    await tester.tap(find.text("Next"));
    await tester.pump();

    expect(find.textContaining("Habit Importance:"), findsOneWidget);
    expect(find.textContaining("(Step 3/3)"), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.textContaining("Importance Rating"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("Finish & Save"), findsOneWidget);
  });
}
