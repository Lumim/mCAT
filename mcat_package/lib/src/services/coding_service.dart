import 'dart:math';
import '../domain/models/coding_task_models.dart';

class CodingService {
  static final _rand = Random();

  static const List<CodePair> baseSet = [
    CodePair(code: 'o**', letter: 'K'),
    CodePair(code: 'o*o', letter: 'B'),
    CodePair(code: '**o', letter: 'C'),
    CodePair(code: '*o*', letter: 'F'),
    CodePair(code: '*oo', letter: 'H'),
  ];

  static List<CodePair> generateSequence(int n) =>
      List.generate(n, (_) => baseSet[_rand.nextInt(baseSet.length)]);
}
