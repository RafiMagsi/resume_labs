import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/repositories/ai_repository.dart';
import 'package:resume_labs/domain/usecases/ai/suggest_skills_usecase.dart';

class MockAiRepository extends Mock implements AiRepository {}

void main() {
  late AiRepository repository;
  late SuggestSkillsUseCase useCase;

  setUp(() {
    repository = MockAiRepository();
    useCase = SuggestSkillsUseCase(repository);
  });

  test('returns Right(List<String>) when repository succeeds', () async {
    when(
      () => repository.suggestSkills(
        jobTitle: 'Flutter Developer',
        existingSkills: const ['Flutter'],
        personalSummary: 'Summary',
      ),
    ).thenAnswer((_) async => const Right(['Dart', 'Firebase']));

    final result = await useCase(
      jobTitle: 'Flutter Developer',
      existingSkills: const ['Flutter'],
      personalSummary: 'Summary',
    );

    expect(result, const Right(['Dart', 'Firebase']));
    verify(
      () => repository.suggestSkills(
        jobTitle: 'Flutter Developer',
        existingSkills: const ['Flutter'],
        personalSummary: 'Summary',
      ),
    ).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(
      () => repository.suggestSkills(
        jobTitle: 'Flutter Developer',
        existingSkills: const ['Flutter'],
        personalSummary: 'Summary',
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('Failed')));

    final result = await useCase(
      jobTitle: 'Flutter Developer',
      existingSkills: const ['Flutter'],
      personalSummary: 'Summary',
    );

    expect(result, const Left(ServerFailure('Failed')));
  });
}
