import 'package:flutter/material.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../widgets/header_bar.dart';

class LnResultScreen extends StatelessWidget {
  final LnController controller;
  const LnResultScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Results', activeStep: 3),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Great job! Your responses were recorded.'
              'Your score saved successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFFFFFFF),
                backgroundColor: const Color(0xFF006BA6),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
