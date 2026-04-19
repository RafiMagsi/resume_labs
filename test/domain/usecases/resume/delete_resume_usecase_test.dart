import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/repositories/resume_repository.dart';
import 'package:resume_labs/domain/usecases/resume/delete_resume_usecase.dart';

class MockResumeRepository extends Mock implements ResumeRepository {}

void main() {
  late ResumeRepository repository;
  late DeleteResumeUseCase useCase;

  setUp(() {
    repository = MockResumeRepository();
    useCase = DeleteResumeUseCase(repository);
  });

  test('returns Right(void) when repository succeeds', () async {
    when(() => repository.deleteResume('resume-1'))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase('resume-1');

    expect(result, const Right(null));
    verify(() => repository.deleteResume('resume-1')).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(() => repository.deleteResume('resume-1')).thenAnswer(
      (_) async => const Left(CacheFailure('Delete failed')),
    );

    final result = await useCase('resume-1');

    expect(result, const Left(CacheFailure('Delete failed')));
  });
}

