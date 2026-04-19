import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../entities/resume.dart';
import '../../repositories/resume_repository.dart';

class GetAllResumesUseCase {
  final ResumeRepository repository;

  const GetAllResumesUseCase(this.repository);

  Future<Either<Failure, List<Resume>>> call(String userId) {
    return repository.getResumesByUserId(userId);
  }
}