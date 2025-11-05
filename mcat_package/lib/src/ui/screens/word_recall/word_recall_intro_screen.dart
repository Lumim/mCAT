import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class WordRecallIntroScreen extends StatelessWidget {
  final VoidCallback onNext;
  const WordRecallIntroScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Word Recall Task', activeStep: 4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text('Instructions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _infoCard(
              'This task goes back to the words that you heard in the first task.',
            ),
            const SizedBox(height: 12),
            _infoCard(
              'Do you remember the list we went over three times earlier? '
              'In a short while you will have to repeat as many words as you remember from that list in any order.',
            ),
            const Spacer(),
            PrimaryButton(label: 'Next', onPressed: onNext),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String text) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
        ),
      );
}
