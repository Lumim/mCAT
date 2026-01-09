import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart'; // For device detection
import '../../../domain/models/emotion.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/header_bar.dart';
import 'package:mcat_package/src/services/data_service.dart';

class FaceItem {
  final String asset;
  final Emotion correct;
  final String stimuli; // Add this to match example format (e.g., "cjneut")

  FaceItem(this.asset, this.correct, this.stimuli);
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

  // Track timestamps for each trial
  final Map<int, DateTime> _stimuliTimes = {};
  final Map<int, DateTime> _responseTimes = {};
  final Map<int, Map<String, dynamic>> _trialData = {};

  // Track emotion counts
  final Map<Emotion, int> _emotionCounts = {for (var e in Emotion.values) e: 0};
  final Map<Emotion, int> _correctCounts = {for (var e in Emotion.values) e: 0};

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

    // Record when the stimulus was shown
    _stimuliTimes[index] = DateTime.now();

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => showImage = false);
    });
  }

  void _selectEmotion(Emotion e) async {
    if (!showImage && selected == null) {
      selected = e;

      // Record response time
      _responseTimes[index] = DateTime.now();

      final current = widget.items[index];
      final isCorrect = selected == current.correct;

      // Update counts
      _emotionCounts[current.correct] =
          (_emotionCounts[current.correct] ?? 0) + 1;
      if (isCorrect) {
        score++;
        _correctCounts[current.correct] =
            (_correctCounts[current.correct] ?? 0) + 1;
      }

      // Store trial data
      _trialData[index] = {
        'correct': isCorrect,
        'stimuli': current.stimuli, // e.g., "cjneut"
        'response': e.toString().split('.').last, // e.g., "neut"
        'stimuli_time': _stimuliTimes[index]?.toIso8601String(),
        'stimuli_type': 'image',
        'response_time': _responseTimes[index]?.toIso8601String(),
        'response_type': 'button',
      };

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

    // Calculate overview statistics
    Map<String, dynamic> overview = {};
    for (var emotion in Emotion.values) {
      final emotionKey = _getEmotionKey(emotion); // Convert to example format
      final count = _emotionCounts[emotion] ?? 0;
      final correct = _correctCounts[emotion] ?? 0;
      final percentageCorrect = count > 0 ? correct / count : 0.0;

      overview[emotionKey] = {
        'count': count,
        'correct': correct,
        'percentageCorrect': percentageCorrect,
      };
    }

    // Format responses in example format (trial1, trial2, etc.)
    Map<String, dynamic> responses = {};
    for (var i = 0; i < _trialData.length; i++) {
      final trialKey = 'trial${i + 1}';
      responses[trialKey] = _trialData[i];
    }

    // Get device data
    final deviceData = _getDeviceData();

    // Save all data
    await DataService().saveTask('face_task', {
      'overview': overview,
      'responses': responses,
      'deviceData': deviceData,
      'correct': score,
      'total': total,
      'accuracy': score / total,
      'timeTakenSec': 3 * total,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  String _getEmotionKey(Emotion emotion) {
    // Convert Emotion enum to the format used in example
    switch (emotion) {
      case Emotion.angry:
        return 'ang';
      case Emotion.disgust:
        return 'dis';
      case Emotion.happy:
        return 'hap';
      case Emotion.sad:
        return 'sad';
      case Emotion.surprise:
        return 'sur';

      case Emotion.neutral:
        return 'neut';
        // case Emotion.fearful:
        //return 'fear';
        // TODO: Handle this case.
        // ignore: dead_code
        throw UnimplementedError();
      case Emotion.fear:
        return 'fear';
        // TODO: Handle this case.
        // ignore: dead_code
        throw UnimplementedError();
    }
  }

  Map<String, dynamic> _getDeviceData() {
    // This is a simplified version - you might want to use a package like device_info
    return {
      'isiPad': false, // You'd need to detect this properly
      'isMobile': Platform.isAndroid || Platform.isIOS,
      'osVersion': _getOSVersion(),
      'userAgent': _getUserAgent(),
      'isTouchDevice': true, // Assuming mobile/tablet
      'possibleDeviceType': _getDeviceType(),
    };
  }

  String _getOSVersion() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'Mac OS X';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  String _getUserAgent() {
    // For Flutter web, you'd use dart:html
    // For mobile, you can use device_info package
    return 'Flutter App';
  }

  String _getDeviceType() {
    final size = MediaQuery.of(context).size;
    final ratio = MediaQuery.of(context).devicePixelRatio;
    final width = size.width * ratio;
    final height = size.height * ratio;

    if (width > 1100 || height > 1100) {
      return 'tablet';
    }
    return 'mobile';
  }

  void _next() {
    setState(() {
      selected = null;
      showImage = true;
      index++;
    });
    _startTimer();
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

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
              if (index == widget.items.length - 1 && !showImage)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PrimaryButton(
                      label: 'Next',
                      onPressed: () async {
                        await _saveResult();
                        widget.onFinished(score, widget.items.length);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
            ],
          ),
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
