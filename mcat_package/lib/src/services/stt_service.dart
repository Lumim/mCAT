import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// ---------------------------------------------------------------------------
/// Continuous 20-second Speech-to-Text Service for mCAT
/// Keeps restarting when Android STT stops early
/// ---------------------------------------------------------------------------
class SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isReady = false;
  bool _isListening = false;
  bool _shouldContinue = false;

  String _localeId = 'en_US';
  String _collectedText = '';

  Timer? _sessionTimer;

  bool get isListening => _isListening;
  String get collectedText => _collectedText;

  Future<void> init() async {
    if (_isReady) return;
    final available = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
      debugLogging: kDebugMode,
    );
    if (!available) {
      throw Exception('Speech recognition not available on this device.');
    }

    try {
      final sys = await _speech.systemLocale();
      _localeId = sys?.localeId ??
          _normalizeLocale(ui.PlatformDispatcher.instance.locale);
    } catch (_) {
      _localeId = _normalizeLocale(ui.PlatformDispatcher.instance.locale);
    }

    _isReady = true;
    if (kDebugMode) debugPrint('🎙️ STT ready (locale: $_localeId)');
  }

  /// Seamless listening for [durationSeconds] total
  Future<void> startListening({
    required void Function(String text) onPartialResult,
    required void Function(String text) onFinalResult,
    int durationSeconds = 20,
  }) async {
    if (!_isReady) await init();
    if (_isListening) return;

    _collectedText = '';
    _shouldContinue = true;
    _isListening = true;

    if (kDebugMode)
      debugPrint('🎧 Starting seamless $durationSeconds s session');

    // stop everything after 20 s total
    _sessionTimer?.cancel();
    _sessionTimer = Timer(Duration(seconds: durationSeconds), () async {
      _shouldContinue = false;
      await stopListening();
      onFinalResult(_collectedText);
    });

    _listenCycle(onPartialResult, onFinalResult);
  }

  /// one recognition cycle; restarted automatically
  Future<void> _listenCycle(
    void Function(String text) onPartialResult,
    void Function(String text) onFinalResult,
  ) async {
    if (!_shouldContinue) return;

    await _speech.listen(
      localeId: _localeId,
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 20),
      onResult: (result) {
        final text = result.recognizedWords.trim();
        if (text.isEmpty) return;

        if (!_collectedText.endsWith(text)) {
          _collectedText = '$_collectedText $text'.trim();
        }

        onPartialResult(_collectedText);

        if (result.finalResult) {
          if (kDebugMode) debugPrint('✅ Segment: $text');
          onFinalResult(_collectedText);
        }
      },
    );
  }

  void _onStatus(String status) {
    if (kDebugMode) debugPrint('STT status: $status');
    if (!_shouldContinue) return;

    // Android reports "done" or "notListening" after a short silence
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      // restart quickly to continue same 20 s session
      Future.delayed(const Duration(milliseconds: 200), () async {
        if (_shouldContinue && !_isListening) {
          if (kDebugMode) debugPrint('🔁 Restarting STT cycle...');
          await _listenCycle((_) {}, (_) {});
        }
      });
    }
  }

  void _onError(dynamic err) {
    if (kDebugMode) debugPrint('⚠️ STT error: $err');
    _isListening = false;
    if (_shouldContinue) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (_shouldContinue && !_isListening) {
          if (kDebugMode) debugPrint('🔁 Restarting after error...');
          await _listenCycle((_) {}, (_) {});
        }
      });
    }
  }

  Future<void> stopListening() async {
    _shouldContinue = false;
    _sessionTimer?.cancel();
    try {
      await _speech.stop();
    } catch (_) {
      await _speech.cancel();
    }
    _isListening = false;
    if (kDebugMode) debugPrint('🛑 Listening stopped');
  }

  void dispose() {
    _shouldContinue = false;
    _sessionTimer?.cancel();
    try {
      _speech.cancel();
    } catch (_) {}
  }

  String _normalizeLocale(ui.Locale locale) {
    final lang = locale.languageCode.isNotEmpty ? locale.languageCode : 'en';
    final country =
        (locale.countryCode ?? '').isNotEmpty ? locale.countryCode : 'US';
    return '${lang}_$country';
  }
}
