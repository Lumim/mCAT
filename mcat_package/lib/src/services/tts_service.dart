import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    print('✅ TTS initialized');
  }

  // Add completion handler support
  void setCompletionHandler(Function handler) {
    _tts.setCompletionHandler(() {
      handler();
    });
  }

  void setErrorHandler(Function(String) handler) {
    _tts.setErrorHandler((msg) {
      handler(msg);
    });
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
