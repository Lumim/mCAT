import 'package:flutter/material.dart';
import 'package:mcat_package/src/ui/widgets/infocard.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class WordRecallInstructionScreen extends StatelessWidget {
  final VoidCallback onStartListening;

  const WordRecallInstructionScreen({
    super.key,
    required this.onStartListening,
  });

  Widget _buildBullet(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.black87),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const InfoCard(
                      text:
                          'This task goes back to the words that you heard in the first task. '),
                  const SizedBox(height: 20),
                  _buildBullet(
                    Icons.volume_up_outlined,
                    'Do you remember the list that we went over three times earlier? In a short while you will have to repeat as many words as you remember from that list in any order.',
                  ),
                  const SizedBox(height: 12),
                  _buildBullet(
                    Icons.visibility_off_outlined,
                    'It is important that you speak loud and clear and that you try to avoid saying anything other than the words. Also, it is important that you make a brief pause between the words when repeating them.',
                  ),
                  const SizedBox(height: 12),
                  _buildBullet(
                    Icons.lightbulb_outline,
                    'Just relax and remember as many words as you can.',
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Start Listening',
              onPressed: onStartListening,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
