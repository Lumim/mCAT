import 'package:flutter/material.dart';

/// Represents the possible emotions shown during the Face Task.
enum Emotion {
  surprise,
  happy,
  neutral,
  sad,
  fear,
  angry,
  disgust,
  // fearful,
}

/// Extension adding labels, colors, and icons for each [Emotion].
extension EmotionX on Emotion {
  /// Display name used in UI.
  String get label => switch (this) {
        Emotion.surprise => 'Surprise',
        Emotion.happy => 'Happy',
        Emotion.neutral => 'Neutral',
        Emotion.sad => 'Sad',
        // Emotion.fearful => 'Fear',
        Emotion.fear => 'Fear',
        Emotion.angry => 'Angry',
        Emotion.disgust => 'Disgust',
        // TODO: Handle this case.
      };

  /// Color representing each emotion.
  Color get color => switch (this) {
        Emotion.surprise => Colors.lightGreenAccent.shade400,
        Emotion.happy => Colors.green.shade400,
        Emotion.neutral => Colors.amber.shade300,
        Emotion.sad => Colors.redAccent.shade200,
        Emotion.fear => Colors.pinkAccent.shade100,
        Emotion.angry => Colors.brown.shade400,
        Emotion.disgust => Colors.grey.shade600,
      };

  /// Icon associated with each emotion.
  IconData get icon => switch (this) {
        Emotion.surprise => Icons.sentiment_very_satisfied_rounded,
        Emotion.happy => Icons.emoji_emotions_rounded,
        Emotion.neutral => Icons.sentiment_neutral_rounded,
        Emotion.sad => Icons.sentiment_dissatisfied_rounded,
        Emotion.fear => Icons.mood_bad_rounded,
        Emotion.angry => Icons.sentiment_very_dissatisfied_rounded,
        Emotion.disgust => Icons.sick_rounded,
      };
}
