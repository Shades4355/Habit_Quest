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
        _completedHabit[habit.id!] = await _habitRepo.isCompletedOnDate(habit.id!, DateTime.now());
        _uncompletedHabit[habit.id!] = !(await _habitRepo.isCompletedOnDate(habit.id!, DateTime.now()));
      }
    }

    _isLoading = false;
    notifyListeners();
  }
  
  /// Get top uncompleted habits for today, sorted by importance level
  List<Habit> topUncompletedHabits(List<Habit> habits, {int limit = 5}) {
    final uncompleted = habits
        .where((h) =>
            h.id != null &&
            h.importanceLevel > 0 &&
            (_uncompletedHabit[h.id] ?? true))
        .toList();
    uncompleted.sort((a, b) => b.importanceLevel.compareTo(a.importanceLevel));
    return uncompleted.take(limit).toList();
  }

  /// Get uncompleted habits for today
  List<Habit> unCompletedHabits(List<Habit> habits) {
    return habits
        .where((h) => h.id != null && (_uncompletedHabit[h.id] ?? true))
        .toList();
  }

  /// Toggle completion status for a habit
  Future<void> recordHabit(int habitId, DateTime date) async {
    await _habitRepo.recordHabit(habitId, date);
    await loadAll();
  }

  /// Marks a habit as completed for today
  Future<void> recordHabitToday(int habitId) async {
    await _habitRepo.recordHabit(habitId, DateTime.now());
    await loadAll();
  }

  /// Deletes a habit record and refreshes all dependent score and status data.
  Future<void> deleteHabitRecord(HabitRecord record) async {
    await _habitRepo.deleteRecordById(record.recordId!);
    await loadAll();
  }

  /// Edits a habit record by replacing the old record with updated values.
  Future<void> editHabitRecord({
    required HabitRecord oldRecord,
    required HabitRecord newRecord,
  }) async {
    await _habitRepo.editRecord(
      oldRecord: oldRecord,
      newRecord: newRecord,
    );
    await loadAll();
  }

  /// Get records for a specific day (synchronous version) 
  List<HabitRecord> getRecordsForDaySync(DateTime date) {
    final key = _habitRepo.dayKey(date);
    return _records.where((r) => r.date == key).toList();
  }

  /// Get score for a specific date
  Future<int?> getScoreForDate(DateTime date) => _habitRepo.getScoreForDate(date);

  Future<void> clearAllRecords() async {
    await _habitRepo.clearAllRecords();
    await loadAll();
  }

  // ==================== NEW TOOLTIP HELPERS ====================

 /// Calculates total positive points recorded on a specific date
  int getPositivePointsForDate(DateTime date) {
    final dailyRecords = getRecordsForDaySync(date);
    // Sum only the records where scoreDelta is greater than 0
    return dailyRecords
        .where((r) => r.scoreDelta > 0)
        .fold(0, (sum, r) => sum + r.scoreDelta);
  }

  /// Calculates total negative points recorded on a specific date
  int getNegativePointsForDate(DateTime date) {
    final dailyRecords = getRecordsForDaySync(date);
    // Sum only the records where scoreDelta is less than 0
    return dailyRecords
        .where((r) => r.scoreDelta < 0)
        .fold(0, (sum, r) => sum + r.scoreDelta);
  }
}