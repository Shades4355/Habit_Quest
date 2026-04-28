import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/database/dao/habit_dao.dart';
import 'package:habit_quest/database/entities/habit_record.dart';
import 'package:habit_quest/database/dao/habit_record_dao.dart';

part 'app_database.g.dart'; // the generated code will be there

@Database(version: 3, entities: [Habit, HabitRecord])
abstract class AppDatabase extends FloorDatabase {
  HabitDao get habitDao;
  HabitRecordDao get habitRecordDao;

  // Migration to add scoreDelta to HabitRecord
  static final migration1to2 = Migration(1, 2, (database) async {
    await database.execute('DROP TABLE IF EXISTS HabitRecord');
    await database.execute('''
      CREATE TABLE IF NOT EXISTS HabitRecord (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        date INTEGER NOT NULL,
        scoreDelta INTEGER NOT NULL,
        FOREIGN KEY (habitId) REFERENCES Habit (id) ON DELETE CASCADE
      )
    ''');
  });

  // Migration to add habitName and importanceLevel to HabitRecord
  static final migration2to3 = Migration(2, 3, (database) async {
    // 1. Create new table
    await database.execute('''
      CREATE TABLE HabitRecord_new (
        recordId INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        habitName TEXT NOT NULL DEFAULT '',
        importanceLevel INTEGER NOT NULL DEFAULT 0,
        date INTEGER NOT NULL,
        scoreDelta INTEGER NOT NULL
      )
    ''');

    // Copy data
    await database.execute('''
      INSERT INTO HabitRecord_new (recordId, habitId, habitName, importanceLevel, date, scoreDelta)
      SELECT
        r.id,
        r.habitId,
        COALESCE(h.habitName, '') as habitName,
        COALESCE(h.importanceLevel, 0) as importanceLevel,
        r.date,
        r.scoreDelta
      FROM HabitRecord r
      LEFT JOIN Habit h ON r.habitId = h.id
    ''');

    // Drop old table
    await database.execute('DROP TABLE HabitRecord');

    // Rename table
    await database.execute('ALTER TABLE HabitRecord_new RENAME TO HabitRecord');
  });

  // List of all migrations
  static final List<Migration> migrations = [
    migration1to2,
    migration2to3,
  ];
}