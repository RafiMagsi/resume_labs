import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/user_profile.dart';
import 'package:resume_labs/domain/repositories/auth_repository.dart';
import 'package:resume_labs/domain/usecases/auth/sign_up_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository repository;
  late SignUpUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignUpUseCase(repository);
  });

  test('returns Right(UserProfile) when repository succeeds', () async {
    final user = UserProfile(
      uid: 'uid-1',
      email: 'test@example.com',
      createdAt: DateTime(2024, 1, 1),
    );

    when(
      () => repository.signUp(
        email: 'test@example.com',
        password: 'password123',
      ),
    ).thenAnswer((_) async => Right(user));

    final result = await useCase(
      email: 'test@example.com',
      password: 'password123',
    );

    expect(result, Right(user));
    verify(
      () => repository.signUp(
        email: 'test@example.com',
        password: 'password123',
      ),
    ).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(
      () => repository.signUp(
        email: 'test@example.com',
        password: 'password123',
      ),
    ).thenAnswer((_) async => const Left(ValidationFailure('Invalid email')));

    final result = await useCase(
      email: 'test@example.com',
      password: 'password123',
    );

    expect(result, const Left(ValidationFailure('Invalid email')));
  });
}

