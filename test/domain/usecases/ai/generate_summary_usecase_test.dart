import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/repositories/ai_repository.dart';
import 'package:resume_labs/domain/usecases/ai/generate_summary_usecase.dart';

class MockAiRepository extends Mock implements AiRepository {}

void main() {
  late AiRepository repository;
  late GenerateSummaryUseCase useCase;

  setUp(() {
    repository = MockAiRepository();
    useCase = GenerateSummaryUseCase(repository);
  });

  test('returns Right(String) when repository succeeds', () async {
    when(
      () => repository.generateSummary(
        jobTitle: 'Flutter Developer',
        skills: const ['Flutter'],
        workHighlights: const ['Built apps'],
      ),
    ).thenAnswer((_) async => const Right('Summary'));

    final result = await useCase(
      jobTitle: 'Flutter Developer',
      skills: const ['Flutter'],
      workHighlights: const ['Built apps'],
    );

    expect(result, const Right('Summary'));
    verify(
      () => repository.generateSummary(
        jobTitle: 'Flutter Developer',
        skills: const ['Flutter'],
        workHighlights: const ['Built apps'],
      ),
    ).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(
      () => repository.generateSummary(
        jobTitle: 'Flutter Developer',
        skills: const ['Flutter'],
        workHighlights: const ['Built apps'],
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('OpenAI unavailable')));

    final result = await useCase(
      jobTitle: 'Flutter Developer',
      skills: const ['Flutter'],
      workHighlights: const ['Built apps'],
    );

    expect(result, const Left(ServerFailure('OpenAI unavailable')));
  });
}

