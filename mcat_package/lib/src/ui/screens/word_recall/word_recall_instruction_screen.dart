import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';
import '../../../services/tts_service.dart';

class WordRecallInstructionScreen extends StatefulWidget {
  final VoidCallback onNext;
  const WordRecallInstructionScreen({super.key, required this.onNext});

  @override
  State<WordRecallInstructionScreen> createState() =>
      _WordRecallInstructionScreenState();
}

class _WordRecallInstructionScreenState
    extends State<WordRecallInstructionScreen> {
  final _tts = TtsService();

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  Future<void> _playInstruction() async {
    await _tts.speak(
        'Please speak loudly and clearly. Try to recall as many words as you can from the earlier task.');
  }

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
              'It is important that you speak loud and clear and that you try to avoid saying anything other than the words. '
              'Make a short pause between words when repeating them.',
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _playInstruction,
              icon: const Icon(Icons.play_circle_fill, color: Colors.blue),
              label: const Text(
                'Hear instructions',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back')),
                PrimaryButton(
                    label: 'Start Assessment', onPressed: widget.onNext),
              ],
            ),
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
