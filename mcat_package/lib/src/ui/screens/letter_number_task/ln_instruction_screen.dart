import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';

class LnInstructionScreen extends StatelessWidget {
  final VoidCallback onNext;
  const LnInstructionScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Letter Number Task', activeStep: 2),
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
                  'You will hear some letters followed by a number.\n'
                  'Immediately start counting backwards out loud from that number,\n'
                  'until you are asked to type the letters you heard.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(label: 'Next', onPressed: onNext),
          ],
        ),
      ),
    );
  }
}
