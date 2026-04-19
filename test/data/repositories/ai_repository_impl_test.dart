import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/app_exception.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/data/datasources/remote/openai_datasource.dart';
import 'package:resume_labs/data/repositories/ai_repository_impl.dart';

class MockOpenAiDataSource extends Mock implements OpenAiDataSource {}

void main() {
  late OpenAiDataSource dataSource;
  late AiRepositoryImpl repository;

  setUp(() {
    dataSource = MockOpenAiDataSource();
    repository = AiRepositoryImpl(dataSource);
  });

  group('generateSummary', () {
    test('returns Right when datasource succeeds', () async {
      when(
        () => dataSource.generateSummary(
          jobTitle: any(named: 'jobTitle'),
          skills: any(named: 'skills'),
          workHighlights: any(named: 'workHighlights'),
        ),
      ).thenAnswer((_) async => 'Strong professional summary');

      final result = await repository.generateSummary(
        jobTitle: 'Flutter Developer',
        skills: const ['Flutter', 'Firebase'],
        workHighlights: const ['Built production apps'],
      );

      expect(result, const Right('Strong professional summary'));
    });

    test('maps NetworkException to NetworkFailure', () async {
      when(
        () => dataSource.generateSummary(
          jobTitle: any(named: 'jobTitle'),
          skills: any(named: 'skills'),
          workHighlights: any(named: 'workHighlights'),
        ),
      ).thenThrow(const NetworkException('No internet'));

      final result = await repository.generateSummary(
        jobTitle: 'Flutter Developer',
        skills: const ['Flutter'],
        workHighlights: const ['Built app'],
      );

      expect(result, const Left(NetworkFailure('No internet')));
    });

    test('maps ServerException to ServerFailure', () async {
      when(
        () => dataSource.generateSummary(
          jobTitle: any(named: 'jobTitle'),
          skills: any(named: 'skills'),
          workHighlights: any(named: 'workHighlights'),
        ),
      ).thenThrow(const ServerException('OpenAI unavailable'));

      final result = await repository.generateSummary(
        jobTitle: 'Flutter Developer',
        skills: const ['Flutter'],
        workHighlights: const ['Built app'],
      );

      expect(result, const Left(ServerFailure('OpenAI unavailable')));
    });

    test('maps timeout to NetworkFailure', () async {
      when(
        () => dataSource.generateSummary(
          jobTitle: any(named: 'jobTitle'),
          skills: any(named: 'skills'),
          workHighlights: any(named: 'workHighlights'),
        ),
      ).thenAnswer(
        (_) => Future<String>.delayed(
          const Duration(seconds: 16),
          () => 'Late response',
        ),
      );

      final result = await repository.generateSummary(
        jobTitle: 'Flutter Developer',
        skills: const ['Flutter'],
        workHighlights: const ['Built app'],
      );

      expect(
        result,
        const Left(NetworkFailure('Request timed out. Please try again.')),
      );
    });
  });

  group('improveBullet', () {
    test('returns Right when datasource succeeds', () async {
      when(
        () => dataSource.improveBullet(
          bullet: any(named: 'bullet'),
          jobTitle: any(named: 'jobTitle'),
        ),
      ).thenAnswer((_) async => 'Improved bullet');

      final result = await repository.improveBullet(
        bullet: 'Made app better',
        jobTitle: 'Flutter Developer',
      );

      expect(result, const Right('Improved bullet'));
    });

    test('maps NetworkException to NetworkFailure', () async {
      when(
        () => dataSource.improveBullet(
          bullet: any(named: 'bullet'),
          jobTitle: any(named: 'jobTitle'),
        ),
      ).thenThrow(const NetworkException('Rate limited'));

      final result = await repository.improveBullet(
        bullet: 'Made app better',
        jobTitle: 'Flutter Developer',
      );

      expect(result, const Left(NetworkFailure('Rate limited')));
    });

    test('maps ServerException to ServerFailure', () async {
      when(
        () => dataSource.improveBullet(
          bullet: any(named: 'bullet'),
          jobTitle: any(named: 'jobTitle'),
        ),
      ).thenThrow(const ServerException('Parse failed'));

      final result = await repository.improveBullet(
        bullet: 'Made app better',
        jobTitle: 'Flutter Developer',
      );

      expect(result, const Left(ServerFailure('Parse failed')));
    });
  });

  group('suggestSkills', () {
    test('returns Right when datasource succeeds', () async {
      when(
        () => dataSource.suggestSkills(
          jobTitle: any(named: 'jobTitle'),
          existingSkills: any(named: 'existingSkills'),
          personalSummary: any(named: 'personalSummary'),
        ),
      ).thenAnswer((_) async => const ['Riverpod', 'Dart']);

      final result = await repository.suggestSkills(
        jobTitle: 'Flutter Developer',
        existingSkills: const ['Flutter'],
        personalSummary: 'Mobile engineer',
      );

      expect(result, const Right(['Riverpod', 'Dart']));
    });

    test('maps ServerException to ServerFailure', () async {
      when(
        () => dataSource.suggestSkills(
          jobTitle: any(named: 'jobTitle'),
          existingSkills: any(named: 'existingSkills'),
          personalSummary: any(named: 'personalSummary'),
        ),
      ).thenThrow(const ServerException('Invalid JSON'));

      final result = await repository.suggestSkills(
        jobTitle: 'Flutter Developer',
        existingSkills: const ['Flutter'],
        personalSummary: 'Mobile engineer',
      );

      expect(result, const Left(ServerFailure('Invalid JSON')));
    });

    test('maps timeout to NetworkFailure', () async {
      when(
        () => dataSource.suggestSkills(
          jobTitle: any(named: 'jobTitle'),
          existingSkills: any(named: 'existingSkills'),
          personalSummary: any(named: 'personalSummary'),
        ),
      ).thenAnswer(
        (_) => Future<List<String>>.delayed(
          const Duration(seconds: 16),
          () => ['Late', 'Response'],
        ),
      );

      final result = await repository.suggestSkills(
        jobTitle: 'Flutter Developer',
        existingSkills: const ['Flutter'],
        personalSummary: 'Mobile engineer',
      );

      expect(
        result,
        const Left(NetworkFailure('Request timed out. Please try again.')),
      );
    });
  });
}