import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Handles speech-to-text (STT) recognition.
class SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  /// Initialize speech recognition.
  Future<bool> init() async {
    return await _speech.initialize();
  }

  /// Start listening with live updates.
  Future<void> startListening({required Function(String) onResult}) async {
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
    );
  }

  /// Stop listening manually.
  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// Simple one-shot listening used by practice mode.
  Future<String> listenOnce() async {
    String recognized = '';
    await _speech.listen(onResult: (result) {
      recognized = result.recognizedWords;
    });
    await Future.delayed(const Duration(seconds: 3));
    await _speech.stop();
    return recognized;
  }

  /// Dispose of resources.
  void dispose() {
    _speech.stop();
  }
}
