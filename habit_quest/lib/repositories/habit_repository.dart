import 'package:habit_quest/database/dao/habit_dao.dart';
import 'package:habit_quest/database/dao/habit_record_dao.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/database/entities/habit_record.dart';

class HabitRepository {
  final HabitDao habitDao;
  final HabitRecordDao habitRecordDao;

  HabitRepository({
    required this.habitDao,
    required this.habitRecordDao,
  });

  /// Converts a DateTime to an integer key in the format MMDDYYYY 
  int _dayKey(DateTime date) => date.month * 1000000 + date.day * 10000 + date.year;

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

  /// Marks a habit as completed for today by creating or updating a HabitRecord with a positive scoreDelta
  Future<bool> isCompletedToday(int habitID) async {
    final date = _dayKey(DateTime.now());
    final record = await habitRecordDao.findRecord(habitID, date);
    return record != null;
  }

  /// Toggles the completion status of a habit for the day
  Future<void> toggleCompletedToday(int habitId) async {
    final date = _dayKey(DateTime.now());
    final existing = await habitRecordDao.findRecord(habitId, date);
    
    if (existing == null) {
      final habit = await habitDao.findHabitById(habitId);
      if (habit == null) return;

      await habitRecordDao.insertRecord(
        HabitRecord(
          habitId: habitId,
          date: date,
          scoreDelta: habit.importanceLevel,
        ),
      );
    } else {
      await habitRecordDao.deleteRecord(habitId, date);
    }
  }

  /// Gets all habit records for a specific habit
  Future<List<HabitRecord>> getRecordsForHabit(int habitId) => habitRecordDao.findRecordsForHabit(habitId);

  /// Gets the total score across all habit records for a specific date
  Future<int?> getScoreForDate(DateTime date) => habitRecordDao.getScoreForDate(_dayKey(date));

  /// Gets the total score across all habit records for the last N days
  Future<List<int?>> getScoreForLastNDays(int n) {
    final now = DateTime.now();
    final past = List.generate(
      n, (i) => _dayKey(now.subtract(Duration(days: n - i - 1)))
    );
    return Future.wait(past.map((d) => habitRecordDao.getScoreForDate(d)));
  }
}