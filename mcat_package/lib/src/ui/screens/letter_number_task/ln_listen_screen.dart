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
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await _stt.init();
    // print('the number is: ${widget.toString()}');
    setState(() {
      listening = true;
      recognized = '';
    });

    // This await might complete BEFORE you create the safety timer
    await _stt.startListening(
      durationSeconds: 10,
      onPartialResult: (text) {
        if (!mounted) return;
        setState(() => recognized = text);
      },
      onFinalResult: (finalText) async {
        if (!mounted) return;
        setState(() {
          recognized = finalText;
          listening = false;
        });
        await _finishAndRoute(); // This stops everything
      },
    );

    // Safety timer is created AFTER stt.startListening might have already finished

    _safetyTimer = Timer(const Duration(seconds: 11), () async {
      if (!mounted) return;
      await _finishAndRoute();
    });
  }

  Future<void> _finishAndRoute() async {
    _safetyTimer?.cancel();
    await _stt.stopListening();

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
      '/ln-input', // hyphen route
      arguments: widget.controller,
    );
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _stt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.controller.current;
    final number = (round.numberSeq.isNotEmpty) ? round.numberSeq.last : 100;

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
                  '${widget.controller.current.numberSeq.join('')}',
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
                  ? '🎤 Listening ${_safetyTimer?.tick ?? 0} seconds... the number starts from ${widget.controller.current.numberSeq.join(',')}'
                  : 'Recognized: ${recognized.isEmpty ? "(none)" : recognized}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
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
