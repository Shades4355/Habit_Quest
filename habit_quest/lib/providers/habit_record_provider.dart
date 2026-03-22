import 'package:flutter/material.dart';
import 'package:habit_quest/database/entities/habit_record.dart';
import 'package:habit_quest/repositories/habit_repository.dart';

class HabitRecordProvider extends ChangeNotifier {
  HabitRepository get _habitRepo => HabitRepository.instance;
  List<HabitRecord> _records = [];
  List<HabitRecord> get records => _records;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HabitRecordProvider() {
    loadRecordsForLastNDays(30);
  }


  Future<void> loadRecordsForLastNDays(int n) async {
    _isLoading = true;
    notifyListeners();

    _records = await _habitRepo.getRecordsForLastNDays(n);

    _isLoading = false;
    notifyListeners();
  }

  Future<List<HabitRecord>> getRecordsForHabit(int habitId) => _habitRepo.getRecordsForHabit(habitId);

  Future<List<HabitRecord>> getRecordsForDate(DateTime date) => _habitRepo.getRecordsForDate(date);

  List<HabitRecord> getRecordsForDaySync(DateTime date) {
  final key = _habitRepo.dayKey(date);
  return _records.where((r) => r.date == key).toList();
}

  Future<int?> getScoreForDate(DateTime date) => _habitRepo.getScoreForDate(date);
}