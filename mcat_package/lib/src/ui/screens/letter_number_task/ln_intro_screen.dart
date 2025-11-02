import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';

class LnIntroScreen extends StatelessWidget {
  final VoidCallback onStart;
  const LnIntroScreen({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Letter Number Task', activeStep: 1),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'It does not matter in which order you type the letters.\n'
                  'Start counting backwards as soon as you hear the number.\n'
                  'Keep looking at the number while you count.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(label: 'Start Assessment', onPressed: onStart),
          ],
        ),
      ),
    );
  }
}
