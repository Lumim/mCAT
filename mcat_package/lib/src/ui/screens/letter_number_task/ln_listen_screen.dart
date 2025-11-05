import 'dart:async';
import 'package:flutter/material.dart';
import '../../../domain/models/letter_number_models.dart';
import '../../widgets/header_bar.dart';
import 'package:mcat_package/src/services/stt_service.dart';
import 'package:mcat_package/src/services/data_service.dart';

class LnListenScreen extends StatefulWidget {
  final LnController controller;
  final VoidCallback onDoneCounting;

  const LnListenScreen({
    super.key,
    required this.controller,
    required this.onDoneCounting,
  });

  @override
  State<LnListenScreen> createState() => _LnListenScreenState();
}

class _LnListenScreenState extends State<LnListenScreen> {
  final SttService _stt = SttService();
  String recognized = '';
  bool listening = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  Future<void> _startListening() async {
    setState(() => listening = true);

    await _stt.startListening(
      onPartialResult: (text) {
        setState(() => recognized = text);
      },
      onFinalResult: (finalText) {
        // Triggered when user pauses for a few seconds or stops manually
        setState(() {
          recognized = finalText;
          listening = false;
        });
        debugPrint('🎤 Final recognized text: $finalText');
      },
    );
  }

  /// Stop the listening session
  Future<void> _stop() async {
    await _stt.stopListening();
    setState(() => listening = false);
  }

  Future<void> _stopListening() async {
    await _stt.stopListening();
    setState(() => listening = false);

    // Save local + Firebase
    await DataService().saveTask('ln_listen', {
      'recognized': recognized,
      'timestamp': DateTime.now().toIso8601String(),
    });

    widget.onDoneCounting();
  }

  @override
  void dispose() {
    _stt.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LnRound? round = widget.controller.current;
    final number =
        (round?.numberSeq.isNotEmpty ?? false) ? round!.numberSeq.last : 0;
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
                  '$number',
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
                  ? 'Listening...'
                  : 'Recognized: ${recognized.isEmpty ? "(none)" : recognized}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
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
