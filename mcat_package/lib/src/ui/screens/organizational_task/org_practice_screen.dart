import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../../domain/models/organizational_models.dart';
import 'package:mcat_package/src/services/tts_service.dart';
import 'package:mcat_package/src/services/data_service.dart';

class OrgPracticeScreen extends StatefulWidget {
  final OrgController controller;
  final VoidCallback onNext;
  const OrgPracticeScreen(
      {super.key, required this.controller, required this.onNext});

  @override
  State<OrgPracticeScreen> createState() => _OrgPracticeScreenState();
}

class _OrgPracticeScreenState extends State<OrgPracticeScreen> {
  final TtsService _tts = TtsService();
  final TextEditingController _ctrl = TextEditingController();
  bool _speaking = false;
  String? _feedback;
  String? _explanation;
  DateTime? _stimuliTime;
  DateTime? _responseTime;
  bool _practiceCompleted = false;

  @override
  void initState() {
    super.initState();
    _tts.init();
    // Reset controller for practice
    widget.controller.resetForPractice();
  }

  @override
  void dispose() {
    _tts.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  String _sanitize(String s) => s.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  Future<void> _playPractice() async {
    setState(() {
      _speaking = true;
      _feedback = null;
      _explanation = null;
      _ctrl.clear();
    });

    // Record stimuli time
    _stimuliTime = DateTime.now();

    await _tts.speak(widget.controller.current.ttsPhrase);
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) setState(() => _speaking = false);
  }

  Future<void> _checkPracticeAnswer() async {
    final answer = _sanitize(_ctrl.text);
    final correct = widget.controller.current.correctAnswer;
    final ok = answer == correct;

    // Record response time
    _responseTime = DateTime.now();

    setState(() {
      _feedback = ok ? 'correct' : 'wrong';
      _explanation = ok
          ? 'Your answer was $answer\nWell done! ✅'
          : 'Your answer was $answer\n\nThe correct answer is $correct\n\nTry again!';
    });

    // Save practice data
    // await _savePracticeData(answer, correct, ok);

    if (ok) {
      widget.onNext();
      setState(() => _practiceCompleted = true);
    }
  }

  Future<void> _savePracticeData(
      String answer, String correct, bool isCorrect) async {
    await DataService().saveTask('org_practice', {
      'task': 'WAISL_Practice',
      'stimuli': widget.controller.current.ttsPhrase.split(' '),
      'response': answer.split(''),
      'correct_response': correct.split(''),
      'is_correct': isCorrect,
      'stimuli_time': _stimuliTime?.toIso8601String(),
      'response_time': _responseTime?.toIso8601String(),
      'response_type': 'written',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _continueToRealTask() {
    Navigator.pushReplacementNamed(context, '/org_intro',
        arguments: widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Organizational Practice', activeStep: 4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Practice Round\n\nListen carefully, then type: numbers first (ascending), then letters (A-Z).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // Play button
            ElevatedButton.icon(
              onPressed: _speaking ? null : _playPractice,
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFFFFFFF),
                backgroundColor: const Color(0xFF006BA6),
              ),
              icon: const Icon(Icons.volume_up),
              label: const Text('Play Practice Sequence'),
            ),

            const SizedBox(height: 20),

            // Input field
            TextField(
              controller: _ctrl,
              enabled: !_speaking && !_practiceCompleted,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Type your answer here',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Check button
            if (!_practiceCompleted)
              ElevatedButton(
                onPressed: _ctrl.text.isEmpty ? null : _checkPracticeAnswer,
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFFFFF),
                  backgroundColor: Colors.lightGreenAccent.shade700,
                ),
                child: const Text('Check Answer'),
              ),

            // Feedback
            if (_feedback != null)
              Card(
                color: _feedback == 'correct'
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _explanation!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _feedback == 'correct'
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_feedback == 'wrong') const SizedBox(height: 8),
                      if (_feedback == 'wrong')
                        const Text(
                          'Tap "Play Practice Sequence" to hear it again',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Continue to real task button (only when practice is completed)
            if (_practiceCompleted)
              ElevatedButton(
                onPressed: _continueToRealTask,
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFFFFF),
                  backgroundColor: const Color(0xFF006BA6),
                ),
                child: const Text('Start Real Task'),
              ),
          ],
        ),
      ),
    );
  }
}
