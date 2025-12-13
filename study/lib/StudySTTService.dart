import '../mcat_package/lib/src/services/stt_service.dart';
import 'study_data_service.dart';

class StudySTTService {
  final STTService _sttService = STTService();
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
    await _sttService.startListening((text) {
      _currentTranscript = text;
    });
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
