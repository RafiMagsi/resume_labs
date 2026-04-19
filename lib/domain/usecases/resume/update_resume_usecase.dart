import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../entities/resume.dart';
import '../../repositories/resume_repository.dart';

class UpdateResumeUseCase {
  final ResumeRepository repository;

  const UpdateResumeUseCase(this.repository);

  Future<Either<Failure, Resume>> call(Resume resume) {
    return repository.updateResume(resume);
  }
}
