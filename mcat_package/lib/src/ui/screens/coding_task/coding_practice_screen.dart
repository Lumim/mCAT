import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/coding_service.dart';
import '../../../domain/models/coding_task_models.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class CodingPracticeScreen extends StatefulWidget {
  final VoidCallback onNext;
  const CodingPracticeScreen({super.key, required this.onNext});

  @override
  State<CodingPracticeScreen> createState() => _CodingPracticeScreenState();
}

class _CodingPracticeScreenState extends State<CodingPracticeScreen>
    with SingleTickerProviderStateMixin {
  late List<CodePair> _sequence;
  int index = 0;
  String feedback = '';
  final TextEditingController _ctrl = TextEditingController();
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _sequence = CodingService.generateSequence(2);
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.9,
      upperBound: 1.1,
    );
  }

  void _checkAnswer() {
    final correct = _sequence[index].letter.toUpperCase();
    if (_ctrl.text.trim().toUpperCase() == correct) {
      feedback = '✅ Correct';
    } else {
      feedback = '❌ Wrong, it was $correct';
    }

    _anim.forward(from: 0.9);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (index < _sequence.length - 1) {
        setState(() {
          index++;
          feedback = '';
          _ctrl.clear();
        });
      } else {
        widget.onNext();
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _sequence[index];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Coding Practice Task', activeStep: 5),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            _buildReferenceTable(),
            const Divider(thickness: 1),
           
            /* Text('Fill in the box with correct words',
                style: const TextStyle(fontSize: 15)), */
            const SizedBox(height: 8),
            Text('Sequence ${index + 1}${_sequence.length}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ScaleTransition(
              scale: _anim,
              child: _codeCard(current.code),
            ),
            const SizedBox(height: 8),
            _inputBox(),
            const SizedBox(height: 6),
            Text(feedback, style: const TextStyle(fontSize: 15)),
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: refCodes
              .map((e) => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(code,
              style: GoogleFonts.inconsolata(
                  fontSize: 34, fontWeight: FontWeight.bold)),
        ),
      );

  Widget _inputBox() => SizedBox(
        width: 120,
        child: TextField(
          controller: _ctrl,
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
            if (val.isNotEmpty) _checkAnswer();
          },
        ),
      );
}
