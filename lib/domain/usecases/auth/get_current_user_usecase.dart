import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../entities/user_profile.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserProfile?>> call() {
    return repository.getCurrentUser();
  }
}
