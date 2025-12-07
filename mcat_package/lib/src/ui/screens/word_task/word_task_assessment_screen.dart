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
  bool ttsFinished = false; // Only after TTS the Speak button should appear
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

  // PLAY ALL WORDS SEQUENTIALLY
  Future<void> _playAllWords() async {
    if (speaking) return;

    setState(() {
      speaking = true;
      listening = false;
      ttsFinished = false;
      recognized = '';
    });

    for (final w in widget.words) {
      await _tts.speak(w);
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      speaking = false;
      ttsFinished = true; // now user may speak
    });
  }

  // START LISTENING
  Future<void> _startListening() async {
    setState(() {
      listening = true;
      speaking = false;
      ttsFinished = false; // Hide Speak button during listening
    });

    _startTimer();

    await _stt.startListening(
      onPartialResult: (text) {
        setState(() => recognized = text);
      },
      onFinalResult: (text) {
        recognized = text;
      },
    );
  }

  // STOP LISTENING
  Future<void> _stopListening() async {
    await _stt.stopListening();

    if (!mounted) return;

    setState(() => listening = false);
  }

  // EVALUATE RESULTS
  void _evaluateAndFinish() {
    final spokenWords = recognized
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    for (final w in widget.words) {
      if (spokenWords.contains(w.toLowerCase())) score++;
    }

    DataService().saveTask('word_task', {
      'correct': score,
      'total': widget.words.length,
      'accuracy': score / widget.words.length,
      'recognized': recognized,
    });

    widget.onFinished(score, widget.words.length);
  }

  // ——————————————————————————
  // TIMER FOR LISTENING
  // ——————————————————————————
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 20), _handleTimeout);
  }

  void _handleTimeout() {
    if (listening) {
      _stopListening();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tts.dispose();
    _stt.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ——————————————————————————
  // BUILD UI
  // ——————————————————————————
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // disable back navigation
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FB),
        appBar: const HeaderBar(title: 'Word Task', activeStep: 2),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Listen carefully and repeat all the words you hear.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 20),

              _micIndicator(),

              const SizedBox(height: 16),

              if (listening)
                const Text('🎤 Listening...', textAlign: TextAlign.center),

              const SizedBox(height: 10),

              if (recognized.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: recognized
                      .split(RegExp(r'\s+'))
                      .where((w) => w.isNotEmpty)
                      .map((w) => Chip(
                            label: Text(w),
                            backgroundColor: Colors.blue.shade50,
                          ))
                      .toList(),
                ),

              const Spacer(),

              // 1️⃣ SHOW "Play Words" only before TTS starts
              if (!speaking && !listening && !ttsFinished && recognized.isEmpty)
                ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text("Play Words"),
                  onPressed: _playAllWords,
                ),

              // 2️⃣ Playing → Disabled button
              if (speaking)
                ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text("Playing..."),
                  onPressed: null,
                ),

              // 3️⃣ After TTS ends → Show Speak button
              if (ttsFinished && !listening)
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text("Speak"),
                  onPressed: _startListening,
                ),

              // 4️⃣ During listening → No buttons

              const SizedBox(height: 20),

              // 5️⃣ After listening ends → Only "Next"
              if (!listening && recognized.isNotEmpty)
                PrimaryButton(
                  label: "Next",
                  onPressed: _evaluateAndFinish,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _micIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: listening ? 80 : 60,
      height: listening ? 80 : 60,
      decoration: BoxDecoration(
        color: listening ? Colors.blueAccent : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.mic, color: Colors.white, size: 32),
    );
  }
}
