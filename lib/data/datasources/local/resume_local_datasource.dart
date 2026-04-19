import '../../models/resume_model.dart';

abstract interface class ResumeLocalDataSource {
  Future<void> cacheResume(ResumeModel resume);

  Future<void> cacheResumes(List<ResumeModel> resumes);

  Future<List<ResumeModel>> getCachedResumes({
    required String userId,
  });

  Future<void> clearCachedResumes({
    String? userId,
  });
}