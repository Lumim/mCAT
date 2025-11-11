import 'package:flutter/material.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../widgets/header_bar.dart';
import 'package:mcat_package/src/services/data_service.dart';

class LnInputScreen extends StatefulWidget {
  final LnController controller;
  const LnInputScreen({super.key, required this.controller});

  @override
  State<LnInputScreen> createState() => _LnInputScreenState();
}

class _LnInputScreenState extends State<LnInputScreen> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    // Optional: persist per-round input
    await DataService().saveTask('ln_input', {
      'round': widget.controller.roundIndex + 1,
      'value': _ctrl.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (!widget.controller.isLast) {
      // ➜ Advance to next round and go back to Play
      widget.controller.nextRound();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/ln-play', // hyphen route
        arguments: widget.controller,
      );
    } else {
      // ➜ Last round: go to Result
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/ln-result', // hyphen route
        arguments: widget.controller,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundNo = widget.controller.roundIndex + 1;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(title: 'LN – Input (Round $roundNo)', activeStep: 3),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Enter a starting number (optional):'),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _onContinue,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
