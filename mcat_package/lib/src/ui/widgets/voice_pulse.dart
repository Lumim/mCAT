import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // add to pubspec.yaml

class VoicePulse extends StatelessWidget {
  const VoicePulse({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Pulse(
        infinite: true,
        duration: const Duration(milliseconds: 800),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.2),
            shape: BoxShape.rectangle,
          ),
          child: const Icon(Icons.mic, size: 38, color: Colors.redAccent),
        ),
      ),
    );
  }
}
