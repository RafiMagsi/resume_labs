import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../repositories/ai_repository.dart';

class ImproveBulletUseCase {
  final AiRepository repository;

  const ImproveBulletUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String bullet,
    String? jobTitle,
  }) {
    return repository.improveBullet(
      bullet: bullet,
      jobTitle: jobTitle,
    );
  }
}
