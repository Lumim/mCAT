import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class CodingRealTextScreen extends StatelessWidget {
  final VoidCallback onNext;
  const CodingRealTextScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(
        title: 'Coding Task',
        activeStep: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Practice Complete!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      ' '
                      'Now you will move to the actual coding task. '
                      'You will have limited time to complete a total sequence of 15 coding problems.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(
              flex: 12,
            ),
            SizedBox(height: 10), // Add 10px gap
            PrimaryButton(label: 'Start Assessment', onPressed: onNext),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
