class WordRecallResult {
  final List<String> recalledWords;
  final int correctCount;
  final int total;

  const WordRecallResult({
    required this.recalledWords,
    required this.correctCount,
    required this.total,
  });
}
