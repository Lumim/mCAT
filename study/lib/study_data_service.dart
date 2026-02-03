import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudyDataService {
  static final StudyDataService _instance = StudyDataService._internal();
  factory StudyDataService() => _instance;
  StudyDataService._internal();

  static const String _prefsKeyDeviceId = 'study_device_id';
  static const String _collectionName = 'mcat_study_sessions';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _deviceId;

  /// Returns a stable, device-specific ID for grouping sessions.
  Future<String> _getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    var stored = prefs.getString(_prefsKeyDeviceId);

    if (stored == null) {
      stored = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_prefsKeyDeviceId, stored);
    }

    _deviceId = stored;
    return stored;
  }

  DocumentReference<Map<String, dynamic>> _sessionDoc(String studyId) {
    return _firestore.collection(_collectionName).doc(studyId);
  }

  CollectionReference<Map<String, dynamic>> _wordListsCol(String studyId) {
    return _sessionDoc(studyId).collection('word_lists');
  }

  /// Create or update a study session document.
  ///
  /// Collection: mcat_study_sessions
  ///   doc(studyId): { deviceId, createdAt, completed }
  Future<void> createStudy(String studyId) async {
    final deviceId = await _getDeviceId();

    final docRef = _sessionDoc(studyId);

    await docRef.set({
      'deviceId': deviceId,
      'createdAt': FieldValue.serverTimestamp(),
      'completed': false,
    }, SetOptions(merge: true));
  }

  /// Save the result for ONE word list in a study session.
  ///
  /// Subcollection: mcat_study_sessions/{studyId}/word_lists
  /// Each call creates a NEW document (so you can run the task many times).
  Future<void> saveWordListResult({
    required String studyId,
    required int listIndex,
    required String transcript,
    required List<String> expectedWords,
  }) async {
    final deviceId = await _getDeviceId();

    final cleanedTranscript = transcript.trim();

    // Tokenize recognized text (very simple tokenizer).
    final recognizedTokens = _tokenize(cleanedTranscript);

    // Compute correctness vs expected words.
    final expectedLower = expectedWords
        .map((w) => w.toLowerCase().trim())
        .toList();
    final expectedSet = expectedLower.toSet();

    int correct = 0;
    for (final token in recognizedTokens) {
      if (expectedSet.contains(token)) {
        correct++;
      }
    }

    final total = expectedWords.length;
    final double accuracy = total > 0 ? correct / total : 0.0;

    final colRef = _wordListsCol(studyId);

    await colRef.add({
      'deviceId': deviceId,
      'listIndex': listIndex,
      'transcript': cleanedTranscript,
      'recognizedTokens': recognizedTokens,
      'expectedWords': expectedWords,
      'correct': correct,
      'total': total,
      'accuracy': accuracy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark the study as completed.
  Future<void> completeStudy(String studyId) async {
    final docRef = _sessionDoc(studyId);

    await docRef.set({
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Very simple tokenizer: lowercases, strips punctuation (keeps some Nordic chars),
  /// and splits on whitespace.
  List<String> _tokenize(String text) {
    if (text.isEmpty) return const [];

    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9æøåäöüß\s]', caseSensitive: false), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }
}
