import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/repositories/resume_repository.dart';
import 'package:resume_labs/domain/usecases/resume/get_resume_usecase.dart';

class MockResumeRepository extends Mock implements ResumeRepository {}

void main() {
  late ResumeRepository repository;
  late GetResumeUseCase useCase;

  setUp(() {
    repository = MockResumeRepository();
    useCase = GetResumeUseCase(repository);
  });

  test('returns Right(Resume?) when repository succeeds', () async {
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

    when(() => repository.getResumeById('resume-1'))
        .thenAnswer((_) async => Right(resume));

    final result = await useCase('resume-1');

    expect(result, Right(resume));
    verify(() => repository.getResumeById('resume-1')).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(() => repository.getResumeById('resume-1')).thenAnswer(
      (_) async => const Left(ServerFailure('Not found')),
    );

    final result = await useCase('resume-1');

    expect(result, const Left(ServerFailure('Not found')));
  });
}
