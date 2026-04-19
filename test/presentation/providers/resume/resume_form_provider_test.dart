import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/education.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/entities/skill.dart';
import 'package:resume_labs/domain/entities/work_experience.dart';
import 'package:resume_labs/domain/usecases/resume/create_resume_usecase.dart';
import 'package:resume_labs/domain/usecases/resume/update_resume_usecase.dart';
import 'package:resume_labs/injection/injection_container.dart';
import 'package:resume_labs/presentation/providers/resume/resume_form_provider.dart';

class MockCreateResumeUseCase extends Mock implements CreateResumeUseCase {}

class MockUpdateResumeUseCase extends Mock implements UpdateResumeUseCase {}

void main() {
  late CreateResumeUseCase createUseCase;
  late UpdateResumeUseCase updateUseCase;

  setUpAll(() {
    registerFallbackValue(
      Resume(
        id: 'fallback',
        userId: 'fallback',
        title: 'fallback',
        personalSummary: '',
        workExperiences: const <WorkExperience>[],
        educations: const <Education>[],
        skills: const <Skill>[],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
  });

  setUp(() {
    createUseCase = MockCreateResumeUseCase();
    updateUseCase = MockUpdateResumeUseCase();
  });

  test('save returns false and sets currentStep to first invalid step',
      () async {
    final container = ProviderContainer(
      overrides: [
        createResumeUseCaseProvider.overrideWithValue(createUseCase),
        updateResumeUseCaseProvider.overrideWithValue(updateUseCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(resumeFormProvider.notifier);
    notifier.reset(userId: 'user-1');

    final ok = await notifier.save();
    expect(ok, false);

    final state = container.read(resumeFormProvider);
    expect(state.currentStep, 0);
    expect(state.errorMessage, isNotNull);
    expect(state.validationErrors.isNotEmpty, true);
  });

  test('save uses create use case when not editing', () async {
    when(() => createUseCase(any())).thenAnswer(
      (invocation) async =>
          Right(invocation.positionalArguments.first as Resume),
    );

    final container = ProviderContainer(
      overrides: [
        createResumeUseCaseProvider.overrideWithValue(createUseCase),
        updateResumeUseCaseProvider.overrideWithValue(updateUseCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(resumeFormProvider.notifier);
    notifier.reset(userId: 'user-1');
    notifier.updateTitle('Flutter Developer');
    notifier.updatePersonalSummary('Summary');
    notifier.addWorkExperience(
      WorkExperience(
        company: 'ABC',
        role: 'Dev',
        location: 'Remote',
        startDate: DateTime(2020, 1, 1),
        endDate: null,
        bulletPoints: const ['Did things'],
        isCurrentRole: true,
      ),
    );
    notifier.addEducation(
      Education(
        school: 'Uni',
        degree: 'BS',
        field: 'CS',
        graduationDate: DateTime(2019, 1, 1),
        gpa: null,
      ),
    );
    notifier.addSkill(const Skill(name: 'Flutter', category: 'Mobile'));

    final future = notifier.save();
    expect(container.read(resumeFormProvider).isLoading, true);

    final ok = await future;
    expect(ok, true);

    verify(() => createUseCase(any())).called(1);
    verifyNever(() => updateUseCase(any()));
  });

  test('save emits failure message when create use case fails', () async {
    when(() => createUseCase(any()))
        .thenAnswer((_) async => const Left(ServerFailure('Failed')));

    final container = ProviderContainer(
      overrides: [
        createResumeUseCaseProvider.overrideWithValue(createUseCase),
        updateResumeUseCaseProvider.overrideWithValue(updateUseCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(resumeFormProvider.notifier);
    notifier.reset(userId: 'user-1');
    notifier.updateTitle('Flutter Developer');
    notifier.updatePersonalSummary('Summary');
    notifier.addWorkExperience(
      WorkExperience(
        company: 'ABC',
        role: 'Dev',
        location: 'Remote',
        startDate: DateTime(2020, 1, 1),
        endDate: null,
        bulletPoints: const ['Did things'],
        isCurrentRole: true,
      ),
    );
    notifier.addEducation(
      Education(
        school: 'Uni',
        degree: 'BS',
        field: 'CS',
        graduationDate: DateTime(2019, 1, 1),
        gpa: null,
      ),
    );
    notifier.addSkill(const Skill(name: 'Flutter', category: 'Mobile'));

    final ok = await notifier.save();
    expect(ok, false);
    expect(container.read(resumeFormProvider).errorMessage, 'Failed');
  });
}
