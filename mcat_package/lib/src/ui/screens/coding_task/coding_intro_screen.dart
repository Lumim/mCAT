import 'package:flutter/material.dart';
import '../../widgets/infocard.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';
import '../../../services/tts_service.dart';

class CodingIntroScreen extends StatefulWidget {
  final VoidCallback onNext;
  const CodingIntroScreen({super.key, required this.onNext});

  @override
  State<CodingIntroScreen> createState() => _CodingIntroScreenState();
}

class _CodingIntroScreenState extends State<CodingIntroScreen> {
  bool _isPlaying = false;
  final _tts = TtsService();
  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  Future<void> _speak() async {
    !_isPlaying
        ? setState(() => _isPlaying = true)
        : setState(() => _isPlaying = false);
    _isPlaying
        ? await _tts.speak(
            'In this task, you will match symbols made of stars and circles with letters. '
            'Before doing the test, you will have the opportunity to practice this "letter'
            ' and code" task. You will be able to practice 6 times and you will be told whether what you typed was right or wrong.'
            'The task is to complete each box with the correct letter that corresponds to the code. '
            'By starting the task, you should fill in the boxes below with the correct letter.'
            'When entering a letter, The test will automatically move you to the next code. Note that you cannot go back and correct letters, so just proceed to the right.',
          )
        : _tts.dispose();
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Coding Task', activeStep: 5),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // const StepIndicator(activeIndex: 5),
            const SizedBox(height: 20),
            const Text('Instructions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            InfoCard(
              text:
                  'In this task, you are going to match symbols with letters. '
                  'Before doing the test, you will have the opportunity to practice this “letter and code” task.',
              fontSize: 16,
            ),
            const Spacer(flex: 1),
            InfoCard(
              text:
                  'You will practice 1 set of 6 codes and will be told whether your answer was right or wrong.',
              fontSize: 16,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _speak,
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.blue,
                size: 28,
              ),
              label: Text(_isPlaying ? 'Playing' : 'Hear instructions',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w600)),
            ),

            const Spacer(flex: 3),
            !_isPlaying
                ? PrimaryButton(
                    label: 'Start Assessment', onPressed: widget.onNext)
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
