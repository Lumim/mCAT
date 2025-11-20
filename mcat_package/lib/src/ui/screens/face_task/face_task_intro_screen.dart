import 'package:flutter/material.dart';
import 'package:mcat_package/src/services/tts_service.dart';
//import 'package:audioplayers/audioplayers.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/header_bar.dart';

class FaceTaskIntroScreen extends StatefulWidget {
  final VoidCallback onNext;
  const FaceTaskIntroScreen({super.key, required this.onNext});

  @override
  State<FaceTaskIntroScreen> createState() => _FaceTaskIntroScreenState();
}

class _FaceTaskIntroScreenState extends State<FaceTaskIntroScreen> {
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
    _isPlaying
        ? await _tts.speak(
            'This will be the practice for face task. There will be 2 faces for practicing the task.'
            'First, you will be given the option to do a practice round where you can try the test before starting the real round. When you are ready to start the practice round, you can press “start” and you will be shown the first image. Next, tap on the feeling you see in the image. Once you have tapped an emotion, get ready for the next image.')
        : _tts.dispose();
    // small pause feels natural
    await Future.delayed(const Duration(milliseconds: 400));
    // if (mounted) setState(() => _isPlaying = false);
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
      appBar: const HeaderBar(title: 'Face Task', activeStep: 1),
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
          _infoCard(
            'This will be the practice for face task. There will be\n2 faces for practicing the task.',
          ),
          const SizedBox(height: 16),
          _infoCard(
            'First, you will be given the option to do a practice round '
            'where you can try the test before starting the real round.',
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
        _infoCard(
          'When you are ready to start the practice round, you can press '
          '“start” and you will be shown the first image. Next, tap on the feeling '
          'you see in the image. Once you have tapped an emotion, get ready for the next image.',
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
      ]),
    );
  }

  Widget _infoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, height: 1.4),
        textAlign: TextAlign.center,
      ),
    );
  }
}
