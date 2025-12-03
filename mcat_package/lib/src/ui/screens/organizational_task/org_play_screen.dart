import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../../domain/models/organizational_models.dart';
import 'package:mcat_package/src/services/tts_service.dart';

class OrgPlayScreen extends StatefulWidget {
  final OrgController controller;
  const OrgPlayScreen({super.key, required this.controller});

  @override
  State<OrgPlayScreen> createState() => _OrgPlayScreenState();
}

class _OrgPlayScreenState extends State<OrgPlayScreen> {
  final TtsService _tts = TtsService();
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    setState(() => _speaking = true);
    await _tts.speak(widget.controller.current.ttsPhrase);
    // small pause feels natural
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final roundNo = widget.controller.roundIndex + 1;
    final total = widget.controller.totalRounds;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(title: 'Organizational Task– $roundNo', activeStep: 4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Tap Play to hear the sequence:',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            /*    Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.controller.current.ttsPhrase,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ), */
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _speaking ? null : _play,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFFFFF),
                      backgroundColor: const Color(0xFF006BA6),
                    ),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Play'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, '/org_input',
                  arguments: widget.controller),
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFFFFFFF),
                backgroundColor: const Color(0xFF006BA6),
              ),
              child: const Text('Start Typing'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
