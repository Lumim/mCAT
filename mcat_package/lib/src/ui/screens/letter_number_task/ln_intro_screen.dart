import 'package:flutter/material.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../widgets/header_bar.dart';

class LnIntroScreen extends StatelessWidget {
  final LnController controller;
  const LnIntroScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Letter–Number Task', activeStep: 1),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'You will see numbers and letters. Review, then count backwards when asked.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/ln_instruction',
                  arguments: controller,
                );
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
