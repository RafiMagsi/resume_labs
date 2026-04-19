import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/resume.dart';
import 'package:resume_labs/domain/repositories/resume_repository.dart';
import 'package:resume_labs/domain/usecases/resume/get_all_resumes_usecase.dart';

class MockResumeRepository extends Mock implements ResumeRepository {}

void main() {
  late ResumeRepository repository;
  late GetAllResumesUseCase useCase;

  setUp(() {
    repository = MockResumeRepository();
    useCase = GetAllResumesUseCase(repository);
  });

  test('returns Right(List<Resume>) when repository succeeds', () async {
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

    when(() => repository.getResumesByUserId('user-1'))
        .thenAnswer((_) async => Right([resume]));

    final result = await useCase('user-1');

    expect(result.isRight(), true);
    result.match(
      (_) => fail('Expected Right but got Left'),
      (resumes) => expect(resumes, [resume]),
    );
    verify(() => repository.getResumesByUserId('user-1')).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(() => repository.getResumesByUserId('user-1')).thenAnswer(
      (_) async => const Left(NetworkFailure('No internet')),
    );

    final result = await useCase('user-1');

    expect(result, const Left(NetworkFailure('No internet')));
  });
}

