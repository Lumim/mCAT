import 'package:flutter/material.dart';
import 'package:mcat_package/src/services/tts_service.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/infocard.dart';
import '../../widgets/primary_button.dart';

class WordTaskIntroScreen extends StatefulWidget {
  final VoidCallback onNext;
  const WordTaskIntroScreen({super.key, required this.onNext});

  @override
  State<WordTaskIntroScreen> createState() => _WordTaskIntroScreenState();
}

class _WordTaskIntroScreenState extends State<WordTaskIntroScreen> {
  bool _showSecond = false;
  final TtsService _tts = TtsService();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  Future<void> _togglePlay() async {
    !_isPlaying
        ? setState(() => _isPlaying = true)
        : setState(() => _isPlaying = false);
    
    if (_isPlaying) {
      final String fullText = !_showSecond
          ? 'This is a test where you’ll hear a series of words. '
            'Repeat each word clearly into the microphone when prompted.'
          : 'When you’re ready, press "Start Assessment". '
            'You’ll hear a list of words—repeat each one aloud. '
            'Your responses will be analyzed using speech recognition.';
      
      await _tts.speak(fullText);
    } else {
      _tts.dispose();
    }
    
    // small pause feels natural
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    if (mounted) setState(() => _isPlaying = false);
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Word Task', activeStep: 2),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: !_showSecond
            ? _buildFirstScreen(context, key: const ValueKey('first'))
            : _buildSecondScreen(context, key: const ValueKey('second')),
      ),
    );
  }

  Widget _buildFirstScreen(BuildContext context, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            text: 'This is a test where you’ll hear a series of words. '
                  'Repeat each word clearly into the microphone when prompted.',
            fontSize: 16,
          ),
          const Spacer(flex: 12),
          PrimaryButton(
            label: 'Next',
            onPressed: () => setState(() => _showSecond = true),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildSecondScreen(BuildContext context, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            text: 'When you\'re ready, press "Start Assessment". '
                  'You\'ll hear a list of words—repeat each one aloud. '
                  'Your responses will be analyzed using speech recognition.',
            fontSize: 16,
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _togglePlay,
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: Colors.blue,
              size: 28,
            ),
            label: Text(
              _isPlaying ? 'Playing' : 'Hear instructions',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(flex: 16),
          !_isPlaying
              ? PrimaryButton(
                  label: 'Start Assessment',
                  onPressed: widget.onNext,
                )
              : const SizedBox.shrink(),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}