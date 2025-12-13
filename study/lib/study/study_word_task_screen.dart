import 'package:flutter/material.dart';
import '../../../services/StudySTTService.dart';

class StudyWordTaskScreen extends StatefulWidget {
  const StudyWordTaskScreen({super.key});

  @override
  State<StudyWordTaskScreen> createState() => _StudyWordTaskScreenState();
}

class _StudyWordTaskScreenState extends State<StudyWordTaskScreen> {
  final _studySttService = StudySTTService();
  int _currentListIndex = 0;

  final List<List<String>> wordLists = [
    ['apple', 'table', 'green'],
    ['river', 'stone', 'cloud'],
    ['doctor', 'window', 'music'],
  ];

  @override
  void initState() {
    super.initState();
    _studySttService.startNewStudy();
  }

  Future<void> _startRecording() async {
    await _studySttService.startListening(
      expectedWords: wordLists[_currentListIndex],
      listIndex: _currentListIndex,
    );
  }

  Future<void> _stopRecording() async {
    await _studySttService.stopListening();

    if (_currentListIndex < wordLists.length - 1) {
      setState(() => _currentListIndex++);
    } else {
      await _studySttService.finishStudy();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Recall')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Word List ${_currentListIndex + 1}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(wordLists[_currentListIndex].join(', ')),
            const Spacer(),
            ElevatedButton(
              onPressed: _startRecording,
              child: const Text('Start Speaking'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _stopRecording,
              child: const Text('Stop & Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
