import 'dart:math';

/// One stimulus: N letters (A–Z) + one number with D digits.
class LetterNumberItem {
  final List<String> letters; // e.g. ['A','B','C']
  final int number; // e.g. 29

  const LetterNumberItem({required this.letters, required this.number});

  /// Accept typed letters in any order (letters only, case-insensitive).
  bool matchesInput(String input) {
    final norm = input.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final typed = norm.split('')..sort();
    final target = [...letters]..sort();
    return typed.join() == target.join();
  }
}

/// Round specification: how many letters and how many digits for the number.
class LnRoundSpec {
  final int lettersCount;
  final int digitsCount;
  const LnRoundSpec(this.lettersCount, this.digitsCount);
}

/// Flow/state controller shared across screens in the task.
class LnController {
  final List<LnRoundSpec> rounds;
  final _rand = Random();

  int roundIndex = 0;
  int correct = 0;
  LetterNumberItem? current;

  LnController(this.rounds); // Remove the incorrect line below this

  bool get isFirst => roundIndex == 0;
  bool get isLast => roundIndex == rounds.length - 1;

  /// Generate a fresh item for the current round.
  LetterNumberItem generate() {
    final spec = rounds[roundIndex];
    final letters = List.generate(
      spec.lettersCount,
      (_) => String.fromCharCode(_rand.nextInt(26) + 65),
    );
    final max = pow(10, spec.digitsCount).toInt();
    final min = pow(10, spec.digitsCount - 1).toInt();
    final number = spec.digitsCount == 1
        ? _rand.nextInt(10)
        : _rand.nextInt(max - min) + min;
    current = LetterNumberItem(letters: letters, number: number);
    return current!;
  }

  /// Score typed letters; advance to next round if any.
  void submitLetters(String typed) {
    if (current == null) return;
    if (current!.matchesInput(typed)) correct++;
  }

  void nextRound() {
    if (!isLast) roundIndex++;
  }

  int get total => rounds.length;
}