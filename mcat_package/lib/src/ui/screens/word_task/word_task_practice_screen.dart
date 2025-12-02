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
  bool hasPlayed = false;

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
      hasPlayed = true;
    });
    
    for (final word in widget.words.take(3)) {
      await _tts.speak(word);
      await Future.delayed(const Duration(seconds: 1));
    }
    
    setState(() => speaking = false);
  }

  Future<void> _startListening() async {
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
      speaking = false;
    });
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 6), _onTimerComplete);
    print('Timer started for 6 seconds...');
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
            
            // Show only one button at a time
            if (!hasPlayed && !speaking && !listening)
              ElevatedButton.icon(
                icon: const Icon(Icons.volume_up),
                label: const Text('Play Words'),
                onPressed: _playWords,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            
            if (speaking)
              ElevatedButton.icon(
                icon: const Icon(Icons.volume_up),
                label: const Text('Playing...'),
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            
            if (hasPlayed && !speaking && !listening)
              ElevatedButton.icon(
                icon: const Icon(Icons.mic),
                label: const Text('Speak Now'),
                onPressed: _startListening,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            
            if (listening)
              ElevatedButton.icon(
                icon: const Icon(Icons.mic),
                label: const Text('Listening...'),
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            
            const SizedBox(height: 16),
            if (!listening && _splitWords(recognized).isNotEmpty)
              PrimaryButton(
                label: 'Continue',
                onPressed: widget.onFinished,
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