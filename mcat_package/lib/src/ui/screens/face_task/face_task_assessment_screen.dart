import 'dart:async';
import 'package:flutter/material.dart';
import '../../../domain/models/emotion.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/header_bar.dart';

class FaceItem {
  final String asset;
  final Emotion correct;
  FaceItem(this.asset, this.correct);
}

class FaceTaskAssessmentScreen extends StatefulWidget {
  final List<FaceItem> items;
  final void Function(int score, int total) onFinished;
  const FaceTaskAssessmentScreen({
    super.key,
    required this.items,
    required this.onFinished,
  });

  @override
  State<FaceTaskAssessmentScreen> createState() =>
      _FaceTaskAssessmentScreenState();
}

class _FaceTaskAssessmentScreenState extends State<FaceTaskAssessmentScreen>
    with SingleTickerProviderStateMixin {
  int index = 0;
  int score = 0;
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

  void _selectEmotion(Emotion e) {
    if (!showImage && selected == null) {
      selected = e;
      final current = widget.items[index];
      if (selected == current.correct) score++;

      if (index < widget.items.length - 1) {
        Future.delayed(const Duration(milliseconds: 100), _next);
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          widget.onFinished(score, widget.items.length);
        });
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
    final current = widget.items[index];

    return Scaffold(
      appBar: HeaderBar(title: 'Face Task - Assessment', activeStep: 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Look at the face for 3 seconds, then select the emotion you saw.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: showImage
                      ? Column(
                          key: ValueKey('img_$index'),
                          children: [
                            Expanded(
                              child: Image.asset(
                                current.asset,
                                fit: BoxFit.contain,
                              ),
                            ),
                            //const SizedBox(height: 2),
                            AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                final progress =
                                    1.0 - _progressController.value;
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 6,
                                    width:
                                        MediaQuery.of(context).size.width *
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
                      : Column(
                          key: const ValueKey('options'),
                          children: [
                            const Text(
                              'Select the emotion below:',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: Emotion.values.map((e) {
                                final isSelected = selected == e;
                                return ChoiceChip(
                                  label: Text(e.label),
                                  selected: isSelected,
                                  onSelected: (_) => _selectEmotion(e),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (index == widget.items.length - 1 && !showImage)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PrimaryButton(
                    label: 'Finish',
                    onPressed: () =>
                        widget.onFinished(score, widget.items.length),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
