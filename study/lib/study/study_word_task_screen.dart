import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mcat_package/src/services/stt_service.dart';
import 'package:mcat_package/src/services/tts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class StudyWordTaskScreen extends StatefulWidget {
  const StudyWordTaskScreen({super.key});

  @override
  State<StudyWordTaskScreen> createState() => _StudyWordTaskScreenState();
}

class _StudyWordTaskScreenState extends State<StudyWordTaskScreen> {
  final SttService _sttService = SttService();
  final TtsService _ttsService = TtsService();

  int _currentListIndex = 0;
  bool _speaking = false;
  bool _listening = false;
  bool _ttsFinished = false;
  String _recognizedText = '';
  String _finalizedText = '';
  Timer? _listeningTimer;
  int _timeRemaining = 20;

  final List<List<String>> wordLists = [
    [
      'coffee',
      'flower',
      'mountain',
      'school',
      'popcorn',
      'drum',
      'umbrella',
      'bird',
      'music',
      'river',
    ],
    [
      'book',
      'sky',
      'city',
      'turkey',
      'curtain',
      'nose',
      'snowman',
      'bike',
      'fish',
      'airport',
    ],
    [
      'clock',
      'garden',
      'window',
      'pencil',
      'guitar',
      'elephant',
      'bridge',
      'camera',
      'island',
      'candle',
    ],
  ];
  final List<List<String>> DAwordLists = [
    [
      'tromme',
      'student',
      'kaffe',
      'fly',
      'stjerne',
      'telefon',
      'sukker',
      'taske',
      'zebra',
      'kirke',
    ],
    [
      'butik',
      'torsk',
      'musik',
      'snemand',
      'tomat',
      'skole',
      'firkant',
      'maleri',
      'sky',
      'elefant',
    ],
    [
      'regn',
      'cykel',
      'bog',
      'hav',
      'bil',
      'fisk',
      'seng',
      'sko',
      'vin',
      'blomst',
    ],
  ];
  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _ttsService.init();
    await _sttService.init();
  }

  // PLAY ALL WORDS SEQUENTIALLY
  Future<void> _playAllWords() async {
    if (_speaking) return;

    setState(() {
      _speaking = true;
      _listening = false;
      _ttsFinished = false;
      _recognizedText = '';
    });

    for (final word in wordLists[_currentListIndex]) {
      await _ttsService.speak(word);
      await Future.delayed(const Duration(milliseconds: 800));
    }

    setState(() {
      _speaking = false;
      _ttsFinished = true; // now user may speak
    });
  }

  // START LISTENING
  Future<void> _startListening() async {
    if (!_sttService.isListening) {
      setState(() {
        _listening = true;
        _speaking = false;
        _ttsFinished = false;

        _recognizedText = '';
        _timeRemaining = 20;
      });

      _startListeningTimer();

      await _sttService.startListening(
        onPartialResult: (text) {
          setState(() {
            _recognizedText = text;
          });
        },
        onFinalResult: (text) {
          setState(() {
            _recognizedText = text;
          });
        },
        durationSeconds: 20,
      );
    }
  }

  // START TIMER FOR LISTENING
  void _startListeningTimer() {
    _listeningTimer?.cancel();
    _listeningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          timer.cancel();
          _stopListening();
        }
      });
    });
  }

  // STOP LISTENING
  Future<void> _stopListening() async {
    if (_sttService.isListening) {
      await _sttService.stopListening();
    }

    _listeningTimer?.cancel();

    if (!mounted) return;

    setState(() => _listening = false);

    // Move to next list or finish
    if (_currentListIndex < wordLists.length - 1) {
      _finalizedText = _finalizedText + _recognizedText;
      await Future.delayed(const Duration(milliseconds: 500));
      _moveToNextList();
    } else {
      _finalizedText = _finalizedText + _recognizedText;

      await Future.delayed(const Duration(milliseconds: 500));
      await _finishStudy();
    }
  }

  void _moveToNextList() {
    setState(() {
      _currentListIndex++;
      _ttsFinished = false;
      _recognizedText = '';
    });
  }

  Future<void> _finishStudy() async {
    // Save results if needed
    print(' 🔁🔁🔁!!!!!!Study completed! Final text: $_finalizedText');

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _sttService.dispose();
    _ttsService.dispose();
    _listeningTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FB),
        appBar: AppBar(
          title: const Text('Word  Study'),
          backgroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Instruction
              const Text(
                'Listen carefully and repeat all the words you hear.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 32),

              // Progress indicator
              Text(
                'List ${_currentListIndex + 1} of ${wordLists.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 20),

              // Current words display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  wordLists[_currentListIndex].join(', '),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Microphone indicator
              _buildMicIndicator(),

              const SizedBox(height: 16),

              // Listening status
              if (_listening)
                Column(
                  children: [
                    const Text(
                      '🎤 Listening...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Time remaining: ${_timeRemaining}s',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // Recognized words chips
              if (_recognizedText.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: _recognizedText
                      .split(RegExp(r'\s+'))
                      .where((w) => w.isNotEmpty)
                      .map(
                        (w) => Chip(
                          label: Text(w, style: const TextStyle(fontSize: 14)),
                          backgroundColor: Colors.blue.shade50,
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),

              const Spacer(),

              // Button controls
              Column(
                children: [
                  // 1. Play Words button (before TTS starts)
                  if (!_speaking &&
                      !_listening &&
                      !_ttsFinished &&
                      _recognizedText.isEmpty)
                    ElevatedButton.icon(
                      onPressed: _playAllWords,
                      icon: const Icon(Icons.volume_up, size: 20),
                      label: const Text(
                        'Play Words',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  // 2. Playing indicator
                  if (_speaking)
                    ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.volume_up, size: 20),
                      label: const Text(
                        'Playing...',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  // 3. Speak button (after TTS finishes)
                  if (_ttsFinished && !_listening)
                    ElevatedButton.icon(
                      onPressed: _startListening,
                      icon: const Icon(Icons.mic, size: 20),
                      label: const Text(
                        'Speak',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // 4. Stop button (during listening)
                  if (_listening)
                    ElevatedButton.icon(
                      onPressed: _stopListening,
                      icon: const Icon(Icons.stop, size: 20),
                      label: const Text(
                        'Stop & Continue',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  // 5. Next button (after listening)
                  if (!_listening &&
                      _recognizedText.isNotEmpty &&
                      _currentListIndex < wordLists.length - 1)
                    ElevatedButton(
                      onPressed: _moveToNextList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Next List',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                  // 6. Finish button (last list)
                  if (!_listening &&
                      _recognizedText.isNotEmpty &&
                      _currentListIndex == wordLists.length - 1)
                    ElevatedButton(
                      onPressed: _finishStudy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Finish Study',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _listening ? 80 : 60,
      height: _listening ? 80 : 60,
      decoration: BoxDecoration(
        color: _listening ? Colors.blueAccent : Colors.grey.shade400,
        shape: BoxShape.circle,
        boxShadow: _listening
            ? [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ]
            : [],
      ),
      child: const Icon(Icons.mic, color: Colors.white, size: 32),
    );
  }
}
