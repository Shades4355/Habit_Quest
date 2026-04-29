// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  HabitDao? _habitDaoInstance;

  HabitRecordDao? _habitRecordDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 3,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Habit` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `habitName` TEXT NOT NULL, `habitDescription` TEXT, `importanceLevel` INTEGER NOT NULL, `createdAtMilliseconds` INTEGER NOT NULL, `isArchived` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `HabitRecord` (`recordId` INTEGER PRIMARY KEY AUTOINCREMENT, `habitId` INTEGER NOT NULL, `habitName` TEXT NOT NULL, `importanceLevel` INTEGER NOT NULL, `date` INTEGER NOT NULL, `scoreDelta` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  HabitDao get habitDao {
    return _habitDaoInstance ??= _$HabitDao(database, changeListener);
  }

  @override
  HabitRecordDao get habitRecordDao {
    return _habitRecordDaoInstance ??=
        _$HabitRecordDao(database, changeListener);
  }
}

class _$HabitDao extends HabitDao {
  _$HabitDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _habitInsertionAdapter = InsertionAdapter(
            database,
            'Habit',
            (Habit item) => <String, Object?>{
                  'id': item.id,
                  'habitName': item.habitName,
                  'habitDescription': item.habitDescription,
                  'importanceLevel': item.importanceLevel,
                  'createdAtMilliseconds': item.createdAtMilliseconds,
                  'isArchived': item.isArchived ? 1 : 0
                }),
        _habitUpdateAdapter = UpdateAdapter(
            database,
            'Habit',
            ['id'],
            (Habit item) => <String, Object?>{
                  'id': item.id,
                  'habitName': item.habitName,
                  'habitDescription': item.habitDescription,
                  'importanceLevel': item.importanceLevel,
                  'createdAtMilliseconds': item.createdAtMilliseconds,
                  'isArchived': item.isArchived ? 1 : 0
                }),
        _habitDeletionAdapter = DeletionAdapter(
            database,
            'Habit',
            ['id'],
            (Habit item) => <String, Object?>{
                  'id': item.id,
                  'habitName': item.habitName,
                  'habitDescription': item.habitDescription,
                  'importanceLevel': item.importanceLevel,
                  'createdAtMilliseconds': item.createdAtMilliseconds,
                  'isArchived': item.isArchived ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Habit> _habitInsertionAdapter;

  final UpdateAdapter<Habit> _habitUpdateAdapter;

  final DeletionAdapter<Habit> _habitDeletionAdapter;

  @override
  Future<Habit?> findHabitById(int id) async {
    return _queryAdapter.query('SELECT * FROM Habit WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Habit(
            id: row['id'] as int?,
            habitName: row['habitName'] as String,
            habitDescription: row['habitDescription'] as String?,
            importanceLevel: row['importanceLevel'] as int,
            createdAtMilliseconds: row['createdAtMilliseconds'] as int,
            isArchived: (row['isArchived'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<List<Habit>> findAllHabits() async {
    return _queryAdapter.queryList('SELECT * FROM Habit',
        mapper: (Map<String, Object?> row) => Habit(
            id: row['id'] as int?,
            habitName: row['habitName'] as String,
            habitDescription: row['habitDescription'] as String?,
            importanceLevel: row['importanceLevel'] as int,
            createdAtMilliseconds: row['createdAtMilliseconds'] as int,
            isArchived: (row['isArchived'] as int) != 0));
  }

  @override
  Future<List<Habit>> findActiveHabits() async {
    return _queryAdapter.queryList('SELECT * FROM Habit WHERE isArchived = 0',
        mapper: (Map<String, Object?> row) => Habit(
            id: row['id'] as int?,
            habitName: row['habitName'] as String,
            habitDescription: row['habitDescription'] as String?,
            importanceLevel: row['importanceLevel'] as int,
            createdAtMilliseconds: row['createdAtMilliseconds'] as int,
            isArchived: (row['isArchived'] as int) != 0));
  }

  @override
  Future<List<Habit>> findArchivedHabits() async {
    return _queryAdapter.queryList('SELECT * FROM Habit WHERE isArchived = 1',
        mapper: (Map<String, Object?> row) => Habit(
            id: row['id'] as int?,
            habitName: row['habitName'] as String,
            habitDescription: row['habitDescription'] as String?,
            importanceLevel: row['importanceLevel'] as int,
            createdAtMilliseconds: row['createdAtMilliseconds'] as int,
            isArchived: (row['isArchived'] as int) != 0));
  }

  @override
  Future<int?> archiveHabit(int id) async {
    return _queryAdapter.query('UPDATE Habit SET isArchived = 1 WHERE id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [id]);
  }

  @override
  Future<int?> unarchiveHabit(int id) async {
    return _queryAdapter.query('UPDATE Habit SET isArchived = 0 WHERE id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [id]);
  }

  @override
  Future<int?> deleteAllHabits() async {
    return _queryAdapter.query('DELETE FROM Habit',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertHabit(Habit habit) {
    return _habitInsertionAdapter.insertAndReturnId(
        habit, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateHabit(Habit habit) {
    return _habitUpdateAdapter.updateAndReturnChangedRows(
        habit, OnConflictStrategy.replace);
  }

  @override
  Future<int> deleteHabit(Habit habit) {
    return _habitDeletionAdapter.deleteAndReturnChangedRows(habit);
  }
}

class _$HabitRecordDao extends HabitRecordDao {
  _$HabitRecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _habitRecordInsertionAdapter = InsertionAdapter(
            database,
            'HabitRecord',
            (HabitRecord item) => <String, Object?>{
                  'recordId': item.recordId,
                  'habitId': item.habitId,
                  'habitName': item.habitName,
                  'importanceLevel': item.importanceLevel,
                  'date': item.date,
                  'scoreDelta': item.scoreDelta
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<HabitRecord> _habitRecordInsertionAdapter;

  @override
  Future<List<HabitRecord>> findRecordsForHabit(int habitId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM HabitRecord WHERE habitId = ?1 ORDER BY date ASC',
        mapper: (Map<String, Object?> row) => HabitRecord(
            recordId: row['recordId'] as int?,
            habitId: row['habitId'] as int,
            habitName: row['habitName'] as String,
            importanceLevel: row['importanceLevel'] as int,
            date: row['date'] as int,
            scoreDelta: row['scoreDelta'] as int),
        arguments: [habitId]);
  }

  @override
  Future<HabitRecord?> findRecord(
    int habitId,
    int date,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM HabitRecord WHERE habitId = ?1 AND date = ?2',
        mapper: (Map<String, Object?> row) => HabitRecord(
            recordId: row['recordId'] as int?,
            habitId: row['habitId'] as int,
            habitName: row['habitName'] as String,
            importanceLevel: row['importanceLevel'] as int,
            date: row['date'] as int,
            scoreDelta: row['scoreDelta'] as int),
        arguments: [habitId, date]);
  }

  @override
  Future<List<HabitRecord>> findRecordsForDate(int date) async {
    return _queryAdapter.queryList('SELECT * FROM HabitRecord WHERE date = ?1',
        mapper: (Map<String, Object?> row) => HabitRecord(
            recordId: row['recordId'] as int?,
            habitId: row['habitId'] as int,
            habitName: row['habitName'] as String,
            importanceLevel: row['importanceLevel'] as int,
            date: row['date'] as int,
            scoreDelta: row['scoreDelta'] as int),
        arguments: [date]);
  }

  @override
  Future<List<HabitRecord>> findAllRecords() async {
    return _queryAdapter.queryList('SELECT * FROM HabitRecord',
        mapper: (Map<String, Object?> row) => HabitRecord(
            recordId: row['recordId'] as int?,
            habitId: row['habitId'] as int,
            habitName: row['habitName'] as String,
            importanceLevel: row['importanceLevel'] as int,
            date: row['date'] as int,
            scoreDelta: row['scoreDelta'] as int));
  }

  @override
  Future<int?> countRecordsForHabit(
    int habitId,
    int date,
  ) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM HabitRecord WHERE habitId = ?1 AND date = ?2',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [habitId, date]);
  }

  @override
  Future<int?> deleteRecord(
    int habitId,
    int date,
  ) async {
    return _queryAdapter.query(
        'DELETE FROM HabitRecord WHERE habitId = ?1 AND date = ?2',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [habitId, date]);
  }

  @override
  Future<int?> deleteRecordById(int id) async {
    return _queryAdapter.query('DELETE FROM HabitRecord WHERE recordId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [id]);
  }

  @override
  Future<int?> deleteRecordsForHabit(int habitId) async {
    return _queryAdapter.query('DELETE FROM HabitRecord WHERE habitId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [habitId]);
  }

  @override
  Future<int?> deleteAllRecords() async {
    return _queryAdapter.query('DELETE FROM HabitRecord',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getScoreForDate(int date) async {
    return _queryAdapter.query(
        'SELECT COALESCE(SUM(scoreDelta), 0) FROM HabitRecord WHERE date = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [date]);
  }

  @override
  Future<int> insertRecord(HabitRecord record) {
    return _habitRecordInsertionAdapter.insertAndReturnId(
        record, OnConflictStrategy.abort);
  }
}
