import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
import '../datasources/remote/openai_datasource.dart';
import '../../domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final OpenAiDataSource dataSource;

  const AiRepositoryImpl(this.dataSource);

  static const Duration _timeout = Duration(seconds: 15);

  @override
  Future<Either<Failure, String>> generateSummary({
    required String jobTitle,
    required List<String> skills,
    required List<String> workHighlights,
  }) async {
    try {
      final result = await dataSource
          .generateSummary(
            jobTitle: jobTitle,
            skills: skills,
            workHighlights: workHighlights,
          )
          .timeout(_timeout);

      return Right(result);
    } on TimeoutException {
      return const Left(
        NetworkFailure('Request timed out. Please try again.'),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('An unexpected AI error occurred.'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> improveBullet({
    required String bullet,
    String? jobTitle,
  }) async {
    try {
      final result = await dataSource
          .improveBullet(
            bullet: bullet,
            jobTitle: jobTitle,
          )
          .timeout(_timeout);

      return Right(result);
    } on TimeoutException {
      return const Left(
        NetworkFailure('Request timed out. Please try again.'),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('An unexpected AI error occurred.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> suggestSkills({
    required String jobTitle,
    required List<String> existingSkills,
    String? personalSummary,
  }) async {
    try {
      final result = await dataSource
          .suggestSkills(
            jobTitle: jobTitle,
            existingSkills: existingSkills,
            personalSummary: personalSummary,
          )
          .timeout(_timeout);

      return Right(result);
    } on TimeoutException {
      return const Left(
        NetworkFailure('Request timed out. Please try again.'),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('An unexpected AI error occurred.'),
      );
    }
  }
}