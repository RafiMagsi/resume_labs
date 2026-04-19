import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/user_profile.dart';
import 'package:resume_labs/domain/repositories/auth_repository.dart';
import 'package:resume_labs/domain/usecases/auth/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository repository;
  late GetCurrentUserUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(repository);
  });

  test('returns Right(UserProfile?) when repository succeeds', () async {
    final user = UserProfile(
      uid: 'uid-1',
      email: 'test@example.com',
      createdAt: DateTime(2024, 1, 1),
    );

    when(() => repository.getCurrentUser())
        .thenAnswer((_) async => Right(user));

    final result = await useCase();

    expect(result, Right(user));
    verify(() => repository.getCurrentUser()).called(1);
  });

  test('returns Left(Failure) when repository fails', () async {
    when(() => repository.getCurrentUser())
        .thenAnswer((_) async => const Left(ServerFailure('Failed')));

    final result = await useCase();

    expect(result, const Left(ServerFailure('Failed')));
  });
}

