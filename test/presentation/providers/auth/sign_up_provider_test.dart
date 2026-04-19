import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/user_profile.dart';
import 'package:resume_labs/domain/usecases/auth/sign_up_usecase.dart';
import 'package:resume_labs/injection/injection_container.dart';
import 'package:resume_labs/presentation/providers/auth/sign_up_provider.dart';

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

void main() {
  late SignUpUseCase useCase;

  setUp(() {
    useCase = MockSignUpUseCase();
  });

  test('emits loading then data on success', () async {
    final user = UserProfile(
      uid: 'uid-1',
      email: 'test@example.com',
      createdAt: DateTime(2024, 1, 1),
    );

    when(
      () => useCase(
        email: 'test@example.com',
        password: 'password123',
      ),
    ).thenAnswer((_) async => Right(user));

    final container = ProviderContainer(
      overrides: [
        signUpUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(signUpProvider.notifier);

    final future = notifier.signUp(
      email: 'test@example.com',
      password: 'password123',
    );

    expect(container.read(signUpProvider), const AsyncLoading<void>());

    await future;

    expect(container.read(signUpProvider), const AsyncData<void>(null));
  });

  test('emits loading then error on failure', () async {
    when(
      () => useCase(
        email: 'test@example.com',
        password: 'password123',
      ),
    ).thenAnswer((_) async => const Left(ValidationFailure('Invalid email')));

    final container = ProviderContainer(
      overrides: [
        signUpUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(signUpProvider.notifier);

    await notifier.signUp(
      email: 'test@example.com',
      password: 'password123',
    );

    final state = container.read(signUpProvider);
    expect(state.hasError, true);
    expect(state.error, const ValidationFailure('Invalid email'));
  });
}

