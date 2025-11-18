import 'package:flutter/material.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../widgets/header_bar.dart';
import 'package:mcat_package/src/services/data_service.dart';

class LnInputScreen extends StatefulWidget {
  final LnController controller;
  //final List<String> letters = controller.current.letterSeq;

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
    String input = _ctrl.text.toUpperCase();
    int calculatedScore = 0;

    // Calculate score based on current input
    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      if (widget.controller.current.letterSeq.contains(char)) {
        calculatedScore++;
      }
    }
    print('Calculated Score: ${calculatedScore.toString()}');

    // Optional: persist per-round input
    await DataService().saveTask('ln_input', {
      'round': widget.controller.roundIndex + 1,
      'score': calculatedScore,
      'total': widget.controller.current.letterSeq.length,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (!widget.controller.isLast) {
      // ➜ Advance to next round and go back to Play
      widget.controller.nextRound();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/ln_play', // hyphen route
        arguments: widget.controller,
      );
    } else {
      // ➜ Last round: go to Result
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/ln_result', // hyphen route
        arguments: widget.controller,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundNo = widget.controller.roundIndex + 1;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(title: 'Letter-Number Task ($roundNo)', activeStep: 3),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Enter the Letters:'),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              maxLength: widget.controller.current.letterSeq.length,
              decoration: InputDecoration(
                counterText: widget.controller.current.letterSeq.join(', '),
                hintText: 'Type here',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                val = val.toUpperCase();
              },
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
