import 'package:floor/floor.dart';

/// A habit the user wants to track
@Entity(tableName: 'Habit')
class Habit {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// The name of the habit
  final String habitName;

  // Optional description of the habit
  final String? habitDescription;

  // Importance level: 1-5, where 1 is least important and 5 is most important
  final int importanceLevel;

  /// The date and time when the habit was created
  final int createdAtMilliseconds;

  /// Whether the habit is archived
  final bool isArchived;

  Habit({
    required this.id,
    required this.habitName,
    this.habitDescription,
    required this.importanceLevel,
    required this.createdAtMilliseconds,
    required this.isArchived,
  });

  /// Creates a new Habit
  Habit.newHabit({
    required this.habitName,
    this.habitDescription,
    required this.importanceLevel,
    int? millisecondsSinceEpoch,
  })  : id = null,
        createdAtMilliseconds = millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        isArchived = false;

  /// Checks if the habit has a description
  bool hasDescription() {
    return habitDescription != null && habitDescription!.isNotEmpty;
  }
}