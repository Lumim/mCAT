import 'package:flutter/material.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/infocard.dart';

class LnInstructionScreen extends StatelessWidget {
  final LnController controller;
  const LnInstructionScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Instructions', activeStep: 3),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const InfoCard(
              text:
                  "Now you will hear some letters and a number. This time you must count backwards out loud from the number until you are asked to type in the letters. For example, if you hear the letters ABC and then hear the number 10, you should start counting backwards out loud from 10 (10, 9, 8, 7...) until you are asked to type in the letters. Then type in the letters ABC.",
              fontSize: 16,
            ),
            const SizedBox(height: 16),
            const InfoCard(
              text:
                  'You must immediately start counting backwards out loud from 10, until you are asked to type in the letters. Then type in the letters ABC.',
              fontSize: 16,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/ln_play', // hyphen route
                  arguments: controller,
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFFFFFFF),
                backgroundColor: const Color(0xFF006BA6),
              ),
              child: const Text('Continue'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
