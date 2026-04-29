// Delete Button
import 'package:flutter/material.dart';

enum DeleteContext {
  habit,
  habitRecord,
  theme,
  notification,
}

class DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;
  final DeleteContext deleteContext;

  const DeleteButton({super.key, required this.onDelete, required this.deleteContext});

    String _getConfirmationMessage() {
      switch (deleteContext) {
        case DeleteContext.habit:
          return 'Are you sure you want to delete this habit? This action cannot be undone.';
        case DeleteContext.habitRecord:
          return 'Are you sure you want to delete this habit record? This action cannot be undone.';
        case DeleteContext.theme:
          return 'Are you sure you want to delete this theme? This action cannot be undone.';
        case DeleteContext.notification:
          return 'Are you sure you want to delete this notification? This action cannot be undone.';
        default:
          return 'Are you sure you want to delete this item? This action cannot be undone.';
      }
    }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(_getConfirmationMessage()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
              child: const Text('Confirm', style: TextStyle(color: Colors.red)),
            ),
          ],
        )
      )
    );
  }
}