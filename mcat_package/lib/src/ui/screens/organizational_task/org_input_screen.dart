import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../../domain/models/organizational_models.dart';

class OrgInputScreen extends StatefulWidget {
  final OrgController controller;
  const OrgInputScreen({super.key, required this.controller});

  @override
  State<OrgInputScreen> createState() => _OrgInputScreenState();
}

class _OrgInputScreenState extends State<OrgInputScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String? _feedback; // null / 'correct' / 'wrong'
  String? _explanation;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _sanitize(String s) => s.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  void _checkAnswer() {
    final answer = _sanitize(_ctrl.text);
    final correct = widget.controller.current.correctAnswer;
    final ok = answer == correct;
    widget.controller.recordCorrect(ok);

    setState(() {
      _feedback = ok ? 'correct' : 'wrong';
      _explanation = ok
          ? 'Your answer was $answer\nWell done!'
          : 'Your answer was\n$answer\n\nThe correct answer is $correct';
    });
  }

  void _next() {
    if (!widget.controller.isLast) {
      widget.controller.nextRound();
      Navigator.pushReplacementNamed(context, '/org_play',
          arguments: widget.controller);
    } else {
      Navigator.pushReplacementNamed(context, '/org_result',
          arguments: widget.controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundNo = widget.controller.roundIndex + 1;
    final total = widget.controller.totalRounds;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(
          title: 'Organizational – Round $roundNo/$total', activeStep: 4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the numbers first (ascending), then letters in alphabetical order.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Type and Tap Check',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_feedback != null)
              Card(
                color: _feedback == 'correct'
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _explanation!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _feedback == 'correct'
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, '/org_play',
                        arguments: widget.controller),
                    child: const Text('Hear Again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _feedback == null ? _checkAnswer : _next,
                    child: Text(_feedback == null ? 'CHECK ANSWER' : 'Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
