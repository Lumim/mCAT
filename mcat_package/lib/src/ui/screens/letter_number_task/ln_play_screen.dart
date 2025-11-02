import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../../services/letter_number_service.dart';
import '../../../services/tts_service.dart';

class LnPlayScreen extends StatefulWidget {
  final LnController controller;
  final VoidCallback onNext;
  const LnPlayScreen({
    super.key,
    required this.controller,
    required this.onNext,
  });

  @override
  State<LnPlayScreen> createState() => _LnPlayScreenState();
}

class _LnPlayScreenState extends State<LnPlayScreen> {
  final _tts = TtsService();
  bool _played = false;

  @override
  void initState() {
    super.initState();
    // Generate the stimulus for this round
    widget.controller.generate();
  }

  Future<void> _play() async {
    final item = widget.controller.current!;
    await LetterNumberService.playSequence(_tts, item);
    setState(() => _played = true);
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.controller.roundIndex + 1;
    final item = widget.controller.current!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(
        title: 'Letter Number Task (Round $round)',
        activeStep: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Tap Play to hear the letters followed by a number.\n'
              'Start counting backwards as soon as you hear the number.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'This round: ${item.letters.length} letter(s) + '
                  '${item.number.toString().length} digit(s)',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _play,
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Hear now'),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Next',
              onPressed: _played ? widget.onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}
