import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/repositories/ai_repository.dart';
import 'package:resume_labs/domain/usecases/ai/improve_bullet_usecase.dart';

class MockAiRepository extends Mock implements AiRepository {}

void main() {
  late AiRepository repository;
  late ImproveBulletUseCase useCase;

  setUp(() {
    repository = MockAiRepository();
    useCase = ImproveBulletUseCase(repository);
  });

  test('returns Right(String) when repository succeeds', () async {
    when(
      () => repository.improveBullet(
        bullet: 'Did stuff',
        jobTitle: 'Flutter Developer',
      ),
    ).thenAnswer((_) async => const Right('Improved'));

    final result = await useCase(
      bullet: 'Did stuff',
      jobTitle: 'Flutter Developer',
    );

    expect(result, const Right('Improved'));
    verify(
      () => repository.improveBullet(
        bullet: 'Did stuff',
        jobTitle: 'Flutter Developer',
      ),
    ).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(
      () => repository.improveBullet(
        bullet: 'Did stuff',
        jobTitle: 'Flutter Developer',
      ),
    ).thenAnswer((_) async => const Left(NetworkFailure('No internet')));

    final result = await useCase(
      bullet: 'Did stuff',
      jobTitle: 'Flutter Developer',
    );

    expect(result, const Left(NetworkFailure('No internet')));
  });
}
