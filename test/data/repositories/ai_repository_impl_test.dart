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

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'No internet');
        },
        (_) => fail('Expected Left but got Right'),
      );
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

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'OpenAI unavailable');
        },
        (_) => fail('Expected Left but got Right'),
      );
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
        result.isLeft(),
        true,
      );
      result.match(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'Request timed out. Please try again.');
        },
        (_) => fail('Expected Left but got Right'),
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

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'Rate limited');
        },
        (_) => fail('Expected Left but got Right'),
      );
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

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Parse failed');
        },
        (_) => fail('Expected Left but got Right'),
      );
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

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Invalid JSON');
        },
        (_) => fail('Expected Left but got Right'),
      );
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
        result.isLeft(),
        true,
      );
      result.match(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'Request timed out. Please try again.');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });
  });
}
