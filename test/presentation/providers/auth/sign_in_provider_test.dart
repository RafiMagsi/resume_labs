import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/entities/user_profile.dart';
import 'package:resume_labs/domain/usecases/auth/sign_in_usecase.dart';
import 'package:resume_labs/injection/injection_container.dart';
import 'package:resume_labs/presentation/providers/auth/sign_in_provider.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}

void main() {
  late SignInUseCase useCase;

  setUp(() {
    useCase = MockSignInUseCase();
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
        signInUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(signInProvider.notifier);

    final future = notifier.signIn(
      email: 'test@example.com',
      password: 'password123',
    );

    expect(container.read(signInProvider), const AsyncLoading<void>());

    await future;

    expect(container.read(signInProvider), const AsyncData<void>(null));
  });

  test('emits loading then error on failure', () async {
    when(
      () => useCase(
        email: 'test@example.com',
        password: 'password123',
      ),
    ).thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

    final container = ProviderContainer(
      overrides: [
        signInUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(signInProvider.notifier);

    await notifier.signIn(
      email: 'test@example.com',
      password: 'password123',
    );

    final state = container.read(signInProvider);
    expect(state.hasError, true);
    expect(state.error, const AuthFailure('Invalid credentials'));
  });
}

