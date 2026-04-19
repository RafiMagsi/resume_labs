import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../entities/resume.dart';
import '../../repositories/resume_repository.dart';

class CreateResumeUseCase {
  final ResumeRepository repository;

  const CreateResumeUseCase(this.repository);

  Future<Either<Failure, Resume>> call(Resume resume) {
    return repository.createResume(resume);
  }
}