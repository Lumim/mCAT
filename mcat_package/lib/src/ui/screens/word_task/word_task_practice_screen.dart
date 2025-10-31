import 'package:flutter/material.dart';
import 'package:mcat_package/src/services/tts_service.dart';
import 'package:mcat_package/src/services/stt_service.dart';
import 'package:mcat_package/src/ui/widgets/voice_pulse.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

/// Word Task Screen — plays all words sequentially and listens for all spoken words.
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
  State<WordTaskPracticeScreen> createState() => _WordTaskPracticeScreenState();
}

class _WordTaskPracticeScreenState extends State<WordTaskPracticeScreen> {
  final TtsService _tts = TtsService();
  final SttService _stt = SttService();

  bool ready = false;
  bool playing = false;
  bool listening = false;

  String recognizedText = '';
  int score = 0;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      await _stt.init();
      setState(() => ready = true);
    } else {
      print('❌ Microphone permission denied');
    }
  }

  /// 🎧 Plays all words sequentially with 1-second delay between them
  Future<void> _playAllWords() async {
    if (playing) return;
    setState(() => playing = true);

    for (int i = 0; i < widget.words.length; i++) {
      await _tts.speak(widget.words[i]);
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() => playing = false);
  }

  /// 🎤 Listens once and checks which words were correctly recognized
  Future<void> _listenAndScoreAll() async {
    if (!ready || listening) return;

    setState(() {
      listening = true;
      recognizedText = '';
    });

    String transcript = '';
    await _stt.startListening(
      onResult: (res) {
        transcript = res;
        setState(() => recognizedText = res);
      },
    );

    // listen for up to 10 seconds total
    await Future.delayed(const Duration(seconds: 10));

    await _stt.stopListening();

    setState(() => listening = false);

    // process transcript
    final spokenWords = transcript
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z\s]'), '')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    print('🗣 Recognized: $spokenWords');

    final expected = widget.words.map((w) => w.toLowerCase()).toList();

    // count matches (spoken words that appear in list)
    int correct = 0;
    for (final word in expected) {
      if (spokenWords.contains(word)) correct++;
    }

    setState(() => score = correct);
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
      appBar: HeaderBar(title: widget.title, activeStep: 3),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'You will hear all the words one by one. Then repeat all of them aloud.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),

            // Word list preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Word List Preview:',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: widget.words
                        .map(
                          (w) => Chip(
                            label: Text(w),
                            backgroundColor: Colors.indigo.shade50,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            listening
                ? listening
                      ? Column(
                          children: const [
                            VoicePulse(),
                            SizedBox(height: 12),
                            Text(
                              'Listening... Say all the words clearly.',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      : Text(
                          recognizedText.isEmpty
                              ? 'Press Speak to start saying the words.'
                              : 'You said:\n"$recognizedText"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: recognizedText.isEmpty
                                ? Colors.black87
                                : Colors.indigo.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                : const Spacer(),

            // 🎧 Play and 🎤 Speak buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: playing ? null : _playAllWords,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Play All Words'),
                ),
                ElevatedButton.icon(
                  onPressed: listening ? null : _listenAndScoreAll,
                  icon: const Icon(Icons.mic),
                  label: const Text('Speak'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ✅ Show score and Finish button
            if (recognizedText.isNotEmpty && !listening)
              Column(
                children: [
                  Text(
                    'Score: $score / ${widget.words.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  PrimaryButton(
                    label: 'Finish',
                    onPressed: () =>
                        widget.onFinished(score, widget.words.length),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
