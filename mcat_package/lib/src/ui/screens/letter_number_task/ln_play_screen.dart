import 'package:flutter/material.dart';
import 'package:stts/stts.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../widgets/header_bar.dart';
import 'package:mcat_package/src/services/tts_service.dart';

class LnPlayScreen extends StatelessWidget {
  final LnController controller;
  const LnPlayScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final TtsService _tts = TtsService();
    final round = controller.current;
    final roundNo = controller.roundIndex + 1;
    void dispose() {
      _tts.dispose();
      Navigator.pushReplacementNamed(
        context,
        '/ln_listen',
        arguments: controller,
      );
    }

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
              onPressed: () async {
                // Set completion handler first
                _tts.setCompletionHandler(() {
                  print("TTS finished speaking");
                  Future.delayed(Duration(seconds: 1), dispose);
                  // Add your completion logic here
                  // For example: navigate to next screen, show buttons, etc.
                });
                if (roundNo == 1) {
                  await _tts.speak(
                      'Get ready for round $roundNo. You will hear a sequence of numbers and letters. After listening, as soon as you hear the number, you are asked to recall them in reverse order. After that you will be asked to enter those letter ${round.letterSeq.join(' ')} . . ${round.numberSeq.join(' ')}');
                } else {
                  await _tts.speak(
                      'This is Round $roundNo.  ${round.letterSeq.join(' ')} . . ${round.numberSeq.join(' ')}');
                }
                // Then speak
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFFFFFFF),
                backgroundColor: const Color(0xFF006BA6),
              ),
              child: const Text('Play Letters & Numbers'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
