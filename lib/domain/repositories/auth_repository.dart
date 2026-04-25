import 'package:fpdart/fpdart.dart';

import '../../core/errors/failure.dart';
import '../entities/user_profile.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserProfile>> signUp({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserProfile>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  Future<Either<Failure, UserProfile?>> getCurrentUser();

  Stream<UserProfile?> authStateChanges();
}
