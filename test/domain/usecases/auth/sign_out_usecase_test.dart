import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/repositories/auth_repository.dart';
import 'package:resume_labs/domain/usecases/auth/sign_out_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository repository;
  late SignOutUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignOutUseCase(repository);
  });

  test('returns Right(void) when repository succeeds', () async {
    when(() => repository.signOut()).thenAnswer((_) async => const Right(null));

    final result = await useCase();

    expect(result, const Right(null));
    verify(() => repository.signOut()).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(() => repository.signOut())
        .thenAnswer((_) async => const Left(ServerFailure('Sign out failed')));

    final result = await useCase();

    expect(result, const Left(ServerFailure('Sign out failed')));
  });
}
