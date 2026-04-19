import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../entities/user_profile.dart';
import '../../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call({
    required String email,
    required String password,
  }) {
    return repository.signUp(
      email: email,
      password: password,
    );
  }
}