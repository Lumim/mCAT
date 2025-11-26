import 'package:flutter/material.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../widgets/header_bar.dart';
import 'package:mcat_package/src/services/tts_service.dart';

class LnPlayScreen extends StatefulWidget {
  final LnController controller;
  const LnPlayScreen({super.key, required this.controller});

  @override
  State<LnPlayScreen> createState() => _LnPlayScreenState();
}

class _LnPlayScreenState extends State<LnPlayScreen> {
  late TtsService _tts;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _tts = TtsService();
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacementNamed(
      context,
      '/ln_listen',
      arguments: widget.controller,
    );
  }

  Future<void> _playSequence() async {
    setState(() {
      _speaking = true;
    });

    final round = widget.controller.current;
    final roundNo = widget.controller.roundIndex + 1;

    // Set completion handler
    _tts.setCompletionHandler(() {
      print("TTS finished speaking");
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _navigateToNextScreen();
        }
      });
    });

    try {
      if (roundNo == 1) {
        await _tts.speak(
            'Get ready for round $roundNo. You will hear a sequence of numbers and letters. After listening, as soon as you hear the number, you are asked to recall them in reverse order. After that you will be asked to enter those letter . . ${round.letterSeq.join(' ')} . . ${round.numberSeq.join(' ')}');
      } else {
        await _tts.speak(
            'The number and letters..  ${round.letterSeq.join(' ')} . . ${round.numberSeq.join(' ')}');
      }
    } catch (e) {
      print("TTS Error: $e");
      setState(() {
        _speaking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.controller.current;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(title: 'Letter Number Task', activeStep: 3),
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Numbers: ${round.numberSeq.join(' ')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Letters: ${round.letterSeq.join(' ')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            _speaking
                ? const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Playing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _playSequence,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFFFFF),
                      backgroundColor: const Color(0xFF006BA6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Play Letters & Numbers',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
