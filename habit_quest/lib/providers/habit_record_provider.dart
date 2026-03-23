import 'package:flutter/material.dart';
import 'package:habit_quest/database/entities/habit_record.dart';
import 'package:habit_quest/repositories/habit_repository.dart';

class HabitRecordProvider extends ChangeNotifier {
  // Singleton pattern for repository access
  HabitRepository get _habitRepo => HabitRepository.instance;
  
  // List of habit records
  List<HabitRecord> _records = [];
  List<HabitRecord> get records => _records;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HabitRecordProvider() {
    loadRecordsForLastNDays(30);
  }

  // Load records for the last N days (default 30)
  Future<void> loadRecordsForLastNDays(int n) async {
    _isLoading = true;
    notifyListeners();

    _records = await _habitRepo.getRecordsForLastNDays(n);

    _isLoading = false;
    notifyListeners();
  }

  /// Get records for a specific habit
  Future<List<HabitRecord>> getRecordsForHabit(int habitId) => _habitRepo.getRecordsForHabit(habitId);

  /// Get records for a specific date
  Future<List<HabitRecord>> getRecordsForDate(DateTime date) => _habitRepo.getRecordsForDate(date);

  /// Synchronous version for quick access (assumes records are already loaded)
  List<HabitRecord> getRecordsForDaySync(DateTime date) {
    final key = _habitRepo.dayKey(date);
    return _records.where((r) => r.date == key).toList();
  }

  /// Get score for a specific date
  Future<int?> getScoreForDate(DateTime date) => _habitRepo.getScoreForDate(date);
}