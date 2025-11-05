import 'package:speech_to_text_ultra/speech_to_text_ultra.dart';

/// Works with speech_to_text_ultra 0.0.3
class SttService {
  late final SpeechToTextUltra _stt;
  bool _isReady = false;
  bool _isListening = false;

  /// Initialize the STT engine with callback
  Future<void> init({Function(String)? onPartial}) async {
    try {
      _stt = SpeechToTextUltra(
        ultraCallback: (String text, String locale, bool isFinal) {
          // Callback returns recognized text + locale + final flag
          if (text.isNotEmpty && onPartial != null) {
            onPartial(text);
          }
        },
      );
      _isReady = true;
      print('✅ speech_to_text_ultra initialized');
    } catch (e) {
      print('❌ Error initializing speech_to_text_ultra: $e');
    }
  }

  /// Start listening
  Future<void> startListening({
    required Function(String) onResult,
  }) async {
    if (!_isReady) await init(onPartial: onResult);
    try {
      _isListening = true;
      await _stt.startListening();
      print('🎧 Listening started');
    } catch (e) {
      print('❌ Error starting listening: $e');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    try {
      await _stt.stopListening();
      _isListening = false;
      print('🛑 Listening stopped');
    } catch (e) {
      print('⚠️ stopListening error: $e');
    }
  }

  /// Dispose
  void dispose() {
    try {
      _stt.cancelListening();
      print('🧹 STT disposed');
    } catch (e) {
      print('⚠️ cancelListening error: $e');
    }
  }
}
