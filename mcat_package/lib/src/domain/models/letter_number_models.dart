import 'dart:math';

/// Represents one Letter–Number round
class LnRound {
  final int level;
  final int digits;
  final int letters;
  final List<int> numberSeq;
  final List<String> letterSeq;

  LnRound({
    required this.level,
    required this.digits,
    required this.letters,
    required this.numberSeq,
    required this.letterSeq,
  });

  factory LnRound.generate({
    required int level,
    required int digits,
    required int letters,
  }) {
    final rand = Random();
    final nums = List.generate(digits, (_) => rand.nextInt(9) + 1);
    final lets = List.generate(
      letters,
      (_) => String.fromCharCode(rand.nextInt(26) + 65),
    );
    return LnRound(
      level: level,
      digits: digits,
      letters: letters,
      numberSeq: nums,
      letterSeq: lets,
    );
  }
}

/// Controls all Letter–Number rounds
class LnController {
  final List<LnRound> rounds;
  int roundIndex = 0;
  int correct = 0;
  int total = 0;

  LnController(this.rounds);

  static List<LnRound> generateRounds() {
    return [
      LnRound.generate(level: 1, digits: 2, letters: 2),
      LnRound.generate(level: 2, digits: 3, letters: 3),
      LnRound.generate(level: 3, digits: 4, letters: 3),
    ];
  }

  LnRound? get current => (roundIndex >= 0 && roundIndex < rounds.length)
      ? rounds[roundIndex]
      : null;

  bool get isLast => roundIndex >= rounds.length - 1;

  void nextRound() {
    if (!isLast) roundIndex++;
  }

  void addScore({required int correctThisRound, required int totalThisRound}) {
    correct += correctThisRound;
    total += totalThisRound;
  }

  /// Dummy placeholder so old references don’t break
  void submitLetters(String text) {}
}
