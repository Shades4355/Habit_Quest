import 'package:flutter/material.dart';
import 'package:habit_quest/database/entities/habit_record.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/repositories/habit_repository.dart';

class HabitRecordProvider extends ChangeNotifier {
  // Singleton pattern for repository access
  HabitRepository get _habitRepo => HabitRepository.instance;
  
  // List of habit records
  List<HabitRecord> _records = [];
  List<HabitRecord> get records => _records;

  // Completion status for today's habits (habitId -> completed)
  Map<int, bool> _completedHabit = {};
  Map<int, bool> get completedHabit => _completedHabit;

  // Uncompleted status for today's habits (habitId -> uncompleted)
  Map<int, bool> _uncompletedHabit = {};
  Map<int, bool> get uncompletedHabit => _uncompletedHabit;

  // Todays score
  int _todayScore = 0;
  int get todayScore => _todayScore;

  // Weekly scores for chart
  List<int?> _weekScores = [];
  List<int?> get weekScores => _weekScores;

  // Monthly scores for chart
  List<int?> _monthScores = [];
  List<int?> get monthScores => _monthScores;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HabitRecordProvider() {
    loadAll();
  }

  /// Load data for the habit records
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _records = await _habitRepo.getRecordsForLastNDays(30);
    _todayScore = await _habitRepo.getScoreForDate(DateTime.now()) ?? 0;
    _weekScores = await _habitRepo.getScoreForLastNDays(7);
    _monthScores = await _habitRepo.getScoreForLastNDays(30);

    // Load completion status for all active habits
    final habits = await _habitRepo.getActiveHabits();
    _completedHabit = {};
    _uncompletedHabit = {};
    for (final habit in habits) {
      if (habit.id != null) {
        _completedHabit[habit.id!] = await _habitRepo.isCompletedToday(habit.id!);
        _uncompletedHabit[habit.id!] = !(await _habitRepo.isCompletedToday(habit.id!));
      }
    }

    _isLoading = false;
    notifyListeners();
  }
  
  List<Habit> topUncompletedHabits(List<Habit> habits, {int limit = 5}) {
    final uncompleted = habits
        .where((h) => h.id != null && (_uncompletedHabit[h.id] ?? true))
        .toList();
    uncompleted.sort((a, b) => b.importanceLevel.abs().compareTo(a.importanceLevel.abs()));
    return uncompleted.take(limit).toList();
  }

  List<Habit> unCompletedHabits(List<Habit> habits) {
    return habits
        .where((h) => h.id != null && (_uncompletedHabit[h.id] ?? true))
        .toList();
  }

  /// Toggle completion status for a habit today
  Future<void> toggleCompletedToday(int habitId) async {
    await _habitRepo.toggleCompletedToday(habitId);
    await loadAll();
  }

  /// Get records for a specific day (synchronous version) 
  List<HabitRecord> getRecordsForDaySync(DateTime date) {
    final key = _habitRepo.dayKey(date);
    return _records.where((r) => r.date == key).toList();
  }

  /// Get score for a specific date
  Future<int?> getScoreForDate(DateTime date) => _habitRepo.getScoreForDate(date);
}