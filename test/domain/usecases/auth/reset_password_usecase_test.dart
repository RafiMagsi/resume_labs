import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/repositories/auth_repository.dart';
import 'package:resume_labs/domain/usecases/auth/reset_password_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository repository;
  late ResetPasswordUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = ResetPasswordUseCase(repository);
  });

  test('returns Right(void) when repository succeeds', () async {
    when(
      () => repository.resetPassword(email: 'test@example.com'),
    ).thenAnswer((_) async => const Right(null));

    final result = await useCase(email: 'test@example.com');

    expect(result, const Right(null));
    verify(() => repository.resetPassword(email: 'test@example.com')).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(
      () => repository.resetPassword(email: 'test@example.com'),
    ).thenAnswer((_) async => const Left(NetworkFailure('No internet')));

    final result = await useCase(email: 'test@example.com');

    expect(result, const Left(NetworkFailure('No internet')));
  });
}
