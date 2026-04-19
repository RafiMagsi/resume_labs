import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/repositories/resume_repository.dart';
import 'package:resume_labs/domain/usecases/resume/create_resume_usecase.dart';

class MockResumeRepository extends Mock implements ResumeRepository {}

void main() {
  late ResumeRepository repository;
  late CreateResumeUseCase useCase;

  setUp(() {
    repository = MockResumeRepository();
    useCase = CreateResumeUseCase(repository);
  });

  test('returns Right(Resume) when repository succeeds', () async {
    final resume = Resume(
      id: 'resume-1',
      userId: 'user-1',
      title: 'Flutter Developer',
      personalSummary: 'Summary',
      workExperiences: const [],
      educations: const [],
      skills: const [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    when(() => repository.createResume(resume))
        .thenAnswer((_) async => Right(resume));

    final result = await useCase(resume);

    expect(result, Right(resume));
    verify(() => repository.createResume(resume)).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    final resume = Resume(
      id: 'resume-1',
      userId: 'user-1',
      title: 'Flutter Developer',
      personalSummary: 'Summary',
      workExperiences: const [],
      educations: const [],
      skills: const [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    when(() => repository.createResume(resume)).thenAnswer(
      (_) async => const Left(ServerFailure('Failed to create')),
    );

    final result = await useCase(resume);

    expect(result, const Left(ServerFailure('Failed to create')));
  });
}
