import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mcat_package/src/services/stt_service.dart';
import 'package:mcat_package/src/services/tts_service.dart';
import 'package:mcat_package/src/services/data_service.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class WordTaskAssessmentScreen extends StatefulWidget {
  final List<String> words;
  final void Function(int score, int total) onFinished;

  const WordTaskAssessmentScreen({
    super.key,
    required this.words,
    required this.onFinished,
  });

  @override
  State<WordTaskAssessmentScreen> createState() =>
      _WordTaskAssessmentScreenState();
}

class _WordTaskAssessmentScreenState extends State<WordTaskAssessmentScreen> {
  final TtsService _tts = TtsService();
  final SttService _stt = SttService();
  bool speaking = false;
  bool listening = false;
  String recognized = '';
  int score = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _tts.init();
    await _stt.init();
  }

  Future<void> _playAllWords() async {
    if (speaking) return;
    setState(() => speaking = true);
    for (final w in widget.words) {
      await _tts.speak(w);
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() => speaking = false);
  }

  Future<void> _startListening() async {
    startTimer();
    setState(() => listening = true);

    await _stt.startListening(
      onPartialResult: (text) {
        setState(() => recognized = text);
      },
      onFinalResult: (finalText) {
        // Triggered when user pauses for a few seconds or stops manually
        recognized = finalText;
        debugPrint('🎤 Final recognized text: $finalText');
      },
    );
  }

  /// Stop the listening session
  Future<void> _stop() async {
    await _stt.stopListening();
    setState(() => listening = false);
  }

  void _evaluate() async {
    final spoken = recognized
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    for (final w in widget.words) {
      if (spoken.contains(w.toLowerCase())) score++;
    }

    await DataService().saveTask('word_task', {
      'correct': score,
      'total': widget.words.length,
      'accuracy': score / widget.words.length,
      'recognized': recognized,
    });

    widget.onFinished(score, widget.words.length);
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

  void startTimer() {
    // Cancel existing timer if any
    _timer?.cancel();

    // Start new timer
    _timer = Timer(const Duration(seconds: 20), _onTimerComplete);

    print('Timer started for 20 seconds...');
  }

  void _onTimerComplete() {
    print('Timer completed. Stopping listening...');
    if (listening) {
      _stop();
      setState(() {
        listening = false;
        _evaluate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Word Task', activeStep: 2),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Listen carefully and repeat all the words you hear.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              'Listen carefully and repeat all the words you hear.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            _micIndicator(),
            const SizedBox(height: 20),
            Text(
              listening
                  ? '🎤 Listening...'
                  : 'Your words are: ${recognized.isEmpty && !listening ? "(none)" : ""}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (recognized.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _splitWords(recognized)
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
                  label: const Text('Play Words'),
                  onPressed: speaking ? null : _playAllWords,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text('Speak'),
                  onPressed: listening ? null : _startListening,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!listening && recognized.isNotEmpty)
              PrimaryButton(
                label: 'Next',
                onPressed: () => widget.onFinished(score, widget.words.length),
              ),
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _micIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: listening ? 80 : 60,
      height: listening ? 80 : 60,
      decoration: BoxDecoration(
        color: listening ? Colors.blueAccent : Colors.grey.shade400,
        shape: BoxShape.circle,
        boxShadow: [
          if (listening)
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 10,
            ),
        ],
      ),
      child: const Icon(Icons.mic, color: Colors.white, size: 36),
    );
  }
}
