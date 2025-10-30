import 'package:flutter/material.dart';
import 'package:mcat_package/src/services/tts_service.dart';
import 'package:mcat_package/src/services/stt_service.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

/// Word Task Screen — used for both practice and assessment.
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

  int index = 0;
  int score = 0;
  bool listening = false;
  String recognizedWord = '';
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _stt.init();
    setState(() => ready = true);
  }

  Future<void> _playWord() async {
    final word = widget.words[index];
    await _tts.speak(word);
  }

  Future<void> _listenAndScore() async {
    if (!ready) return;

    setState(() {
      listening = true;
      recognizedWord = '';
    });

    await _stt.startListening(onResult: (res) {
      setState(() => recognizedWord = res);
    });

    await Future.delayed(const Duration(seconds: 3));
    await _stt.stopListening();

    setState(() => listening = false);

    final expected = widget.words[index].toLowerCase().trim();
    final spoken = recognizedWord.toLowerCase().trim();

    if (spoken == expected) score++;

    if (index < widget.words.length - 1) {
      setState(() => index++);
    } else {
      widget.onFinished(score, widget.words.length);
    }
  }

  @override
  void dispose() {
    _tts.dispose();
    _stt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.words[index];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(title: widget.title, activeStep: 3),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Listen carefully and repeat the word you hear.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),

            // word card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                ],
              ),
              child: Column(
                children: [
                  Text('Word ${index + 1} of ${widget.words.length}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                 /*  Text(word,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo)), */
                ],
              ),
            ),
            const SizedBox(height: 40),

            // recognition feedback
            listening
                ? Column(
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Listening... Please say the word.'),
                    ],
                  )
                : Text(
                    recognizedWord.isEmpty
                        ? 'Press the mic and repeat the word.'
                        : 'You said: "$recognizedWord"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: recognizedWord.isEmpty
                          ? Colors.black87
                          : Colors.indigo.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _playWord,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Play word'),
                ),
                ElevatedButton.icon(
                  onPressed: listening ? null : _listenAndScore,
                  icon: const Icon(Icons.mic),
                  label: const Text('Speak'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (index == widget.words.length - 1 && !listening)
              PrimaryButton(
                label: 'Finish',
                onPressed: () =>
                    widget.onFinished(score, widget.words.length),
              ),
          ],
        ),
      ),
    );
  }
}
