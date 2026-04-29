import 'package:floor/floor.dart';

/// A record of a habit for a specific date
@Entity(tableName: 'HabitRecord')
class HabitRecord {
  /// The unique ID of the habit record
  @PrimaryKey(autoGenerate: true)
  final int? recordId;

  /// The ID of the habit this record is associated with
  /// Useful for grouping records by habit
  final int habitId;

  /// The name of the habit
  final String habitName;

  /// The importance level of the habit
  final int importanceLevel;

  /// The date of the habit record
  final int date;

  /// The change in score for this habit record
  final int scoreDelta;

  HabitRecord({
    this.recordId,
    required this.habitId,
    required this.habitName,
    required this.importanceLevel,
    required this.date,
    required this.scoreDelta,
  });
}