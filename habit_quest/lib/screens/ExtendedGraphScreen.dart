import 'package:flutter/material.dart';

// ==================== EXTENDED GRAPH SCREEN ====================

class ExtendedGraphScreen extends StatelessWidget {
  const ExtendedGraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTE: The document states this screen should lock to landscape mode[cite: 27].
    // Orientation locking requires device-specific configuration outside the scope of a simple UI mockup.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extended Graph'),
        // There will be a back button... which will take Users back to the "Homepage"[cite: 29].
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        // The "Extended Graph" screen will display a line graph showing User scores over the last 30 days[cite: 28].
        child: Container(
          height: 300,
          width: double.infinity,
          color: Colors.indigo.shade200,
          child: const Center(child: Text('Placeholder: 30-Day Score Line Graph (Landscape View)')),
        ),
      ),
    );
  }
}
