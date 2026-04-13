import 'package:flutter/material.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/repositories/habit_repository.dart';

class HabitProvider extends ChangeNotifier {
  // Singleton pattern for repository access
  HabitRepository get _habitRepo => HabitRepository.instance;

  // List of ALL habits
  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  // List of active habits
  List<Habit> _activeHabits = [];
  List<Habit> get activeHabits => _activeHabits;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HabitProvider() {
    loadHabits();
  }

  /// Load active habits from the database
  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    _activeHabits = await _habitRepo.getActiveHabits();
    _habits = _activeHabits + await _habitRepo.getArchivedHabits();

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new habit
  Future<void> addHabit(Habit habit) async {
    await _habitRepo.addHabit(habit);
    await loadHabits();
  }

  /// Archive (soft delete) a habit
  Future<void> removeHabit(Habit habit) async {
    final id = habit.id;
    if (id == null) return;

    await _habitRepo.archiveHabit(id);
    await loadHabits();
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit habit) async {
    await _habitRepo.updateHabit(habit);
    await loadHabits();
  }

  Future<void> clearAllHabits() async {
    await _habitRepo.clearAllHabits();
    await loadHabits();
  }
}