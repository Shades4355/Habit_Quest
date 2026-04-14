import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_saver/file_saver.dart';
import 'package:habit_quest/repositories/habit_repository.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  HabitRepository get _repo => HabitRepository.instance;

  Future<void> exportData(BuildContext context) async {
    final habits = await _repo.getActiveHabits();
    final archivedHabits = await _repo.getArchivedHabits();
    final allHabits = [...habits, ...archivedHabits];
    final records = await _repo.getRecordsForLastNDays(365);

    // Build habits CSV
    final habitRows = [
      ['=== Habits ==='],
      ['id', 'name', 'importance', 'created_at', 'is_archived'],
      ...allHabits.map((habit) => [
        habit.id,
        habit.habitName,
        habit.importanceLevel,
        DateTime.fromMillisecondsSinceEpoch(habit.createdAtMilliseconds).toIso8601String(),
        habit.isArchived,
      ]),
    ];

    // Build records CSV
    final recordRows = [
      ['=== Habit Records ==='],
      ['id', 'habit_id', 'date', 'score_delta'],
      ...records.map((record) => [
        record.recordId,
        record.habitId,
        record.date,
        record.scoreDelta,
      ]),
    ];

    final allRows = [...habitRows, [], ...recordRows];

    final csvString = csv.encode(allRows);

    // Write to temp files
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/habit_quest.csv');

    await file.writeAsString(csvString);

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('How would you like to export your data?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Save to device
              await FileSaver.instance.saveAs(
                name: 'habit_quest',
                bytes: Uint8List.fromList(csvString.codeUnits),
                fileExtension: 'csv',
                mimeType: MimeType.csv,
              );
            },
            child: const Text('Save to Device'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Share
              final dir = await getTemporaryDirectory();
              final file = File('${dir.path}/habit_quest_export.csv');
              await file.writeAsString(csvString);
              await Share.shareXFiles(
                [XFile(file.path)],
                subject: 'Habit Quest Export',
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}