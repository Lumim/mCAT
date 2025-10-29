import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/header_bar.dart';

class FaceTaskIntroScreen extends StatefulWidget {
  final VoidCallback onNext;
  const FaceTaskIntroScreen({super.key, required this.onNext});

  @override
  State<FaceTaskIntroScreen> createState() => _FaceTaskIntroScreenState();
}

class _FaceTaskIntroScreenState extends State<FaceTaskIntroScreen> {
  bool _showSecond = false;

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
          const Spacer(),
          PrimaryButton(
            label: 'Next',
            onPressed: () => setState(() => _showSecond = true),
          ),
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
          _infoCard(
            'When you are ready to start the practice round, you can press '
            '“start” and you will be shown the first image. Next, tap on the feeling '
            'you see in the image. Once you have tapped an emotion, get ready for the next image.',
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              // TODO: add play audio logic later
            },
            icon: const Icon(Icons.play_circle_fill, color: Colors.blue),
            label: const Text(
              'Hear instructions',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, height: 1.4),
        textAlign: TextAlign.center,
      ),
    );
  }
}
