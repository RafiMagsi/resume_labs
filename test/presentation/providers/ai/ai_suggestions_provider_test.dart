import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/usecases/ai/generate_summary_usecase.dart';
import 'package:resume_labs/domain/usecases/ai/improve_bullet_usecase.dart';
import 'package:resume_labs/domain/usecases/ai/suggest_skills_usecase.dart';
import 'package:resume_labs/injection/injection_container.dart';
import 'package:resume_labs/presentation/providers/ai/ai_suggestions_provider.dart';

class MockGenerateSummaryUseCase extends Mock implements GenerateSummaryUseCase {}

class MockImproveBulletUseCase extends Mock implements ImproveBulletUseCase {}

class MockSuggestSkillsUseCase extends Mock implements SuggestSkillsUseCase {}

void main() {
  late GenerateSummaryUseCase generateSummary;
  late ImproveBulletUseCase improveBullet;
  late SuggestSkillsUseCase suggestSkills;

  setUp(() {
    generateSummary = MockGenerateSummaryUseCase();
    improveBullet = MockImproveBulletUseCase();
    suggestSkills = MockSuggestSkillsUseCase();
  });

  test('generateSummary emits loading then data on success', () async {
    when(
      () => generateSummary(
        jobTitle: any(named: 'jobTitle'),
        skills: any(named: 'skills'),
        workHighlights: any(named: 'workHighlights'),
      ),
    ).thenAnswer((_) async => const Right('Summary'));

    final container = ProviderContainer(
      overrides: [
        generateSummaryUseCaseProvider.overrideWithValue(generateSummary),
        improveBulletUseCaseProvider.overrideWithValue(improveBullet),
        suggestSkillsUseCaseProvider.overrideWithValue(suggestSkills),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(aiSuggestionsProvider.notifier);

    final future = notifier.generateSummary(
      jobTitle: 'Flutter Developer',
      skills: const ['Flutter'],
      workHighlights: const ['Built apps'],
    );

    expect(container.read(aiSuggestionsProvider), const AsyncLoading<AiSuggestionsState>());
    await future;

    final state = container.read(aiSuggestionsProvider).valueOrNull;
    expect(state?.generatedSummary, 'Summary');
  });

  test('generateSummary emits loading then error on failure', () async {
    when(
      () => generateSummary(
        jobTitle: any(named: 'jobTitle'),
        skills: any(named: 'skills'),
        workHighlights: any(named: 'workHighlights'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('OpenAI down')));

    final container = ProviderContainer(
      overrides: [
        generateSummaryUseCaseProvider.overrideWithValue(generateSummary),
        improveBulletUseCaseProvider.overrideWithValue(improveBullet),
        suggestSkillsUseCaseProvider.overrideWithValue(suggestSkills),
      ],
    );
    addTearDown(container.dispose);

    await container.read(aiSuggestionsProvider.notifier).generateSummary(
          jobTitle: 'Flutter Developer',
          skills: const ['Flutter'],
          workHighlights: const ['Built apps'],
        );

    final providerState = container.read(aiSuggestionsProvider);
    expect(providerState.hasError, true);
    expect(providerState.error, const ServerFailure('OpenAI down'));
  });
}

