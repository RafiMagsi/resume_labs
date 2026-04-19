import '../../models/resume_model.dart';

abstract interface class FirestoreResumeDataSource {
  Future<ResumeModel> createResume(ResumeModel resume);

  Future<ResumeModel?> getResumeById(String resumeId);

  Future<ResumeModel> updateResume(ResumeModel resume);

  Future<void> deleteResume(String resumeId);

  Future<List<ResumeModel>> getAllResumes({
    required String userId,
  });

  Stream<List<ResumeModel>> watchAllResumes({
    required String userId,
  });
}
