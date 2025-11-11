import 'package:flutter/material.dart';
import '../../../domain/models/emotion.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/header_bar.dart';
import 'dart:async';

class FacePracticeItem {
  final String asset;
  final Emotion correct;
  FacePracticeItem(this.asset, this.correct);
}

class FaceTaskPracticeScreen extends StatefulWidget {
  final List<FacePracticeItem>
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

class _FaceTaskPracticeScreenState extends State<FaceTaskPracticeScreen>
    with SingleTickerProviderStateMixin {
  int index = 0;
  Emotion? selected;
  bool showImage = true;
  Timer? _timer;
  late AnimationController _progressController;
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _progressController.forward(from: 0);
    setState(() => showImage = true);

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => showImage = false);
    });
  }

  void _next() {
    setState(() {
      selected = null;
      showImage = true;
      index++;
    });
    _startTimer();
  }

  void _selectEmotion(Emotion e) async {
    if (!showImage && selected == null) {
      selected = e;
      //final img = widget.practiceImageAssets[index];

      // small delay to show feedback
      await Future.delayed(const Duration(milliseconds: 400));

      if (index < widget.practiceImageAssets.length - 1) {
        _next();
      } else {
        widget.onPracticeDone();
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              showImage
                  ? 'Look at the face for 3 seconds.'
                  : 'Select the emotion you saw:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: showImage
                      ? Column(
                          key: ValueKey('img_$index'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child:
                                  Image.asset(img.asset, fit: BoxFit.contain),
                            ),
                            const SizedBox(height: 8),
                            AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                final progress =
                                    1.0 - _progressController.value;
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 6,
                                    width: MediaQuery.of(context).size.width *
                                        progress,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : _buildEmotionOptions(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (index == widget.practiceImageAssets.length - 1 && !showImage)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PrimaryButton(
                    label: 'Finish',
                    onPressed: () async {
                      widget.onPracticeDone();
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionOptions() {
    return Column(
      key: const ValueKey('options'),
      children: [
        const SizedBox(height: 12),
        Column(
          children: Emotion.values.map((e) {
            final isSelected = selected == e;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(e.icon, color: e.color, size: 26),
                label: Text(e.label),
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      isSelected ? e.color.withOpacity(0.15) : Colors.white,
                  side: BorderSide(
                    color: isSelected ? e.color : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () => _selectEmotion(e),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
