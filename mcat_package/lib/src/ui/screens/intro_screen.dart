import 'package:flutter/material.dart';
import '../../domain/models/mcat_task.dart';
import '../widgets/primary_button.dart';
import '../../services/asset_provider.dart';
import '../widgets/header_bar.dart';

class IntroScreen extends StatefulWidget {
  final VoidCallback? onStart;
  final List<McatTask> tasks;

  const IntroScreen({
    super.key,
    required this.onStart,
    required this.tasks,
  });

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _showInstructions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Welcome', activeStep: 1),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: !_showInstructions
            ? _buildIntro(context, key: const ValueKey('intro'))
            : _buildInstructions(context, key: const ValueKey('instructions')),
      ),
    );
  }

  Widget _buildIntro(BuildContext context, {Key? key}) {
    final assets = ServiceLocator.assetProvider;

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(
            assets.logo,
            package: 'mcat_package',
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
          const Text(
            'A smartphone based battery for cognitive assessment',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Start',
            onPressed: () {
              setState(() => _showInstructions = true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instructions',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'A brief evaluation of cognitive abilities and mental health.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                _buildBullet(
                  Icons.block,
                  'You cannot pause mCAT tasks, so please visit the toilet now if needed',
                ),
                const SizedBox(height: 12),
                _buildBullet(
                  Icons.volume_off_outlined,
                  'Sit in a quiet room.',
                ),
                const SizedBox(height: 12),
                _buildBullet(
                  Icons.meeting_room_outlined,
                  'Close the door to avoid distractions.',
                ),
              ],
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Start Assessment',
            onPressed: widget.onStart,
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.black87),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
