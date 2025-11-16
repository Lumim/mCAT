import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:stts/stts.dart' as stts;

/// ---------------------------------------------------------------------------
/// Continuous 20-second Speech-to-Text Service for mCAT (stts version)
/// Keeps restarting when STT stops early
/// ---------------------------------------------------------------------------
class SttService {
  final stts.Stt _speech = stts.Stt();

  bool _isReady = false;
  bool _isListening = false;
  bool _shouldContinue = false;

  String _localeId = 'en-US';
  String _collectedText = '';

  Timer? _sessionTimer;

  StreamSubscription<stts.SttRecognition>? _resultSub;
  StreamSubscription<stts.SttState>? _stateSub;

  bool get isListening => _isListening;
  String get collectedText => _collectedText;

  /// ---------------------------------------------
  /// INIT
  /// ---------------------------------------------
  Future<void> init() async {
    if (_isReady) return;

    final hasPermission = await _speech.hasPermission();
    if (!hasPermission) {
      throw Exception('Speech permission not granted.');
    }

    final supported = await _speech.isSupported();
    if (!supported) {
      throw Exception('Speech recognition not supported.');
    }

    // try to detect language
    try {
      final lang = await _speech.getLanguage();
      if (lang.isNotEmpty) {
        _localeId = lang;
      } else {
        _localeId = _normalizeLocale(ui.PlatformDispatcher.instance.locale);
        await _speech.setLanguage(_localeId);
      }
    } catch (_) {
      _localeId = _normalizeLocale(ui.PlatformDispatcher.instance.locale);
      try {
        await _speech.setLanguage(_localeId);
      } catch (_) {}
    }

    // listen to STT start/stop events
    _stateSub = _speech.onStateChanged.listen(
      (state) => _onStatus(state.name),
      onError: _onError,
    );

    _isReady = true;

    if (kDebugMode) debugPrint('🎙️ STT ready (locale: $_localeId)');
  }

  /// ---------------------------------------------
  /// START 20-second CONTINUOUS LISTENING
  /// ---------------------------------------------
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

    if (kDebugMode) {
      debugPrint('🎧 Starting seamless $durationSeconds s STT session...');
    }

    // stop after total duration
    _sessionTimer?.cancel();
    _sessionTimer = Timer(Duration(seconds: durationSeconds), () async {
      _shouldContinue = false;
      await stopListening();
      onFinalResult(_collectedText);
    });

    _listenCycle(onPartialResult, onFinalResult);
  }

  /// ---------------------------------------------
  /// ONE LISTENING CYCLE
  /// ---------------------------------------------
  Future<void> _listenCycle(
    void Function(String text) onPartialResult,
    void Function(String text) onFinalResult,
  ) async {
    if (!_shouldContinue) return;

    await _resultSub?.cancel();
    _resultSub = _speech.onResultChanged.listen((result) {
      final text = result.text.trim();
      if (text.isEmpty) return;

      if (!_collectedText.endsWith(text)) {
        _collectedText = '$_collectedText $text'.trim();
      }

      onPartialResult(_collectedText);

      if (result.isFinal) {
        if (kDebugMode) debugPrint('✅ Final segment: $text');
        onFinalResult(_collectedText);
      }
    });

    try {
      await _speech.setLanguage(_localeId);
    } catch (_) {}

    await _speech.start(
      const stts.SttRecognitionOptions(
        punctuation: true,
        offline: true,
      ),
    );
  }

  /// ---------------------------------------------
  /// STATUS CALLBACKS
  /// ---------------------------------------------
  void _onStatus(String status) {
    if (kDebugMode) debugPrint('STT status: $status');

    if (!_shouldContinue) return;

    if (status == stts.SttState.start.name) {
      _isListening = true;
      return;
    }

    if (status == stts.SttState.stop.name) {
      _isListening = false;

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

    Future.delayed(const Duration(milliseconds: 500), () async {
      if (_shouldContinue && !_isListening) {
        if (kDebugMode) debugPrint('🔁 Restarting after error...');
        await _listenCycle((_) {}, (_) {});
      }
    });
  }

  /// ---------------------------------------------
  /// STOP MANUALLY
  /// ---------------------------------------------
  Future<void> stopListening() async {
    _shouldContinue = false;
    _sessionTimer?.cancel();

    try {
      await _speech.stop();
    } catch (_) {}

    _isListening = false;
    await _resultSub?.cancel();

    if (kDebugMode) debugPrint('🛑 Listening stopped');
  }

  /// ---------------------------------------------
  /// DISPOSE
  /// ---------------------------------------------
  void dispose() {
    _shouldContinue = false;
    _sessionTimer?.cancel();
    _resultSub?.cancel();
    _stateSub?.cancel();
    try {
      _speech.dispose();
    } catch (_) {}
  }

  /// ---------------------------------------------
  /// NORMALIZE LOCALE
  /// ---------------------------------------------
  String _normalizeLocale(ui.Locale locale) {
    final lang = locale.languageCode.isNotEmpty ? locale.languageCode : 'en';
    final country =
        (locale.countryCode ?? '').isNotEmpty ? locale.countryCode! : 'US';
    return '$lang-$country'; // stts uses dash format
  }
}
