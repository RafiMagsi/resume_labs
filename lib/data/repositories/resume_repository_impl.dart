import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
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
  final FirebaseStorage? _firebaseStorage;

  ResumeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    FirebaseStorage? firebaseStorage,
  }) : _firebaseStorage = firebaseStorage;

  @override
  Future<Either<Failure, Resume>> createResume(Resume resume) async {
    try {
      var resumeToSave = resume;

      if (resume.photoUrl != null &&
          resume.photoUrl!.isNotEmpty &&
          !resume.photoUrl!.startsWith('http')) {
        try {
          final photoUrl = await _uploadResumePhoto(
            resume.userId,
            resume.id,
            resume.photoUrl!,
          );
          resumeToSave = resume.copyWith(photoUrl: photoUrl);
        } catch (e) {
          resumeToSave = resume.copyWith(photoUrl: null);
        }
      }

      final model = resumeToSave.toModel();
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
      var resumeToSave = resume;

      if (resume.photoUrl != null &&
          resume.photoUrl!.isNotEmpty &&
          !resume.photoUrl!.startsWith('http')) {
        try {
          final photoUrl = await _uploadResumePhoto(
            resume.userId,
            resume.id,
            resume.photoUrl!,
          );
          resumeToSave = resume.copyWith(photoUrl: photoUrl);
        } catch (e) {
          resumeToSave = resume.copyWith(photoUrl: null);
        }
      }

      final model = resumeToSave.toModel();
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
      await localDataSource.deleteResume(resumeId);
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

  Future<String> _uploadResumePhoto(
    String userId,
    String resumeId,
    String localPhotoPath,
  ) async {
    try {
      final file = File(localPhotoPath);
      if (!file.existsSync()) {
        throw FileSystemException('Photo file not found', localPhotoPath);
      }

      final storagePath = 'resumes/$userId/$resumeId/photo';
      final storage = _firebaseStorage ?? FirebaseStorage.instance;
      final ref = storage.ref(storagePath);

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw ServerException(
        'Failed to upload resume photo: ${e.toString()}',
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
