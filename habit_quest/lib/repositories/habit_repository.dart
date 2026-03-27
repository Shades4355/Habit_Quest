import 'package:habit_quest/database/dao/habit_dao.dart';
import 'package:habit_quest/database/dao/habit_record_dao.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/database/entities/habit_record.dart';

class HabitRepository {
  static HabitRepository? _instance;

  static HabitRepository get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('HabitRepository not initialized. Call HabitRepository.initialize(...) first.');
    }
    return instance;
  }

  static HabitRepository initialize({
    required HabitDao habitDao,
    required HabitRecordDao habitRecordDao,
  }) => _instance ??= HabitRepository._internal(habitDao, habitRecordDao);

  final HabitDao habitDao;
  final HabitRecordDao habitRecordDao;

  HabitRepository._internal(this.habitDao, this.habitRecordDao);

  /// Converts a DateTime to an integer key in the format MMDDYYYY 
  int dayKey(DateTime date) => date.month * 1000000 + date.day * 10000 + date.year;

  /// Retrieves all active (non-archived) habits from the database
  Future<List<Habit>> getActiveHabits() => habitDao.findActiveHabits();

  /// Retrieves all archived habits from the database
  Future<List<Habit>> getArchivedHabits() => habitDao.findArchivedHabits();

  /// Retrieves a habit by its ID
  Future<Habit?> getHabitById(int id) => habitDao.findHabitById(id);

  /// Adds a new habit to the database.
  /// If a matching habit exists in archive, it is restored instead of inserting a duplicate.
  Future<int?> addHabit(Habit habit) async {
    final normalizedName = habit.habitName.trim().toLowerCase();
    final archivedHabits = await habitDao.findArchivedHabits();

    Habit? archivedMatch;
    for (final archivedHabit in archivedHabits) {
      if (archivedHabit.habitName.trim().toLowerCase() == normalizedName) {
        archivedMatch = archivedHabit;
        break;
      }
    }

    if (archivedMatch != null && archivedMatch.id != null) {
      final restoredHabit = Habit(
        id: archivedMatch.id,
        habitName: archivedMatch.habitName,
        habitDescription: habit.habitDescription,
        importanceLevel: habit.importanceLevel,
        createdAtMilliseconds: archivedMatch.createdAtMilliseconds,
        isArchived: false,
      );

      await habitDao.updateHabit(restoredHabit);
      return restoredHabit.id;
    }

    return habitDao.insertHabit(habit);
  }

  /// Updates an existing habit in the database
  Future<int?> updateHabit(Habit habit) => habitDao.updateHabit(habit);

  /// archives a habit from the database
  Future<int?> archiveHabit(int id) => habitDao.archiveHabit(id);

  /// unarchives a habit from the database
  Future<int?> unarchiveHabit(int id) => habitDao.unarchiveHabit(id);

  /// Toggles the completion status of a habit for the day
  Future<void> recordHabit(int habitId, DateTime date) async {
    final habit = await habitDao.findHabitById(habitId);

    if (habit == null) return;

    await habitRecordDao.insertRecord(HabitRecord(
      habitId: habitId,
      date: dayKey(date),
      scoreDelta: habit.importanceLevel,
    ));
  }

  /// Checks if a habit is completed on a specific date
  Future<bool> isCompletedOnDate(int habitId, DateTime date) async {
    final count = await habitRecordDao.countRecordsForHabit(habitId, dayKey(date)) ?? 0;
    return count > 0;
  }

  /// Gets all habit records for a specific habit
  Future<List<HabitRecord>> getRecordsForHabit(int habitId) => habitRecordDao.findRecordsForHabit(habitId);

  /// Gets all habit records for a specific date
  Future<List<HabitRecord>> getRecordsForDate(DateTime date) => habitRecordDao.findRecordsForDate(dayKey(date));

  /// Gets the total score across all habit records for a specific date
  Future<int?> getScoreForDate(DateTime date) => habitRecordDao.getScoreForDate(dayKey(date));

  /// Gets the total score across all habit records for the last N days
  Future<List<int?>> getScoreForLastNDays(int n) {
    final now = DateTime.now();
    final past = List.generate(
      n, (i) => dayKey(now.subtract(Duration(days: n - i - 1)))
    );
    return Future.wait(past.map((d) => habitRecordDao.getScoreForDate(d)));
  }

  /// Gets all habit records for the last N days
  Future<List<HabitRecord>> getRecordsForLastNDays(int n) async {
    final now = DateTime.now();
    final keys = List.generate(n, (i) => dayKey(now.subtract(Duration(days: i))));
    final results = await Future.wait(keys.map((k) => habitRecordDao.findRecordsForDate(k)));
    return results.expand((r) => r).toList();
  }

  /// Counts the number of records for a specific habit and date
  Future<int?> countRecordsForHabit(int habitId, DateTime date) => habitRecordDao.countRecordsForHabit(habitId, dayKey(date));
}