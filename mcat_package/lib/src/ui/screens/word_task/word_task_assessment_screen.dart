import 'package:flutter/material.dart';
import 'word_task_practice_screen.dart';

class WordTaskAssessmentScreen extends StatelessWidget {
  final List<String> words;
  final void Function(int score, int total) onFinished;

  const WordTaskAssessmentScreen({
    super.key,
    required this.words,
    required this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    return WordTaskPracticeScreen(
      title: 'Word Task - Assessment',
      words: words,
      onFinished: onFinished,
    );
  }
}
