import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/database/dao/habit_dao.dart';
import 'package:habit_quest/database/entities/habit_record.dart';
import 'package:habit_quest/database/dao/habit_record_dao.dart';

part 'app_database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Habit, HabitRecord])
abstract class AppDatabase extends FloorDatabase {
  HabitDao get habitDao;
  HabitRecordDao get habitRecordDao;
}