import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/database/dao/habit_dao.dart';
import 'package:habit_quest/database/entities/habit_record.dart';
import 'package:habit_quest/database/dao/habit_record_dao.dart';

part 'app_database.g.dart'; // the generated code will be there

@Database(version: 2, entities: [Habit, HabitRecord])
abstract class AppDatabase extends FloorDatabase {
  HabitDao get habitDao;
  HabitRecordDao get habitRecordDao;

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

  static final List<Migration> migrations = [
    migration1to2,
  ];
}