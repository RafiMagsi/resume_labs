import 'package:fpdart/fpdart.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
import '../datasources/local/resume_local_datasource.dart';
import '../datasources/remote/firestore_resume_datasource.dart';
import '../mappers/resume_mapper.dart';
import '../../domain/entities/resume.dart';
import '../../domain/repositories/resume_repository.dart';

class ResumeRepositoryImpl implements ResumeRepository {
  final FirestoreResumeDataSource remoteDataSource;
  final ResumeLocalDataSource localDataSource;

  const ResumeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Resume>> createResume(Resume resume) async {
    try {
      final model = resume.toModel();
      final remoteResult = await remoteDataSource.createResume(model);

      await localDataSource.cacheResume(remoteResult);

      return Right(remoteResult.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('An unexpected error occurred while creating resume.'),
      );
    }
  }

  @override
  Future<Either<Failure, Resume>> updateResume(Resume resume) async {
    try {
      final model = resume.toModel();
      final remoteResult = await remoteDataSource.updateResume(model);

      await localDataSource.cacheResume(remoteResult);

      return Right(remoteResult.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('An unexpected error occurred while updating resume.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteResume(String resumeId) async {
    try {
      await remoteDataSource.deleteResume(resumeId);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('An unexpected error occurred while deleting resume.'),
      );
    }
  }

  @override
  Future<Either<Failure, Resume?>> getResumeById(String resumeId) async {
    try {
      final remoteResult = await remoteDataSource.getResumeById(resumeId);
      if (remoteResult == null) {
        return const Right(null);
      }

      await localDataSource.cacheResume(remoteResult);

      return Right(remoteResult.toEntity());
    } on NetworkException catch (_) {
      return const Left(
        NetworkFailure('No internet connection. Unable to load resume.'),
      );
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('An unexpected error occurred while loading resume.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Resume>>> getResumesByUserId(
      String userId) async {
    try {
      final remoteResults =
          await remoteDataSource.getAllResumes(userId: userId);

      await localDataSource.cacheResumes(remoteResults);

      return Right(remoteResults.map((e) => e.toEntity()).toList());
    } on NetworkException catch (_) {
      try {
        final cachedResults =
            await localDataSource.getCachedResumes(userId: userId);

        return Right(cachedResults.map((e) => e.toEntity()).toList());
      } on AppException catch (cacheException) {
        return Left(_mapExceptionToFailure(cacheException));
      } catch (_) {
        return const Left(
          CacheFailure('Unable to load cached resumes.'),
        );
      }
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('An unexpected error occurred while loading resumes.'),
      );
    }
  }

  Failure _mapExceptionToFailure(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }

    if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    }

    if (exception is AuthException) {
      return AuthFailure(exception.message);
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
