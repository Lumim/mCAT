import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Continuous Speech-to-Text Service for mCAT
/// ------------------------------------------
/// - Auto detects device locale (e.g. da_DK)
/// - Keeps listening by auto-restarting after silence
/// - Supports short pauses (default 8s)
/// - Emits both partial and final results
/// - Stops only when stopListening() is called
class SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isReady = false;
  bool _isListening = false;
  bool _shouldContinue = false;

  String _localeId = 'en_US';
  String _collectedText = '';

  bool get isListening => _isListening;
  String get collectedText => _collectedText;
  String get localeId => _localeId;

  /// Initialize engine and detect device language.
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
    if (kDebugMode) debugPrint('🎙️ STT ready, locale: $_localeId');
  }

  /// Start continuous listening and accumulate recognized text.
  ///
  /// [onPartialResult] — fires on each partial update.
  /// [onFinalResult] — fires when long silence or manual stop occurs.
  /// [silenceTimeoutSeconds] — silence duration before restart.
  /// [maxListenSeconds] — max session duration before restart.
  Future<void> startListening({
    required void Function(String text) onPartialResult,
    void Function(String text)? onFinalResult,
    double silenceTimeoutSeconds = 8.0,
    double maxListenSeconds = 30.0,
  }) async {
    if (!_isReady) await init();
    if (_isListening) return;

    _collectedText = '';
    _shouldContinue = true;

    await _startSession(
      onPartialResult,
      onFinalResult,
      silenceTimeoutSeconds,
      maxListenSeconds,
    );
  }

  Future<void> _startSession(
    void Function(String text) onPartialResult,
    void Function(String text)? onFinalResult,
    double silenceTimeoutSeconds,
    double maxListenSeconds,
  ) async {
    _isListening = true;
    if (kDebugMode) debugPrint('🎧 Listening ($_localeId)...');

    await _speech.listen(
      onResult: (result) {
        final text = result.recognizedWords.trim();
        if (text.isNotEmpty) {
          if (!_collectedText.endsWith(text)) {
            _collectedText = '$_collectedText $text'.trim();
          }
          onPartialResult(_collectedText);

          if (result.finalResult) {
            if (kDebugMode) debugPrint('✅ Final result: $text');
            onFinalResult?.call(_collectedText);
          }
        }
      },
      localeId: _localeId,
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
      listenFor: Duration(seconds: maxListenSeconds.toInt()),
      pauseFor: Duration(seconds: silenceTimeoutSeconds.toInt()),
    );
  }

  /// React to engine status changes (auto-restart)
  void _onStatus(String status) {
    if (kDebugMode) debugPrint('STT status: $status');
    if (!_shouldContinue) return;

    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      Future.delayed(const Duration(milliseconds: 400), () async {
        if (_shouldContinue && !_isListening) {
          if (kDebugMode) debugPrint('🔁 Auto-restarting STT...');
          await _startSession((_) {}, null, 8.0, 30.0);
        }
      });
    }
  }

  /// Handle plugin errors and recover
  void _onError(dynamic err) {
    if (kDebugMode) debugPrint('⚠️ STT error: $err');
    _isListening = false;
    if (_shouldContinue) {
      Future.delayed(const Duration(seconds: 1), () async {
        if (kDebugMode) debugPrint('🔁 Restarting after error...');
        await _startSession((_) {}, null, 8.0, 30.0);
      });
    }
  }

  /// Stop listening manually (user action)
  Future<void> stopListening() async {
    _shouldContinue = false;
    try {
      await _speech.stop();
    } catch (_) {
      await _speech.cancel();
    }
    _isListening = false;
    if (kDebugMode) debugPrint('🛑 Listening stopped.');
  }

  /// Dispose service cleanly
  void dispose() {
    _shouldContinue = false;
    try {
      _speech.cancel();
    } catch (_) {}
  }

  String _normalizeLocale(ui.Locale locale) {
    final lang = locale.languageCode.isNotEmpty ? locale.languageCode : 'en';
    final country =
        (locale.countryCode ?? '').isNotEmpty ? locale.countryCode : 'US';
    return '${lang}_${country}';
  }
}
