import 'package:flutter/material.dart';
import 'package:mcat_package/src/services/stt_service.dart';
import 'package:mcat_package/src/services/data_service.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class WordRecallInputScreen extends StatefulWidget {
  /// The original list of words from the Word Task.
  final List<String> targetWords;

  /// Called with (correct, total) after scoring.
  final void Function(int correct, int total) onFinished;

  const WordRecallInputScreen({
    super.key,
    required this.targetWords,
    required this.onFinished,
  });

  @override
  State<WordRecallInputScreen> createState() => _WordRecallInputScreenState();
}

class _WordRecallInputScreenState extends State<WordRecallInputScreen> {
  final SttService _stt = SttService();

  bool listening = false;
  bool saving = false;

  String recognized = '';
  List<String> recognizedWords = [];
  int score = 0;

  @override
  void initState() {
    super.initState();
    _stt.init();
  }

  @override
  void dispose() {
    _stt.dispose();
    super.dispose();
  }

  // Start a 20-second STT session, similar to WordTaskPracticeScreen
  Future<void> _startListening() async {
    if (listening || saving) return;

    setState(() {
      listening = true;
      recognized = '';
      recognizedWords = [];
      score = 0;
    });

    await _stt.startListening(
      onPartialResult: (text) {
        if (!mounted) return;
        setState(() {
          recognized = text;
          recognizedWords = _splitWords(text);
        });
      },
      onFinalResult: (finalText) {
        if (!mounted) return;
        setState(() {
          recognized = finalText;
          recognizedWords = _splitWords(finalText);
          listening = false;
        });
        _evaluateAndSave();
      },
      durationSeconds: 20,
    );
  }

  List<String> _splitWords(String text) {
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  }

  Future<void> _evaluateAndSave() async {
    if (saving) return;
    setState(() => saving = true);

    // Normalize spoken words (from STT)
    final spoken = recognized
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zæøåäöüéèáíóúñ\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    // Count how many target words were recalled (case-insensitive)
    score = 0;
    for (final w in widget.targetWords) {
      if (spoken.contains(w.toLowerCase())) score++;
    }

    final total = widget.targetWords.length;

    await DataService().saveTask('word_recall', {
      'targetWords': widget.targetWords,
      'recognized': recognized,
      'correct': score,
      'total': total,
      'accuracy': total == 0 ? 0.0 : score / total,
      'durationSec': 20,
    });

    setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.targetWords.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Word Recall', activeStep: 4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Now recall the words',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Press the microphone and say all the words you remember from the Word Task.\n'
              'You will have up to 20 seconds.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            _micIndicator(),
            const SizedBox(height: 16),
            Text(
              listening
                  ? '🎤 Listening for 20 seconds...'
                  : recognized.isEmpty
                      ? 'You said: (none yet)'
                      : 'You said:',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (recognizedWords.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: recognizedWords
                    .map(
                      (word) => Chip(
                        label: Text(word),
                        backgroundColor: Colors.blue.shade50,
                      ),
                    )
                    .toList(),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: Text(listening ? 'Listening...' : 'Speak'),
                  onPressed: listening || saving ? null : _startListening,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!listening && recognized.isNotEmpty)
              PrimaryButton(
                label: saving
                    ? 'Saving...'
                    : 'Next (${score.toString()} / $total)',
                onPressed:
                    saving ? null : () => widget.onFinished(score, total),
              ),
          ],
        ),
      ),
    );
  }

  // Same animated mic style as WordTaskPracticeScreen
  Widget _micIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: listening ? 70 : 50,
      height: listening ? 70 : 50,
      decoration: BoxDecoration(
        color: listening ? Colors.blue : Colors.grey,
        shape: BoxShape.circle,
        boxShadow: [
          if (listening)
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 8,
            ),
        ],
      ),
      child: const Icon(Icons.mic, color: Colors.white, size: 28),
    );
  }
}
