import 'dart:async';
import 'package:flutter/material.dart';
import '../../../domain/models/emotion.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/header_bar.dart';
import 'package:mcat_package/src/services/data_service.dart';

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

  void _selectEmotion(Emotion e) async {
    if (!showImage && selected == null) {
      selected = e;
      final current = widget.items[index];
      if (selected == current.correct) score++;

      // small delay to show feedback
      await Future.delayed(const Duration(milliseconds: 400));

      if (index < widget.items.length - 1) {
        _next();
      } else {
        await _saveResult();
        widget.onFinished(score, widget.items.length);
      }
      setState(() {});
    }
  }

  Future<void> _saveResult() async {
    final total = widget.items.length;
    await DataService().saveTask('face_task', {
      'correct': score,
      'total': total,
      'accuracy': score / total,
      'timeTakenSec': 3 * total, // 3 sec per face
    });
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
      backgroundColor: const Color(0xFFF5F6FB),
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
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600),
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
                              child: Image.asset(
                                current.asset,
                                // ✅ IMPORTANT: load asset from package
                                package: 'mcat_package',
                                fit: BoxFit.contain,
                              ),
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
                      : _buildEmotionOptions(),
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
                    onPressed: () async {
                      await _saveResult();
                      widget.onFinished(score, widget.items.length);
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
