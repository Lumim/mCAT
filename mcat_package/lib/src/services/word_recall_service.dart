import 'dart:math';

class WordRecallService {
  /// Cleans and splits recognized text into lowercase words.
  static List<String> extractWords(String text) {
    final clean = text.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), ' ');
    return clean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }

  /// Returns how many recalled words match the original list (case-insensitive)
  static int scoreRecall(List<String> spoken, List<String> targetList) {
    final targetSet = targetList.map((e) => e.toLowerCase()).toSet();
    final spokenSet = spoken.map((e) => e.toLowerCase()).toSet();
    return spokenSet.intersection(targetSet).length;
  }

  /// Simulates saved word list (replace with DB or provider)
  static List<String> getOriginalWordList() => [
        'mountain',
        'city',
        'snowman',
        'coffee',
        'airport',
        'book',
        'cartoon',
        'sky',
        'garden',
        'house',
      ];

  /// Random shuffle for recall difficulty (optional)
  static List<String> shuffled() {
    final list = List<String>.from(getOriginalWordList());
    list.shuffle(Random());
    return list;
  }
}
