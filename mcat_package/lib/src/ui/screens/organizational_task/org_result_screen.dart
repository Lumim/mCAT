import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../../domain/models/organizational_models.dart';

class OrgResultScreen extends StatelessWidget {
  final OrgController controller;
  final VoidCallback?
      onNextTask; // e.g., to jump to the next (Organization) task flow in your app shell

  const OrgResultScreen({super.key, required this.controller, this.onNextTask});

  @override
  Widget build(BuildContext context) {
    final total = controller.totalRounds;
    final score = controller.correctCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Results', activeStep: 4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Your score',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('$score / $total',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onNextTask ??
                  () => Navigator.pushReplacementNamed(
                        context,
                        '/word-recall-intro', // hyphen route
                      ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
