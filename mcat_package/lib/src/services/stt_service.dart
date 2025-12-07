import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:stts/stts.dart' as stts;

/// Fixed Continuous Speech-to-Text Service for mCAT
/// Proper partial + final result merging
class SttService {
  final stts.Stt _speech = stts.Stt();

  bool _isReady = false;
  bool _isListening = false;
  bool _shouldContinue = false;

  late String _localeId;
  String _collectedText = '';
  String _currentSessionText = '';

  Timer? _sessionTimer;
  Timer? _restartTimer;

  StreamSubscription<stts.SttRecognition>? _resultSub;
  StreamSubscription<stts.SttState>? _stateSub;

  // Callbacks
  void Function(String text)? _onPartialResult;
  void Function(String text)? _onFinalResult;

  bool get isListening => _isListening;
  String get collectedText => _collectedText;

  /// INIT

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

    // Try to detect language
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

    // Listen to STT state changes
    _stateSub = _speech.onStateChanged.listen(
      _handleStateChange,
      onError: _onError,
    );

    _isReady = true;

    if (kDebugMode) debugPrint('🎙️ STT ready (locale: $_localeId)');
  }

  /// START 20-second CONTINUOUS LISTENING

  Future<void> startListening({
    required void Function(String text) onPartialResult,
    required void Function(String text) onFinalResult,
    int durationSeconds = 20,
  }) async {
    if (!_isReady) await init();
    if (_isListening) return;

    _collectedText = '';
    _currentSessionText = '';
    _shouldContinue = true;
    _isListening = true;

    _onPartialResult = onPartialResult;
    _onFinalResult = onFinalResult;

    if (kDebugMode) {
      debugPrint('🎧 Starting $durationSeconds s STT session...');
    }

    // Stop after total duration
    _sessionTimer?.cancel();
    _sessionTimer = Timer(Duration(seconds: durationSeconds), () async {
      if (kDebugMode) debugPrint('⏰ Session time completed');
      await _completeSession();
    });

    await _startListeningCycle();
  }

//listening cycle
  Future<void> _startListeningCycle() async {
    if (!_shouldContinue) return;

    await _resultSub?.cancel();
    _currentSessionText = '';

    _resultSub = _speech.onResultChanged.listen((result) {
      final text = result.text.trim();
      if (text.isEmpty) return;

      if (result.isFinal) {
        // Handle final result - merge with collected text
        _collectedText = _mergeText(_collectedText, text);
        _currentSessionText = ''; // Reset for next session

        if (kDebugMode)
          debugPrint('TICK Final: "$text" | Total: "$_collectedText"');

        _onFinalResult?.call(_collectedText);
      } else {
        // Handle partial result
        if (_isNewContent(text)) {
          _currentSessionText = text;
          final partialTotal = _mergeText(_collectedText, text);

          if (kDebugMode)
            debugPrint(' [Partial]: "$text" | Total: "$partialTotal"');

          _onPartialResult?.call(partialTotal);
        }
      }
    });

    try {
      await _speech.setLanguage(_localeId);
      await _speech.start(
        const stts.SttRecognitionOptions(
          punctuation: true,
          offline: true,
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('!! Start error: $e');
      _scheduleRestart();
    }
  }

  /// HANDLE STATE CHANGES

  void _handleStateChange(stts.SttState state) {
    if (kDebugMode) debugPrint('STT state: $state');

    if (!_shouldContinue) return;

    switch (state) {
      case stts.SttState.start:
        _isListening = true;
        _restartTimer?.cancel(); // Cancel any pending restarts
        break;

      case stts.SttState.stop:
        _isListening = false;
        if (_shouldContinue) {
          _scheduleRestart();
        }
        break;

      default:
        break;
    }
  }

  /// SCHEDULE RESTART WITH DELAY
  void _scheduleRestart() {
    if (!_shouldContinue) return;

    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(milliseconds: 500), () async {
      if (_shouldContinue && !_isListening) {
        if (kDebugMode) debugPrint('🔁 Restarting STT...');
        await _startListeningCycle();
      }
    });
  }

  /// COMPLETE SESSION
  Future<void> _completeSession() async {
    _shouldContinue = false;
    _sessionTimer?.cancel();
    _restartTimer?.cancel();

    try {
      await _speech.stop();
    } catch (_) {}

    _isListening = false;
    await _resultSub?.cancel();

    // Send final result
    _onFinalResult?.call(_collectedText);

    if (kDebugMode)
      debugPrint('🎯 Session completed. Final text: "$_collectedText"');
  }

  /// STOP MANUALLY
  Future<void> stopListening() async {
    await _completeSession();
  }

  /// TEXT PROCESSING HELPERS

  /// Check if new text is meaningfully different from current
  bool _isNewContent(String newText) {
    if (_currentSessionText.isEmpty) return true;

    // Simple similarity check - if new text is significantly different
    final currentWords = _currentSessionText.toLowerCase().split(' ');
    final newWords = newText.toLowerCase().split(' ');

    // If new text is longer or contains new words
    return newText.length > _currentSessionText.length ||
        newWords.any((word) => !currentWords.contains(word));
  }

  /// Merge text intelligently, avoiding duplicates
  String _mergeText(String existing, String newText) {
    if (existing.isEmpty) return newText;
    if (newText.isEmpty) return existing;

    final existingLower = existing.toLowerCase();
    final newLower = newText.toLowerCase();

    // If new text is already contained in existing text, return existing
    if (existingLower.contains(newLower)) {
      return existing;
    }

    // If existing text is contained in new text, return new text
    if (newLower.contains(existingLower)) {
      return newText;
    }

    // Check for overlapping words at the end/beginning
    final existingWords = existingLower.split(' ');
    final newWords = newLower.split(' ');

    // Look for overlapping sequences
    for (int overlap = 3; overlap >= 1; overlap--) {
      if (existingWords.length >= overlap && newWords.length >= overlap) {
        final existingEnd =
            existingWords.sublist(existingWords.length - overlap).join(' ');
        final newStart = newWords.sublist(0, overlap).join(' ');

        if (existingEnd == newStart) {
          // Merge with overlap
          return existing + ' ' + newWords.sublist(overlap).join(' ');
        }
      }
    }

    // No clear overlap, just append
    return '$existing $newText'.trim();
  }

  /// ERROR HANDLING
  void _onError(dynamic err) {
    if (kDebugMode) debugPrint('⚠️ STT error: $err');

    _isListening = false;

    if (_shouldContinue) {
      _scheduleRestart();
    }
  }

  /// DISPOSE
  void dispose() {
    _shouldContinue = false;
    _sessionTimer?.cancel();
    _restartTimer?.cancel();
    _resultSub?.cancel();
    _stateSub?.cancel();
    try {
      _speech.dispose();
    } catch (_) {}
  }

  /// NORMALIZE LOCALE
  String _normalizeLocale(ui.Locale locale) {
    final lang = locale.languageCode.isNotEmpty ? locale.languageCode : 'en';
    final country =
        (locale.countryCode ?? '').isNotEmpty ? locale.countryCode! : 'US';
    return '$lang-$country';
  }
}
