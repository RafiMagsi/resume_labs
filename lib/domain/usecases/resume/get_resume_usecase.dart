import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../entities/resume.dart';
import '../../repositories/resume_repository.dart';

class GetResumeUseCase {
  final ResumeRepository repository;

  const GetResumeUseCase(this.repository);

  Future<Either<Failure, Resume?>> call(String resumeId) {
    return repository.getResumeById(resumeId);
  }
}