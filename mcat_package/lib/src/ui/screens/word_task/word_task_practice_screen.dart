import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mcat_package/src/services/tts_service.dart';
import 'package:mcat_package/src/services/stt_service.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class WordTaskPracticeScreen extends StatefulWidget {
  final List<String> words;
  final VoidCallback onFinished;

  const WordTaskPracticeScreen({
    super.key,
    required this.words,
    required this.onFinished,
  });

  @override
  State<WordTaskPracticeScreen> createState() => _WordTaskPracticeScreenState();
}

class _WordTaskPracticeScreenState extends State<WordTaskPracticeScreen> {
  final TtsService _tts = TtsService();
  final SttService _stt = SttService();

  bool speaking = false;
  bool listening = false;
  String recognized = '';
  List<String> recognizedWords = [];

  @override
  void initState() {
    super.initState();
    _tts.init();
    _stt.init();
  }

  Future<void> _playWords() async {
    setState(() => speaking = true);
    for (final word in widget.words.take(3)) {
      await _tts.speak(word);
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() => speaking = false);
  }

  Future<void> _start() async {
    setState(() {
      listening = true;
      recognized = '';
      recognizedWords = [];
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
        debugPrint('🎤 Final recognized text: $finalText');
      },
      durationSeconds: 20,
    );
  }

  Future<void> _stop() async {
    await _stt.stopListening();
    if (mounted) setState(() => listening = false);
  }

  List<String> _splitWords(String text) {
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  }

  @override
  void dispose() {
    _tts.dispose();
    _stt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(title: 'Word Task – Practice', activeStep: 2),
      backgroundColor: const Color(0xFFF5F6FB),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Let’s practice. Listen and repeat these words.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            _micIndicator(),
            const SizedBox(height: 16),
            Text(
              listening
                  ? '🎤 Listening for 20 seconds...'
                  : recognized.isEmpty
                      ? 'You said: (none)'
                      : 'You said:',
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Play'),
                  onPressed: speaking ? null : _playWords,
                ),
                ElevatedButton.icon(
                  icon: Icon(listening ? Icons.stop : Icons.mic),
                  label: Text(listening ? 'Stop' : 'Speak'),
                  onPressed: listening ? _stop : _start,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!listening && recognizedWords.isNotEmpty)
              PrimaryButton(
                label: 'Continue',
                onPressed: widget.onFinished,
              ),
          ],
        ),
      ),
    );
  }

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
