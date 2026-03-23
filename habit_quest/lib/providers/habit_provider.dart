import 'package:flutter/material.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/repositories/habit_repository.dart';

class HabitProvider extends ChangeNotifier {
  // Singleton pattern for repository access
  HabitRepository get _habitRepo => HabitRepository.instance;

  // Todays score
  int _todayScore = 0;
  int get todayScore => _todayScore;

  // Completion status for each habit (key: habitId, value: completed today)
  Map<int, bool> _completionStatus = {};
  Map<int, bool> get completionStatus => _completionStatus;

  // List of active habits
  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Weekly scores for chart
  List<int?> _weekScores = [];
  List<int?> get weekScores => _weekScores;

  // Monthly scores for chart
  List<int?> _monthScores = [];
  List<int?> get monthScores => _monthScores;

  HabitProvider() {
    loadHabits();
  }

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    _habits = await _habitRepo.getActiveHabits();
    _todayScore = await _habitRepo.getScoreForDate(DateTime.now()) ?? 0;
    _weekScores = await _habitRepo.getScoreForLastNDays(7);
    _monthScores = await _habitRepo.getScoreForLastNDays(30);
    _completionStatus = {};
    for (final habit in _habits) {
      if (habit.id != null) {
        _completionStatus[habit.id!] = await _habitRepo.isCompletedToday(habit.id!);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await _habitRepo.addHabit(habit);
    await loadHabits();
  }

  Future<void> removeHabit(Habit habit) async {
    final id = habit.id;
    if (id == null) return;

    await _habitRepo.archiveHabit(id);
    await loadHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitRepo.updateHabit(habit);
    await loadHabits();
  }

  Future<void> toggleCompletedToday(int habitId) async {
    await _habitRepo.toggleCompletedToday(habitId);
    await loadHabits();
  }

  Future<int?> getScoreForDate(DateTime date) => _habitRepo.getScoreForDate(date);

  Future<List<int?>> getScoreForLastNDays(int n) => _habitRepo.getScoreForLastNDays(n);

}