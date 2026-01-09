import 'dart:math';
import 'package:flutter/foundation.dart';

class OrgRound {
  final List<int> numbers; // mixed
  final List<String> letters;

  var stimuliElements; // mixed

  OrgRound({required this.numbers, required this.letters});

  /// The “correct” answer: numbers ascending, then letters alphabetically.
  String get correctAnswer {
    final sortedNums = [...numbers]..sort();
    final sortedLetters = [...letters]..sort((a, b) => a.compareTo(b));
    final numPart = sortedNums.join();
    final letterPart = sortedLetters.join();
    return '$numPart$letterPart'.toUpperCase();
  }

  /// Sentence to play via TTS: e.g., "9, B, 2, D, 1, A"
  String get ttsPhrase {
    final mixed = <String>[];
    final len = max(numbers.length, letters.length);
    for (var i = 0; i < len; i++) {
      if (i < numbers.length) mixed.add(numbers[i].toString());
      if (i < letters.length) mixed.add(letters[i]);
    }
    return mixed.join(', ');
  }

  /// For demos/tests – generate random round
  factory OrgRound.generate({required int digits, required int letters}) {
    final r = Random();
    final nums = List<int>.generate(digits, (_) => r.nextInt(9) + 1);
    final lets = List<String>.generate(
      letters,
      (_) => String.fromCharCode(r.nextInt(26) + 65),
    );
    // Shuffle independently to ensure “mixed” feel
    nums.shuffle(r);
    lets.shuffle(r);
    return OrgRound(numbers: nums, letters: lets);
  }
}

class OrgController extends ChangeNotifier {
  final List<OrgRound> _rounds;
  int _index = 0;
  int _correct = 0;

  OrgController(this._rounds);

  OrgRound get current => _rounds[_index];
  int get roundIndex => _index; // 0-based
  int get totalRounds => _rounds.length;
  bool get isLast => _index == _rounds.length - 1;
  int get correctCount => _correct;

  void recordCorrect(bool isCorrect) {
    if (isCorrect) _correct++;
    notifyListeners();
  }

  void nextRound() {
    if (!isLast) {
      _index++;
      notifyListeners();
    }
  }

  void resetForPractice() {
    // Reset any state variables needed for practice
    _index = 0;
    _correct = 0;
    // You might want to set a specific practice round
    // or create a separate practice sequence
  }

  void reset() {
    _index = 0;
    _correct = 0;
    notifyListeners();
  }
}
