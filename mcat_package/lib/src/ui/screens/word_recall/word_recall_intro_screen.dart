import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/infocard.dart';
import '../../widgets/primary_button.dart';

class WordRecallIntroScreen extends StatelessWidget {
  final VoidCallback onStart;

  const WordRecallIntroScreen({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(
        title: 'Word Recall',
        activeStep: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Spacer(),
            /*  const Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Colors.black54,
            ), */
            const SizedBox(height: 24),
            /*  const Text(
              'Word Recall Task',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ), */
            const SizedBox(height: 12),
            const InfoCard(
              text: 'Earlier, in the Word Task, you heard a list of words. '
                  'Now you will be asked to recall as many of those words as you can.',
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Continue',
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}
