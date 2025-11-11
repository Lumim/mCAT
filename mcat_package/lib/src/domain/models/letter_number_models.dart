import 'package:flutter/foundation.dart';
import 'dart:math';

class LnRound {
  final List<int> numberSeq;
  final List<String> letterSeq;

  LnRound({required this.numberSeq, required this.letterSeq});

  /// Factory method to generate random sequences for testing/demo
  factory LnRound.generate({
    required int level,
    required int digits,
    required int letters,
  }) {
    final rand = Random();
    final numberSeq = List<int>.generate(digits, (_) => rand.nextInt(9) + 1);
    final letterSeq = List<String>.generate(
      letters,
      (_) => String.fromCharCode(rand.nextInt(26) + 65), // A–Z
    );
    return LnRound(numberSeq: numberSeq, letterSeq: letterSeq);
  }
}

class LnController extends ChangeNotifier {
  final List<LnRound> _rounds;
  int _roundIndex = 0;

  LnController(this._rounds);

  LnRound get current => _rounds[_roundIndex];
  int get roundIndex => _roundIndex;
  bool get isLast => _roundIndex == _rounds.length - 1;

  void nextRound() {
    if (!isLast) {
      _roundIndex++;
      notifyListeners();
    }
  }

  void reset() {
    _roundIndex = 0;
    notifyListeners();
  }
}
