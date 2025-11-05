import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mcat_package/src/services/stt_service.dart';
import 'package:mcat_package/src/services/data_service.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class WordRecallListeningScreen extends StatefulWidget {
  final List<String> expectedWords;
  final VoidCallback onFinished;

  const WordRecallListeningScreen({
    super.key,
    required this.expectedWords,
    required this.onFinished,
  });

  @override
  State<WordRecallListeningScreen> createState() =>
      _WordRecallListeningScreenState();
}

class _WordRecallListeningScreenState extends State<WordRecallListeningScreen> {
  final SttService _stt = SttService();
  String recognized = '';
  bool listening = false;
  Timer? _timer;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _beginRecall();
  }

  Future<void> _beginRecall() async {
    setState(() => listening = true);

    await _stt.startListening(
      onPartialResult: (text) {
        setState(() => recognized = text);
      },
      onFinalResult: (finalText) {
        // Triggered when user pauses for a few seconds or stops manually
        setState(() {
          recognized = finalText;
          listening = false;
        });
        debugPrint('🎤 Final recognized text: $finalText');
      },
    );
  }

  /// Stop the listening session
  Future<void> _stop() async {
    await _stt.stopListening();
    setState(() => listening = false);
  }

  Future<void> _stopListening() async {
    await _stt.stopListening();
    setState(() => listening = false);
    _calculateScore();

    await DataService().saveTask('word_recall', {
      'correct': score,
      'total': widget.expectedWords.length,
      'recognized': recognized,
      'accuracy': score / widget.expectedWords.length,
      'timestamp': DateTime.now().toIso8601String(),
    });

    widget.onFinished();
  }

  void _calculateScore() {
    final spokenWords = recognized
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    for (final word in widget.expectedWords) {
      if (spokenWords.contains(word.toLowerCase())) score++;
    }
  }

  @override
  void dispose() {
    _stt.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Word Recall', activeStep: 4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Say all the words you remember.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            _micIndicator(),
            const SizedBox(height: 16),
            Text(
              listening
                  ? 'Listening...'
                  : 'You said: ${recognized.isEmpty ? "(no words)" : recognized}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            if (!listening)
              PrimaryButton(label: 'Continue', onPressed: widget.onFinished),
          ],
        ),
      ),
    );
  }

  Widget _micIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: listening ? 90 : 70,
      height: listening ? 90 : 70,
      decoration: BoxDecoration(
        color: listening ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
        boxShadow: [
          if (listening)
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 12,
            ),
        ],
      ),
      child: const Icon(Icons.mic, color: Colors.white, size: 36),
    );
  }
}
