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
    String input = _ctrl.text.toUpperCase();
    int calculatedScore = 0;

    // Calculate score based on current input
    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      if (widget.controller.current.letterSeq.contains(char)) {
        calculatedScore++;
      }
    }

    // Save response data matching the example format
    await DataService()
        .saveTask('ln_input${widget.controller.roundIndex + 1}', {
      'stimuli': widget.controller.current.letterSeq, // e.g., ["2L", "6P"]
      'response': input.split(''), // e.g., ["L", "P"]
      'stimuli_time': widget.controller.currentStimuliTime?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      'response_time': DateTime.now().toIso8601String(),
      'response_type': 'written',
      'round': widget.controller.roundIndex + 1,
      'score': calculatedScore,
      'total': widget.controller.current.letterSeq.length,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('Calculated Score: ${calculatedScore.toString()}');

    if (!widget.controller.isLast) {
      widget.controller.nextRound();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/ln_play',
        arguments: widget.controller,
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/ln_result',
        arguments: widget.controller,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundNo = widget.controller.roundIndex + 1;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FB),
        appBar: HeaderBar(title: 'Letter-Number Task $roundNo', activeStep: 3),
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFFFFF),
                  backgroundColor: const Color(0xFF006BA6),
                ),
                child: const Text('Continue'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
