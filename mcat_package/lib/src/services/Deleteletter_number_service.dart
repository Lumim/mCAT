/* import '../domain/models/letter_number_models.dart';
import 'tts_service.dart';

class LetterNumberService {
  /// Updated rounds to match your 3-level requirement:
  /// 1) 2 letters, 1 digit (5-9)
  /// 2) 3 letters, 2 digits
  /// 3) 4 letters, 3 digits
  static List<LnRoundSpec> defaultRounds() => const [
        LnRoundSpec(2, 1), // Level 1: 2 letters + 1-digit number (5-9)
        LnRoundSpec(3, 2), // Level 2: 3 letters + 2-digit number
        LnRoundSpec(4, 3), // Level 3: 4 letters + 3-digit number
      ];

  static String lettersHuman(List<String> ls) => ls.join(', ');

  /// Speaks "A, B, C ... 29" with small gaps.
  static Future<void> playSequence(
    TtsService tts,
    LnItem item, // Changed from LetterNumberItem to LnItem
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

  /// Alternative method that takes LnController and plays current item
  static Future<void> playCurrentSequence(
    TtsService tts,
    LnController controller,
  ) async {
    if (controller.current == null) {
      throw StateError('No current item in controller');
    }
    await playSequence(tts, controller.current!);
  }
}
 */
