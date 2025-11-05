import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mcat_package/src/services/tts_service.dart';
import 'package:mcat_package/src/services/stt_service.dart';
import 'package:mcat_package/src/services/data_service.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class WordTaskPracticeScreen extends StatefulWidget {
  final List<String> words;
  final void Function(int score, int total) onFinished;
  final String title;

  const WordTaskPracticeScreen({
    super.key,
    required this.words,
    required this.onFinished,
    this.title = 'Word Task',
  });

  @override
  State<WordTaskPracticeScreen> createState() =>
      _WordTaskPracticeScreenState();
}

class _WordTaskPracticeScreenState extends State<WordTaskPracticeScreen> {
  final TtsService _tts = TtsService();
  final SttService _stt = SttService();

  bool speaking = false;
  bool listening = false;
  bool completed = false;
  int score = 0;
  String recognizedText = '';
  Stopwatch timer = Stopwatch();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _stt.init();
  }

  Future<void> _playAllWords() async {
    if (speaking) return;
    setState(() => speaking = true);
    for (final word in widget.words) {
      await _tts.speak(word);
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() => speaking = false);
  }

  Future<void> _startListening() async {
    if (listening) return;

    recognizedText = '';
    score = 0;
    timer.start();
    setState(() => listening = true);

    await _stt.startListening(onResult: (result) {
      setState(() => recognizedText = result);
    });

    // allow 15 seconds max listening
    await Future.delayed(const Duration(seconds: 15));
    await _stopListening();
  }

  Future<void> _stopListening() async {
    await _stt.stopListening();
    timer.stop();
    setState(() => listening = false);

    // scoring
    final spokenWords = recognizedText
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    for (final w in widget.words) {
      if (spokenWords.contains(w.toLowerCase())) score++;
    }

    await _saveResult();
    setState(() => completed = true);
  }

  Future<void> _saveResult() async {
    final total = widget.words.length;
    await DataService().saveTask('word_task', {
      'correct': score,
      'total': total,
      'accuracy': score / total,
      'timeTakenMs': timer.elapsedMilliseconds,
    });
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
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(title: widget.title, activeStep: 2),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Listen carefully and repeat all the words you hear.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            _buildWordCard(),
            const SizedBox(height: 24),
            _buildRecognitionArea(),
            const Spacer(),
            if (!completed)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: speaking ? null : _playAllWords,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Play Words'),
                  ),
                  ElevatedButton.icon(
                    onPressed: listening ? null : _startListening,
                    icon: const Icon(Icons.mic),
                    label: const Text('Speak'),
                  ),
                ],
              ),
            if (completed) ...[
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Next',
                onPressed: () => widget.onFinished(score, widget.words.length),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          const Text('Word List',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: widget.words
                .map((w) => Chip(
                      label: Text(w),
                      backgroundColor: Colors.indigo.shade100,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          Text(
            listening
                ? '🎤 Listening...'
                : completed
                    ? '✅ You said ${recognizedText.isEmpty ? "(no words)" : recognizedText}'
                    : 'Press Speak and say all the words',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: listening
                  ? Colors.blue
                  : completed
                      ? Colors.green
                      : Colors.black87,
            ),
          ),
          if (listening) const SizedBox(height: 10),
          if (listening)
            const LinearProgressIndicator(minHeight: 4, color: Colors.blue),
        ],
      ),
    );
  }
}
