import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/stt_service.dart';
import '../../../services/word_recall_service.dart';
import '../../../domain/models/word_recall_models.dart';
import '../../widgets/header_bar.dart';

class WordRecallListeningScreen extends StatefulWidget {
  final void Function(WordRecallResult result) onFinished;
  const WordRecallListeningScreen({super.key, required this.onFinished});

  @override
  State<WordRecallListeningScreen> createState() =>
      _WordRecallListeningScreenState();
}

class _WordRecallListeningScreenState extends State<WordRecallListeningScreen> {
  final _stt = SttService();
  bool _listening = false;
  String _recognized = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  Future<void> _startListening() async {
    await _stt.init();
    setState(() => _listening = true);

    _stt.startListening(onResult: (text) {
      setState(() => _recognized = text);
    });

    // Auto-stop after 12 seconds
    _timer = Timer(const Duration(seconds: 12), _finish);
  }

  Future<void> _finish() async {
    await _stt.stopListening();
    setState(() => _listening = false);

    final spokenWords = WordRecallService.extractWords(_recognized);
    final target = WordRecallService.getOriginalWordList();
    final correct = WordRecallService.scoreRecall(spokenWords, target);

    widget.onFinished(WordRecallResult(
      recalledWords: spokenWords,
      correctCount: correct,
      total: target.length,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Word Recall Task', activeStep: 4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text('Now say the words you heard before.',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mic,
                    color: _listening ? Colors.blue : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _listening ? 'Listening...' : 'Stopped',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_recognized.isNotEmpty)
              Text(
                'Recognized: $_recognized',
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            if (!_listening)
              ElevatedButton(
                onPressed: _finish,
                child: const Text('End'),
              ),
          ],
        ),
      ),
    );
  }
}
