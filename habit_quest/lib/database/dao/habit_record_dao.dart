import 'package:floor/floor.dart';
import 'package:habit_quest/database/entities/habit_record.dart';

@dao
abstract class HabitRecordDao {
  /// Get all records for a habit in ascending order by date
  @Query('SELECT * FROM HabitRecord WHERE habitId = :habitId ORDER BY date ASC')
  Future<List<HabitRecord>> findRecordsForHabit(int habitId);

  /// Get the Habit Record for a specific habit and date (if it exists)
  @Query('SELECT * FROM HabitRecord WHERE habitId = :habitId AND date = :date')
  Future<HabitRecord?> findRecord(int habitId, int date);

  @Query('SELECT * FROM HabitRecord WHERE date = :date')
  Future<List<HabitRecord>> findRecordsForDate(int date);

  /// Insert or replace a record
  @Insert(onConflict: OnConflictStrategy.abort)
  Future<int?> insertRecord(HabitRecord record);

  /// Count the number of records for a specific habit and date
  @Query('SELECT COUNT(*) FROM HabitRecord WHERE habitId = :habitId AND date = :date')
  Future<int?> countRecordsForHabit(int habitId, int date);

  /// Delete all records for a habit
  @Query('DELETE FROM HabitRecord WHERE habitId = :habitId AND date = :date')
  Future<int?> deleteRecord(int habitId, int date);

  /// Delete all records for a habit
  @Query('DELETE FROM HabitRecord WHERE habitId = :habitId')
  Future<int?> deleteRecordsForHabit(int habitId);

  /// Get the total score across all habit records for a specific date
  @Query('SELECT COALESCE(SUM(scoreDelta), 0) FROM HabitRecord WHERE date = :date')
  Future<int?> getScoreForDate(int date);
}