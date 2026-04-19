import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../entities/user_profile.dart';
import '../../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  const SignInUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call({
    required String email,
    required String password,
  }) {
    return repository.signIn(
      email: email,
      password: password,
    );
  }
}