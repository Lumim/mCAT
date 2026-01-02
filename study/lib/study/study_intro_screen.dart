import 'package:flutter/material.dart';
import '../routes.dart';

class StudyIntroScreen extends StatelessWidget {
  const StudyIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('mCAT word study')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You will be asked to recall 3 lists of words.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.studyWordTask);
              },
              child: const Text('Start Study'),
            ),
          ],
        ),
      ),
    );
  }
}
