import 'package:flutter/material.dart';

class EditButton extends StatelessWidget {
  final Widget editInterface;

  const EditButton({super.key, required this.editInterface});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (ctx) => editInterface,
        );
      },
    );
  }
}