import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';
import '../../../domain/models/letter_number_models.dart';

class LnInputScreen extends StatefulWidget {
  final LnController controller;
  final VoidCallback onRoundFinished; // next round or result
  const LnInputScreen({
    super.key,
    required this.controller,
    required this.onRoundFinished,
  });

  @override
  State<LnInputScreen> createState() => _LnInputScreenState();
}

class _LnInputScreenState extends State<LnInputScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    widget.controller.submitLetters(_controller.text);
    widget.onRoundFinished();
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.controller.roundIndex + 1;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(
        title: 'Letter Number Task (Round $round)',
        activeStep: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Now, please enter the letters in any order',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Tap and Type',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(label: 'Next', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
