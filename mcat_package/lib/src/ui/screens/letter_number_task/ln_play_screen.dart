import 'package:flutter/material.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../widgets/header_bar.dart';

class LnPlayScreen extends StatelessWidget {
  final LnController controller;
  final VoidCallback onNext;

  const LnPlayScreen({
    super.key,
    required this.controller,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final LnRound? round = controller.current;
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
            if (round != null)
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
                if (!controller.isLast) {
                  controller.nextRound();
                  Navigator.of(context).pushReplacementNamed(
                    ModalRoute.of(context)!.settings.name!,
                    arguments: controller,
                  );
                } else {
                  onNext();
                }
              },
              child: Text(controller.isLast ? 'See Result' : 'Next Round'),
            ),
          ],
        ),
      ),
    );
  }
}
