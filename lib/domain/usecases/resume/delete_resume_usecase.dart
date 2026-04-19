import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../repositories/resume_repository.dart';

class DeleteResumeUseCase {
  final ResumeRepository repository;

  const DeleteResumeUseCase(this.repository);

  Future<Either<Failure, void>> call(String resumeId) {
    return repository.deleteResume(resumeId);
  }
}