import 'package:fpdart/fpdart.dart';

import '../../core/errors/failure.dart';
import '../entities/resume.dart';

abstract interface class ResumeRepository {
  Future<Either<Failure, Resume>> createResume(Resume resume);

  Future<Either<Failure, Resume>> updateResume(Resume resume);

  Future<Either<Failure, void>> deleteResume(String resumeId);

  Future<Either<Failure, Resume?>> getResumeById(String resumeId);

  Future<Either<Failure, List<Resume>>> getResumesByUserId(String userId);
}