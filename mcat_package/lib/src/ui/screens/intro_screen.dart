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
  //bool _showInstructions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Welcome to mCAT'),
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
          child: _buildIntro(context, key: const ValueKey('intro'))),
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
            onPressed: widget.onStart,
          ),
        ],
      ),
    );
  }
}
