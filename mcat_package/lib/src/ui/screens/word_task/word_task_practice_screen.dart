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
  bool ttsFinished = false;

  String recognized = '';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _stt.init();
  }

  // ——————————————————————————
  // PLAY FIRST 3 WORDS
  // ——————————————————————————
  Future<void> _playWords() async {
    setState(() {
      speaking = true;
      listening = false;
      ttsFinished = false;

      recognized = '';
    });

    for (final w in widget.words.take(3)) {
      await _tts.speak(w);
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      speaking = false;
      ttsFinished = true;
    });
  }

  // ——————————————————————————
  // START LISTENING
  // ——————————————————————————
  Future<void> _startListening() async {
    setState(() {
      listening = true;
      ttsFinished = false;
    });

    _startTimer();

    await _stt.startListening(
      onPartialResult: (text) => setState(() => recognized = text),
      onFinalResult: (text) => recognized = text,
    );
  }

  Future<void> _stopListening() async {
    await _stt.stopListening();
    setState(() => listening = false);
  }

  // TIMER
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 8), () {
      if (listening) _stopListening();
    });
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
        appBar: const HeaderBar(title: 'Word Task – Practice', activeStep: 2),
        backgroundColor: const Color(0xFFF5F6FB),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Let\'s practice.',
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
                    : recognized.isEmpty
                        ? 'Tap "Play" to hear the words'
                        : 'Your recognized words:',
              ),

              const SizedBox(height: 10),

              if (recognized.isNotEmpty)
                Wrap(
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

              // Before TTS
              if (!speaking && !listening && !ttsFinished && recognized.isEmpty)
                ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text("Play Words"),
                  onPressed: _playWords,
                ),

              // During TTS
              if (speaking)
                ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text("Playing..."),
                  onPressed: null,
                ),

              // After TTS → Speak
              if (ttsFinished && !listening && recognized.isEmpty)
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text("Speak"),
                  onPressed: _startListening,
                ),

              // After listening → ONLY Continue
              if (!listening && recognized.isNotEmpty)
                PrimaryButton(
                  label: "Continue",
                  onPressed: widget.onFinished,
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
