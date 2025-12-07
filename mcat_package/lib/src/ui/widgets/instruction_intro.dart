import 'package:flutter/material.dart';
import 'primary_button.dart';

/// {@template instruction_intro}
/// InstructionIntro widget.
/// {@endtemplate}
class InstructionIntro extends StatelessWidget {
  /// {@macro instruction_intro}
  const InstructionIntro({
    super.key,
    // ignore: unused_element_parameter
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'A brief evaluation of cognitive abilities and mental health.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
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
            label: 'Ready',
            onPressed: () {
              Navigator.of(context).pop();
            },
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
