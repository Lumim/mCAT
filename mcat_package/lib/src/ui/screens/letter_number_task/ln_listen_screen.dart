import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/step_indicator.dart';
import '../../../domain/models/letter_number_models.dart';

class LnListenScreen extends StatefulWidget {
  final LnController controller;
  final VoidCallback onDoneCounting; // navigate to input screen
  const LnListenScreen({
    super.key,
    required this.controller,
    required this.onDoneCounting,
  });

  @override
  State<LnListenScreen> createState() => _LnListenScreenState();
}

class _LnListenScreenState extends State<LnListenScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Give user time to count backwards (UI only; plug in STT if you want to capture)
    _timer = Timer(const Duration(seconds: 8), widget.onDoneCounting);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.controller.current!.number;
    final round = widget.controller.roundIndex + 1;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(
        title: 'Letter Number Task (Round $round)',
        activeStep: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 28),
            const Text(
              'Now, please count backwards from',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '$n',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.mic, color: Colors.blue, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Listening',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
