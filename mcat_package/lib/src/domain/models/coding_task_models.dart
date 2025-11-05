class CodePair {
  final String code;
  final String letter;
  const CodePair({required this.code, required this.letter});
}

class CodingResult {
  final int correct;
  final int total;
  final double accuracy;
  final int timeTakenMs;

  const CodingResult({
    required this.correct,
    required this.total,
    required this.accuracy,
    required this.timeTakenMs,
  });

  Map<String, dynamic> toJson() => {
        'correct': correct,
        'total': total,
        'accuracy': accuracy,
        'timeTakenMs': timeTakenMs,
      };
}
