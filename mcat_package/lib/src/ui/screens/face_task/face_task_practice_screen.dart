import 'package:flutter/material.dart';
import '../../../domain/models/emotion.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/header_bar.dart';
class FaceTaskPracticeScreen extends StatefulWidget {
  final List<String>
  practiceImageAssets; // e.g., ['assets/images/face_1.png', 'assets/images/face_2.png']
  final VoidCallback onPracticeDone;
  const FaceTaskPracticeScreen({
    super.key,
    required this.practiceImageAssets,
    required this.onPracticeDone,
  });

  @override
  State<FaceTaskPracticeScreen> createState() => _FaceTaskPracticeScreenState();
}

class _FaceTaskPracticeScreenState extends State<FaceTaskPracticeScreen> {
  int index = 0;
  Emotion? selected;

  void _next() {
    setState(() {
      selected = null;
      if (index < widget.practiceImageAssets.length - 1) {
        index++;
      } else {
        widget.onPracticeDone();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final img = widget.practiceImageAssets[index];
    return Scaffold(
      /* appBar: AppBar(title: const Text('Face Task – Practice')), */
       appBar: const HeaderBar(title: 'Face Task', activeStep: 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text('Figure out the emotion by seeing the picture.'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(child: Image.asset(img, fit: BoxFit.contain)),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: Emotion.values.map((e) {
                      final isSelected = selected == e;
                      return ChoiceChip(
                        label: Text(e.label),
                        selected: isSelected,
                        onSelected: (_) => setState(() => selected = e),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PrimaryButton(
                  label: 'Next',
                  onPressed: selected != null ? _next : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
