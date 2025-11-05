import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/coding_service.dart';
import '../../../domain/models/coding_task_models.dart';
import '../../../services/data_service.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class CodingAssessmentScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const CodingAssessmentScreen({super.key, required this.onFinish});

  @override
  State<CodingAssessmentScreen> createState() => _CodingAssessmentScreenState();
}

class _CodingAssessmentScreenState extends State<CodingAssessmentScreen>
    with SingleTickerProviderStateMixin {
  late List<CodePair> _sequence;
  int index = 0;
  int correct = 0;
  int total = 15;
  int elapsed = 0;
  final controller = TextEditingController();
  late AnimationController _anim;
  Timer? timer;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    _sequence = CodingService.generateSequence(total);
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => elapsed++);
      if (elapsed >= 40) _completeTask(showPopup: true);
    });
  }

  void _checkLetter(String input) {
    final expected = _sequence[index].letter.toUpperCase();
    if (input.trim().toUpperCase() == expected) correct++;
    _anim.forward(from: 0.9);
    controller.clear();

    if (index < total - 1) {
      setState(() => index++);
    } else {
      _completeTask();
    }
  }

  Future<void> _completeTask({bool showPopup = false}) async {
    if (finished) return;
    finished = true;
    timer?.cancel();

    if (showPopup && mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Time\'s up!'),
          content: const Text('Your test has ended automatically.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }

    await DataService().saveTask('coding_task', {
      'correct': correct,
      'total': total,
      'accuracy': correct / total,
      'timeTakenSec': elapsed,
    });

    if (mounted) widget.onFinish();
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _sequence[index];
    final remaining = 40 - elapsed;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Coding Task', activeStep: 5),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            _buildReferenceTable(),
            const Divider(thickness: 1),
            Text('Sequence ${index + 1}/$total • Time left: $remaining s',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            ScaleTransition(
              scale: _anim,
              child: _codeCard(current.code),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              child: TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                maxLength: 1,
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: 'Type here',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty) _checkLetter(val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceTable() {
    final refCodes = CodingService.baseSet.take(5).toList();
    return Column(
      children: [
        const Text(
          'Look at the table below.\nEach letter has a code made of stars (*) and circles (o).',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: refCodes
              .map((e) => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(e.code,
                            style: GoogleFonts.inconsolata(
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 3),
                      Text(e.letter,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _codeCard(String code) => Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(code,
              style: GoogleFonts.inconsolata(
                  fontSize: 34, fontWeight: FontWeight.bold)),
        ),
      );
}
