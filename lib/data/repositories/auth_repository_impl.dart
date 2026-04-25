import 'package:fpdart/fpdart.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
import '../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../data/datasources/remote/firestore_user_datasource.dart';
import '../../data/mappers/user_profile_mapper.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/account_cleanup_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;
  final FirestoreUserDatasource userDatasource;
  final AccountCleanupDatasource accountCleanupDatasource;

  const AuthRepositoryImpl(
    this.dataSource, {
    required this.userDatasource,
    required this.accountCleanupDatasource,
  });

  @override
  Future<Either<Failure, UserProfile>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final result = await dataSource.signUp(
        email: email,
        password: password,
      );

      await userDatasource.createUserDoc(
        uid: result.uid,
        email: email,
      );

      return Right(result.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('An unexpected error occurred during sign up.'),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await dataSource.signIn(
        email: email,
        password: password,
      );

      return Right(result.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('An unexpected error occurred during sign in.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('An unexpected error occurred during sign out.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final currentUser = dataSource.getCurrentUser();
      if (currentUser == null) {
        return const Left(AuthFailure('No signed-in user found.'));
      }

      // Delete user-owned data first while we still have a valid auth session.
      await accountCleanupDatasource.deleteUserData(uid: currentUser.uid);

      // Finally, delete the auth account.
      await dataSource.deleteAccount();

      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('An unexpected error occurred while deleting account.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
  }) async {
    try {
      await dataSource.resetPassword(email: email);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure(
          'An unexpected error occurred while resetting the password.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> getCurrentUser() async {
    try {
      final result = dataSource.getCurrentUser();
      return Right(result?.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('An unexpected error occurred while loading the user.'),
      );
    }
  }

  @override
  Stream<UserProfile?> authStateChanges() {
    return dataSource.authStateChanges().map((model) => model?.toEntity());
  }

  Failure _mapExceptionToFailure(AppException exception) {
    if (exception is AuthException) {
      return AuthFailure(exception.message);
    }

    if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    }

    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }

    if (exception is CacheException) {
      return CacheFailure(exception.message);
    }

    if (exception is ServerException) {
      return ServerFailure(exception.message);
    }

    return UnknownFailure(exception.message);
  }
}
