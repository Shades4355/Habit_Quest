import 'package:floor/floor.dart';
import 'package:habit_quest/database/entities/habit.dart';

@dao
abstract class HabitDao {
  /// Retrieves a habit by its ID
  @Query('SELECT * FROM Habit WHERE id = :id')
  Future<Habit?> findHabitById(int id);

  /// Retrieves all active (non-archived) habits from the database
  @Query('SELECT * FROM Habit WHERE isArchived = 0')
  Future<List<Habit>> findActiveHabits();

  /// Retrieves all archived habits from the database
  @Query('SELECT * FROM Habit WHERE isArchived = 1')
  Future<List<Habit>> findArchivedHabits();

  /// Inserts a new habit into the database
  @insert
  Future<int?> insertHabit(Habit habit);

  /// Updates an existing habit in the database
  @Update(onConflict: OnConflictStrategy.replace)
  Future<int?> updateHabit(Habit habit);

  /// Archives a habit by setting its isArchived field to true
  @Query('UPDATE Habit SET isArchived = 1 WHERE id = :id')
  Future<int?> archiveHabit(int id);

  /// Unarchives a habit by setting its isArchived field to false
  @Query('UPDATE Habit SET isArchived = 0 WHERE id = :id')
  Future<int?> unarchiveHabit(int id);

  /// Deletes a habit from the database
  @delete
  Future<int?> deleteHabit(Habit habit);
}