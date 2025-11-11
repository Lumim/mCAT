import 'package:flutter/material.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../widgets/header_bar.dart';

class LnPlayScreen extends StatelessWidget {
  final LnController controller;
  const LnPlayScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final round = controller.current;
    final roundNo = controller.roundIndex + 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(title: 'LN – Round $roundNo', activeStep: 3),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Review this sequence before continuing.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Numbers: ${round.numberSeq.join(' ')}'),
                    Text('Letters: ${round.letterSeq.join(' ')}'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/ln-listen', // hyphen route
                  arguments: controller,
                );
              },
              child: const Text('I’m Ready'),
            ),
          ],
        ),
      ),
    );
  }
}
