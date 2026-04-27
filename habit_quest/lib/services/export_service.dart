import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:habit_quest/repositories/habit_repository.dart';
import 'package:habit_quest/database/entities/habit.dart';
import 'package:habit_quest/database/entities/habit_record.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:habit_quest/services/toast_service.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  HabitRepository get _repo => HabitRepository.instance;

  // Formats DateTime as MM-DD-YYYY for CSV export
  static String _formatDate(DateTime date) =>
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}-'
      '${date.year}';

  // Converts the dayKey back to DateTime (for habit records)
  DateTime _fromDayKey(int key) {
    final month = key ~/ 1000000;
    final day = (key % 1000000) ~/ 10000;
    final year = key % 10000;
    return DateTime(year, month, day);
  }

  // Parses MM-DD-YYYY back to DateTime
  static DateTime _parseDate(String date) {
    final parts = date.split('-');
    return DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
  }

  // Get the temporary directory path for storing the CSV file before saving
  Future<String> get _tempPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  // Get a File instance for the temporary CSV file
  Future<File> get _tempFile async {
    final path = await _tempPath;
    return File('$path/habit_quest_export.csv');
  }

  // Writes the CSV string to a temporary file and returns the File instance
  Future<File> _writeCsv(String csvString) async {
    final file = await _tempFile;
    return file.writeAsString(csvString);
  }

  // Reads the content of a CSV file and returns it as a string
  Future<String> _readCsv(String filePath) async {
    try {
      return await File(filePath).readAsString();
    } catch (e) {
      throw Exception('Failed to read CSV file: $e');
    }
  }

  // Define the headers for habits and records
  final _habitHeader = [['Habits'],['Id', 'Name', 'Importance', 'Created At', 'Is Archived']];
  final _recordHeader = [['Habit Records'],['Record Id', 'Habit Id', 'Habit Name', 'Date', 'Importance', 'Score Delta']];

  /// Exports active and archived habits along with their records to a CSV file and prompts the user to save it.
  Future<void> exportData(BuildContext context) async {
    // Fetch all habits and records from the repository
    final habits = await _repo.getAllHabits();
    final records = await _repo.getAllRecords();

    // Create rows for habits (with headers)
    final habitRows = [
      ..._habitHeader,
      ...habits.map((habit) => [
        habit.id,
        habit.habitName,
        habit.importanceLevel,
        _formatDate(DateTime.fromMillisecondsSinceEpoch(habit.createdAtMilliseconds)),
        habit.isArchived,
      ]),
    ];

    // Create rows for records (with headers)
    final recordRows = [
      ..._recordHeader,
      ...records.map((record) => [
        record.recordId,
        record.habitId,
        record.habitName,
        _formatDate(_fromDayKey(record.date)),
        record.importanceLevel,
        record.scoreDelta,
      ]),
    ];

    // Combine habit and record rows with a blank line in between
    final allRows = [...habitRows, [], ...recordRows];

    // Convert the combined rows to CSV format
    final csvString = csv.encode(allRows);
    
    try {
      // Write the CSV string to a temporary file and get the File instance
      final file = await _writeCsv(csvString);
      await FileSaver.instance.saveAs(
        name: 'habit_quest_export_${_formatDate(DateTime.now())}',
        bytes: await file.readAsBytes(),
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
      if (!context.mounted) return;
      ToastService.showSuccess('Data exported successfully!');
    } catch (e) {
      if (!context.mounted) return;
      ToastService.showError('Failed to export data: $e');
    }
  }

  /// Imports data from a CSV file selected by the user. The CSV should have two sections: "Habits" and "Habit Records".
  Future<void> importData(BuildContext context) async {
    try {
      // Use FilePicker to let the user select a CSV file
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      // Check if a file was selected and if it has a valid path
      if (result == null || result.files.single.path == null) return;

      final content = await _readCsv(result.files.single.path!);
      if (content.isEmpty) {
        if (!context.mounted) return;
        ToastService.showError('Selected file is empty');
        return;
      }

      // Decode the CSV content into rows
      final rows = csv.decode(content);

      // Replace the separatorIndex logic with this:
      final separatorIndex = rows.indexWhere((row) =>
        row.length == 1 && row[0].toString().trim() == 'Habit Records'
      );
      if (separatorIndex == -1) throw Exception('Invalid CSV format: missing Habit Records section');

      final habitRows = rows.sublist(0, separatorIndex);
      final recordRows = rows.sublist(separatorIndex); // include the header row

      // Skip ['Habits'] and column headers
      final habitData = habitRows.sublist(2);
      // Skip ['Habit Records'] and column headers  
      final recordData = recordRows.sublist(2);

      // Clear existing data before importing
      await _repo.clearAllHabits();
      await _repo.clearAllRecords();

      // Habits
      for (final row in habitData) {
        // Get habit fields from CSV
        final id = int.parse(row[0].toString());
        final habitName = row[1].toString();
        final importance = int.parse(row[2].toString());
        final createdAt = _parseDate(row[3].toString());
        final isArchived = row[4].toString().trim() == 'true';

        // Insert the habit into the database
        await _repo.habitDao.insertHabit(Habit(
          id: id,
          habitName: habitName,
          importanceLevel: importance,
          createdAtMilliseconds: createdAt.millisecondsSinceEpoch,
          isArchived: isArchived,
        ));
      }

      // Records
      for (final row in recordData) {
        // Get record fields from CSV
        final habitId = int.parse(row[1].toString());
        final habitName = row[2].toString();
        final date = _parseDate(row[3].toString());
        final importanceLevel = int.parse(row[4].toString());
        final scoreDelta = int.parse(row[5].toString());

        // Insert the record into the database
        await _repo.habitRecordDao.insertRecord(HabitRecord(
          habitId: habitId,
          habitName: habitName,
          date: _repo.dayKey(date),
          importanceLevel: importanceLevel,
          scoreDelta: scoreDelta,
        ));
      }

      if (!context.mounted) return;
      ToastService.showSuccess('Data imported successfully!');
    } catch (e) {
      if (!context.mounted) return;
      ToastService.showError('Failed to import data: $e');
    }
  }
}