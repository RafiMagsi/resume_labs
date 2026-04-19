abstract interface class OpenAiDataSource {
  Future<String> generateSummary({
    required String jobTitle,
    required List<String> skills,
    required List<String> workHighlights,
  });

  Future<String> improveBullet({
    required String bullet,
    String? jobTitle,
  });

  Future<List<String>> suggestSkills({
    required String jobTitle,
    required List<String> existingSkills,
    String? personalSummary,
  });
}
