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

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  void dispose() {
    _tts.stop();
  }
}
