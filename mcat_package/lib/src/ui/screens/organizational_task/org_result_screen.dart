import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../../domain/models/organizational_models.dart';

import 'package:mcat_package/src/services/data_service.dart';

class OrgResultScreen extends StatelessWidget {
  final OrgController controller;
  final VoidCallback? onNextTask;

  const OrgResultScreen({super.key, required this.controller, this.onNextTask});
  void saveState() async {
    await DataService().saveTask('organizational_task', {
      'correct': controller.correctCount,
      'total': controller.totalRounds,
      'accuracy': controller.correctCount / controller.totalRounds,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

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
            Row(
              children: [
                Expanded(
                  child: Card(
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
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                saveState();
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFFFFFFF),
                backgroundColor: const Color(0xFF006BA6),
              ),
              child: const Text('Done'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
