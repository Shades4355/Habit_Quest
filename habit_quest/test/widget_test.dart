// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habit_quest/main.dart';
import 'package:habit_quest/screens/HomePageScreen.dart';

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
    expect(find.textContaining("Unrecorded Habits"), findsOneWidget);
  });

  testWidgets("Homepage contains the navigation 'hamburger'", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const HomePageScreen()));
    // find hamburger button
    final hamburger = find.byType(DrawerButton);

    expect(hamburger, findsOneWidget);

    await tester.tap(hamburger);
    await tester.pump();

    expect(find.text("Settings"), findsOneWidget);
  });
}
