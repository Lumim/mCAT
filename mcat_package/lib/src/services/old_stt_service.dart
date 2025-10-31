import 'package:speech_to_text/speech_to_text.dart' as stt;

class SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isReady = false;

  Future<bool> init() async {
    _isReady = await _speech.initialize(
      onError: (e) => print('❌ STT error: $e'),
      onStatus: (s) => print('🎤 STT status: $s'),
    );
    return _isReady;
  }

  /// Continuous listening with live updates
  Future<void> startListening({required Function(String) onResult}) async {
    if (!_isReady) await init();

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: 'en_US',
      partialResults: true,
      listenMode: stt.ListenMode.dictation, //  keeps mic open for pauses
      listenFor: const Duration(seconds:30), //  total listening time
      pauseFor: const Duration(seconds: 5),   // allow small pauses
    );
  }

  Future<void> stopListening() async => _speech.stop();
  void dispose() => _speech.stop();
}

