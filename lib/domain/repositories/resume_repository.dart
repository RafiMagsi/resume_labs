import '../entities/resume.dart';

abstract interface class ResumeRepository {
  Future<Resume> createResume(Resume resume);

  Future<Resume> updateResume(Resume resume);

  Future<void> deleteResume(String resumeId);

  Future<Resume?> getResumeById(String resumeId);

  Future<List<Resume>> getResumesByUserId(String userId);
}