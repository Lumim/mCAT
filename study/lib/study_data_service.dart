class StudyDataService {
  Future<void> createStudy(String studyId) async {
    // create new study entry
  }

  Future<void> saveWordListResult({
    required String studyId,
    required int listIndex,
    required String transcript,
    required List<String> expectedWords,
  }) async {
    // save per-list data
  }

  Future<void> completeStudy(String studyId) async {
    // mark study as completed
  }
}
