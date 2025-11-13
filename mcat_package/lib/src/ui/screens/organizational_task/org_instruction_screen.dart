import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../../domain/models/organizational_models.dart';

class OrgInstructionScreen extends StatelessWidget {
  final OrgController controller;
  const OrgInstructionScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Instructions', activeStep: 2),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Tap Play to hear the numbers and letters. '
                  'Then type your answer: numbers first (ascending), then letters (A–Z).',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, '/org-play',
                  arguments: controller),
              child: const Text('Start Assessment'),
            ),
          ],
        ),
      ),
    );
  }
}
