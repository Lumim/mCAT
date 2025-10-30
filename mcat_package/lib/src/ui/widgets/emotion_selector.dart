import 'package:flutter/material.dart';
import '../../domain/models/emotion.dart';

/// A reusable widget that displays all emotion options vertically,
/// styled with icons, colors, and selection highlighting.
///
/// [selected] → the currently selected emotion (if any)
/// [onSelect] → callback fired when a user taps an emotion.
class EmotionSelector extends StatelessWidget {
  final Emotion? selected;
  final void Function(Emotion emotion) onSelect;

  const EmotionSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('emotion_selector'),
      children: Emotion.values.map((e) {
        final isSelected = selected == e;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(e.icon, color: e.color, size: 26),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                e.label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  isSelected ? e.color.withOpacity(0.15) : Colors.white,
              side: BorderSide(
                color: isSelected ? e.color : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => onSelect(e),
          ),
        );
      }).toList(),
    );
  }
}
