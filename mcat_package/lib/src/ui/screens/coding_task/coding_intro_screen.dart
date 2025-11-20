import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';
import '../../../services/tts_service.dart';

class CodingIntroScreen extends StatefulWidget {
  final VoidCallback onNext;
  const CodingIntroScreen({super.key, required this.onNext});

  @override
  State<CodingIntroScreen> createState() => _CodingIntroScreenState();
}

class _CodingIntroScreenState extends State<CodingIntroScreen> {
  final _tts = TtsService();

  Future<void> _speak() async {
    await _tts.speak(
      'In this task, you will match symbols made of stars and circles with letters. '
      'You will first practice before starting the real test.',
    );
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Coding Task', activeStep: 5),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // const StepIndicator(activeIndex: 5),
            const SizedBox(height: 20),
            const Text('Instructions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _card(
              'In this task, you are going to match symbols with letters. '
              'Before doing the test, you will have the opportunity to practice this “letter and code” task.',
            ),
            const SizedBox(height: 12),
            _card(
              'You will practice 1 set of 6 codes and will be told whether your answer was right or wrong.',
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _speak,
              icon: const Icon(Icons.play_circle_fill, color: Colors.blue),
              label: const Text('Hear instructions',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Start Assessment', onPressed: widget.onNext),
            const Spacer(flex: 8),
          ],
        ),
      ),
    );
  }

  Widget _card(String text) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
        ),
      );
}
