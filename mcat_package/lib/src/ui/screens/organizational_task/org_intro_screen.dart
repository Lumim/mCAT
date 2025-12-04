import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../../domain/models/organizational_models.dart';
import '../../widgets/infocard.dart';

class OrgIntroScreen extends StatelessWidget {
  final OrgController controller;
  const OrgIntroScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Organizational Task', activeStep: 4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
           InfoCard(
            text:
                'In this task, you will hear numbers and letters in random order. '
                'Type your answer as: numbers in ascending order, then letters in alphabetical order.',
               fontSize: 16,
              ),

            
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, '/org_instruction',
                  arguments: controller),
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFFFFFFF),
                backgroundColor: const Color(0xFF006BA6),
              ),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
