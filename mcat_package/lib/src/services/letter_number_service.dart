import '../domain/models/letter_number_models.dart';
import 'tts_service.dart';

class LetterNumberService {
  /// Official 3 repetitions + your final pattern:
  /// 1) 1 letter, 1 digit
  /// 2) 2 letters, 2 digits
  /// 3) 3 letters, 3 digits
  /// 4) 4 letters, 3 digits   (your “3 digit but 4 letters” requirement)
  static List<LnRoundSpec> defaultRounds() => const [
    LnRoundSpec(1, 1),
    LnRoundSpec(2, 2),
    LnRoundSpec(3, 3),
    LnRoundSpec(4, 3),
  ];

  static String lettersHuman(List<String> ls) => ls.join(', ');

  /// Speaks "A, B, C ... 29" with small gaps.
  static Future<void> playSequence(
    TtsService tts,
    LetterNumberItem item,
  ) async {
    // Speak letters one by one
    for (final l in item.letters) {
      await tts.speak(l);
      await Future.delayed(const Duration(milliseconds: 500));
    }
    // Short pause then speak the number
    await Future.delayed(const Duration(milliseconds: 600));
    await tts.speak(item.number.toString());
  }
}
