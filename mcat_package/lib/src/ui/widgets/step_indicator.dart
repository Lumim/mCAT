import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int activeIndex;
  final int total;
  const StepIndicator({
    super.key,
    required this.activeIndex,
    this.total = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final step = i + 1;
          final isActive = step == activeIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CircleAvatar(
              radius: 10,
              backgroundColor:
                  isActive ? Colors.blue : Colors.blue.withOpacity(0.3),
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
