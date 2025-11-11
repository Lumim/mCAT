import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class WordTaskIntroScreen extends StatefulWidget {
  final VoidCallback onNext;
  const WordTaskIntroScreen({super.key, required this.onNext});

  @override
  State<WordTaskIntroScreen> createState() => _WordTaskIntroScreenState();
}

class _WordTaskIntroScreenState extends State<WordTaskIntroScreen> {
  bool _showSecond = false;
  AudioPlayer? _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _player!.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player!.play(AssetSource('sounds/face_1.mp3'));
      setState(() => _isPlaying = true);
      _player!.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Word Task', activeStep: 2),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child:
            !_showSecond ? _buildIntro(context) : _buildInstructions(context),
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    return Padding(
      key: const ValueKey('intro'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text('Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _infoCard(
            'This is a test where you’ll hear a series of words. '
            'Repeat each word clearly into the microphone when prompted.',
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Next',
            onPressed: () => setState(() => _showSecond = true),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Padding(
      key: const ValueKey('instructions'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text('Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _infoCard(
            'When you’re ready, press “Start Assessment”. '
            'You’ll hear a list of words—repeat each one aloud. '
            'Your responses will be analyzed using speech recognition.',
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _toggleAudio,
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: Colors.blue,
              size: 28,
            ),
            label: Text(
              _isPlaying ? 'Pause audio' : 'Hear instructions',
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Start Assessment',
            onPressed: widget.onNext,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, height: 1.4)),
    );
  }
}
