import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/header_bar.dart';
class FaceTaskResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onNext;
  const FaceTaskResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(title: 'Face Task - Result', activeStep: 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'You have scored $score out of $total in the Face Task!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: PrimaryButton(label: 'Next', onPressed: onNext),
            ),
          ],
        ),
      ),
    );
  }
}
