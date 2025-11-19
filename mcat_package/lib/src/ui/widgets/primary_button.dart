import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final filledStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF006BA6),
      foregroundColor: const Color(0xFFFFFFFF), // blue
      shape: const StadiumBorder(), // pill shape
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 32,
      ),
      textStyle: const TextStyle(fontSize: 14),
    );
    const Spacer(flex: 8);
    final outlinedStyle = OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFFFFFFF),
      side: const BorderSide(color: Color(0xFFFFFFFF)),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 32,
      ),
      textStyle: const TextStyle(fontSize: 14),
    );

    if (filled) {
      return ElevatedButton(
        onPressed: onPressed,
        style: filledStyle,
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: outlinedStyle,
      child: Text(label),
    );
  }
}
