import 'dart:async';
import 'package:flutter/material.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../widgets/header_bar.dart';
import 'package:mcat_package/src/services/stt_service.dart';
import 'package:mcat_package/src/services/data_service.dart';

class LnListenScreen extends StatefulWidget {
  final LnController controller;
  const LnListenScreen({super.key, required this.controller});

  @override
  State<LnListenScreen> createState() => _LnListenScreenState();
}

class _LnListenScreenState extends State<LnListenScreen> {
  final SttService _stt = SttService();
  String recognized = '';
  bool listening = false;
  Timer? _timer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _stt.init();
    _startListening();
  }

  Future<void> _startListening() async {
    setState(() {
      listening = true;
      recognized = '';
      _completed = false;
    });

    _startTimer();

    await _stt.startListening(
      durationSeconds: 10,
      onPartialResult: (text) {
        if (!mounted) return;
        setState(() => recognized = text);
      },
      onFinalResult: (finalText) {
        if (!mounted) return;
        setState(() => recognized = finalText);
        // Don't auto-navigate on final result, let timer handle it
      },
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 10), _onTimerComplete);
    print('Timer started for 15 seconds...');
  }

  void _onTimerComplete() {
    print('Timer completed. Forcing navigation...');
    _forceCompleteSession();
  }

  Future<void> _forceCompleteSession() async {
    if (_completed) return;
    _completed = true;

    // Cancel timer first
    _timer?.cancel();

    // Dispose the STT service completely to prevent restarts
    _stt.dispose();

    if (mounted) {
      setState(() => listening = false);
    }

    // Persist this round
    await DataService().saveTask('ln_listen', {
      'round': widget.controller.roundIndex + 1,
      'recognized': recognized,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Move to next round or result
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/ln_input',
      arguments: widget.controller,
    );
  }

  List<String> _splitWords(String text) {
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (!_completed) {
      _stt.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roundNo = widget.controller.roundIndex + 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(title: 'LN – Round $roundNo', activeStep: 3),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Please count backwards from the number below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
                child: Text(
                  widget.controller.current.numberSeq.join(''),
                  style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
              ),
            ),
            const SizedBox(height: 28),
            _micIndicator(),
            const SizedBox(height: 16),
            Text(
              listening
                  ? 'Listening'
                  : 'Recognized:${recognized.isEmpty && !listening ? "(none)" : ""}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (recognized.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _splitWords(recognized)
                    .map(
                      (word) => Chip(
                        label: Text(word),
                        backgroundColor: Colors.blue.shade50,
                      ),
                    )
                    .toList(),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _micIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: listening ? 80 : 60,
      height: listening ? 80 : 60,
      decoration: BoxDecoration(
        color: listening ? Colors.blueAccent : Colors.grey.shade400,
        shape: BoxShape.circle,
        boxShadow: [
          if (listening)
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 10,
            ),
        ],
      ),
      child: const Icon(Icons.mic, color: Colors.white, size: 36),
    );
  }
}
