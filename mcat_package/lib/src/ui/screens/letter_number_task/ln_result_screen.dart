import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';
import '../../../domain/models/letter_number_models.dart';

class LnResultScreen extends StatelessWidget {
  final LnController controller;
  final VoidCallback onNext;
  const LnResultScreen({
    super.key,
    required this.controller,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final score = controller.correct;
    final total = controller.total;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Letter Number Task', activeStep: 5),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'You have scored $score out of $total in the Letter Number Task!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
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
