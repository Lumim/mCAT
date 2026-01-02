import 'package:mcat_package/src/services/stt_service.dart';
// Use relative import for study_data_service.dart
import 'study_data_service.dart'; // Make sure this file exists in same folder

class StudySTTService {
  final SttService _sttService = SttService();
  final StudyDataService _dataService = StudyDataService();

  String _currentTranscript = '';
  late String _studyId;

  void startNewStudy() {
    _studyId = DateTime.now().millisecondsSinceEpoch.toString();
    _dataService.createStudy(_studyId);
  }

  Future<void> startListening({
    required List<String> expectedWords,
    required int listIndex,
  }) async {
    // Store expected words if needed
    await _sttService.startListening(
      onPartialResult: (text) {
        _currentTranscript = text;
        print('Partial: $text');
      },
      onFinalResult: (text) {
        _currentTranscript = text;
        print('Final: $text');
      },
      durationSeconds: 20,
    );
  }

  Future<void> stopListening() async {
    await _sttService.stopListening();
  }

  Future<void> saveListResult({
    required int listIndex,
    required List<String> expectedWords,
  }) async {
    await _dataService.saveWordListResult(
      studyId: _studyId,
      listIndex: listIndex,
      transcript: _currentTranscript,
      expectedWords: expectedWords,
    );
  }

  Future<void> finishStudy() async {
    await _dataService.completeStudy(_studyId);
  }
}
