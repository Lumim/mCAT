import 'dart:async';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'package:mcat_package/src/services/stt_service.dart';
import 'package:mcat_package/src/services/tts_service.dart';
import 'package:mcat_package/src/services/data_service.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class WordTaskAssessmentScreen extends StatefulWidget {
  final List<String> words;
  final void Function(int score, int total) onFinished;
  final int sequenceId; // Add sequenceId if needed
  final String studyDeploymentId; // Add studyDeploymentId if needed

  const WordTaskAssessmentScreen({
    super.key,
    required this.words,
    required this.onFinished,
    this.sequenceId = 0,
    this.studyDeploymentId = '',
  });

  @override
  State<WordTaskAssessmentScreen> createState() =>
      _WordTaskAssessmentScreenState();
}

class _WordTaskAssessmentScreenState extends State<WordTaskAssessmentScreen> {
  final TtsService _tts = TtsService();
  final SttService _stt = SttService();

  bool speaking = false;
  bool listening = false;
  bool ttsFinished = false;
  String recognized = '';
  int score = 0;
  int trialNumber = 1; // Track trial number
  Timer? _timer;

  // Track timestamps
  DateTime? _stimuliStartTime;
  DateTime? _responseStartTime;

  // Track all trials data
  final List<Map<String, dynamic>> _trialsData = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _tts.init();
    await _stt.init();
  }

  // PLAY ALL WORDS SEQUENTIALLY
  Future<void> _playAllWords() async {
    if (speaking) return;

    setState(() {
      speaking = true;
      listening = false;
      ttsFinished = false;
      recognized = '';
    });

    // Record stimuli start time
    _stimuliStartTime = DateTime.now();

    for (final w in widget.words) {
      await _tts.speak(w);
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      speaking = false;
      ttsFinished = true; // now user may speak
    });
  }

  // START LISTENING
  Future<void> _startListening() async {
    setState(() {
      listening = true;
      speaking = false;
      ttsFinished = false;
    });

    _startTimer();

    // Record response start time
    _responseStartTime = DateTime.now();

    await _stt.startListening(
      onPartialResult: (text) {
        setState(() => recognized = text);
      },
      onFinalResult: (text) {
        recognized = text;
      },
    );
  }

  // STOP LISTENING
  Future<void> _stopListening() async {
    await _stt.stopListening();

    if (!mounted) return;

    setState(() => listening = false);

    // Save trial data when listening stops
    await _saveTrialData();
  }

  // SAVE TRIAL DATA
  Future<void> _saveTrialData() async {
    final spokenWords = recognized
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    // Calculate trial score
    int trialScore = 0;
    final List<String> correctWords = [];

    for (final w in widget.words) {
      if (spokenWords.contains(w.toLowerCase())) {
        trialScore++;
        correctWords.add(w);
      }
    }

    // Add to total score
    score += trialScore;

    // Save trial data
    final trialData = {
      'stimuli': widget.words,
      'response': correctWords, // Only correctly recognized words
      'stimuli_time': _stimuliStartTime?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      'stimuli_type': 'oral',
      'response_time': _responseStartTime?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      'response_type': 'oral',
      'recognized_text': recognized, // Full recognized text
      'trial_score': trialScore,
      'trial_number': trialNumber,
    };

    _trialsData.add(trialData);
    trialNumber++;
  }

  // EVALUATE AND SAVE FINAL RESULTS
  Future<void> _evaluateAndFinish() async {
    // If we haven't saved the last trial data yet
    if (listening) {
      await _stopListening();
    }

    if (_trialsData.isEmpty) {
      // If no trials were saved (user skipped directly), save empty trial
      await _saveTrialData();
    }

    await _saveFinalResults();
    widget.onFinished(score, widget.words.length);
  }

  // SAVE FINAL RESULTS IN EXAMPLE FORMAT
  Future<void> _saveFinalResults() async {
    final deviceData = _getDeviceData();

    // Format trials data like example (trial1, trial2, etc.)
    final Map<String, dynamic> formattedTrials = {};
    for (int i = 0; i < _trialsData.length; i++) {
      final trialKey = 'trial${i + 1}';
      formattedTrials[trialKey] = _trialsData[i];
    }

    final totalTrials = _trialsData.length;
    final maxPossibleScore = widget.words.length * totalTrials;
    final finalScore = _trialsData.fold<int>(
        0, (sum, trial) => sum + (trial['trial_score'] as int));

    await DataService().saveTask('word_task', {
      'task': 'ListLearning',
      'score': finalScore,
      '__type': 'dk.cachet.icat.listlearning',
      'total_trials': totalTrials,
      'words_per_trial': widget.words.length,
      'max_possible_score': maxPossibleScore,
      'accuracy': finalScore / maxPossibleScore,
      ...formattedTrials, // Spread all trial data
      'deviceData': deviceData,
      'sequenceId': widget.sequenceId,
      'studyDeploymentId': widget.studyDeploymentId,
      'deviceRoleName': 'mCAT Mobile App',
      'timestamp': DateTime.now().toIso8601String(),
      'sensorStartTime': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // GET DEVICE DATA (similar to previous example)
  Map<String, dynamic> _getDeviceData() {
    return {
      'isiPad': false,
      'isMobile': Platform.isAndroid || Platform.isIOS,
      'osVersion': _getOSVersion(),
      'userAgent': _getUserAgent(),
      'isTouchDevice': true,
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

  // TIMER FOR LISTENING
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 20), _handleTimeout);
  }

  void _handleTimeout() {
    if (listening) {
      _stopListening();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tts.dispose();
    _stt.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FB),
        appBar: HeaderBar(
          title: 'Word Task - Trial ${_trialsData.length + 1}',
          activeStep: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Listen carefully and repeat all the words you hear.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 20),

              if (_trialsData.isNotEmpty)
                Column(
                  children: [
                    Text(
                      'Press next to continue to trial ${_trialsData.length + 1}.',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),

              _micIndicator(),

              const SizedBox(height: 16),

              if (listening)
                const Text('🎤 Listening...', textAlign: TextAlign.center),

              const SizedBox(height: 10),

              if (recognized.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: recognized
                      .split(RegExp(r'\s+'))
                      .where((w) => w.isNotEmpty)
                      .map((w) {
                    final isCorrect = widget.words
                        .any((word) => word.toLowerCase() == w.toLowerCase());
                    return Chip(
                      label: Text(w),
                      backgroundColor:
                          isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                      side: BorderSide(
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    );
                  }).toList(),
                ),

              const Spacer(),

              // 1️⃣ SHOW "Play Words" only before TTS starts
              if (!speaking && !listening && !ttsFinished && recognized.isEmpty)
                ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text("Play Words"),
                  onPressed: _playAllWords,
                ),

              // 2️⃣ Playing → Disabled button
              if (speaking)
                ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text("Playing..."),
                  onPressed: null,
                ),

              // 3️⃣ After TTS ends → Show Speak button
              if (ttsFinished && !listening)
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text("Speak"),
                  onPressed: _startListening,
                ),

              // 4️⃣ During listening → No buttons

              const SizedBox(height: 20),

              // 5️⃣ After listening ends → Only "Next"
              if (!listening && recognized.isNotEmpty)
                PrimaryButton(
                  label: "Next",
                  onPressed: _evaluateAndFinish,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _micIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: listening ? 80 : 60,
      height: listening ? 80 : 60,
      decoration: BoxDecoration(
        color: listening ? Colors.blueAccent : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.mic, color: Colors.white, size: 32),
    );
  }
}
