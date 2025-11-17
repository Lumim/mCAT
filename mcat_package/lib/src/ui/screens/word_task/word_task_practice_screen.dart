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

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _stt.init();
  }

  Future<void> _playWords() async {
    await _stop();

    setState(() {
      listening = false;
      speaking = true;
    });
    for (final word in widget.words.take(3)) {
      await _tts.speak(word);
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() => speaking = false);
  }

  Future<void> _start() async {
    startTimer();
    setState(() {
      listening = true;
      speaking = false;
    });
    _tts.dispose();

    await _stt.startListening(
      onPartialResult: (text) {
        setState(() => recognized = text);
      },
      onFinalResult: (finalText) {
        recognized = finalText;
        debugPrint('🎤 Final recognized text: $finalText');
      },
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
    _timer?.cancel();
    _tts.dispose();
    _stt.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      //listening = false;
      speaking = false;
    });
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 20), _onTimerComplete);
    print('Timer started for 20 seconds...');
  }

  void _onTimerComplete() {
    print('Timer completed. Stopping listening...');
    if (listening) {
      _stop();
      setState(() {
        speaking = false;
      });
    }
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
              'Let`s practice.',
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
                  label: const Text('Play'),
                  onPressed: speaking ? null : _playWords,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text('Speak'),
                  onPressed: listening ? null : _start,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!listening && _splitWords(recognized).isNotEmpty)
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
