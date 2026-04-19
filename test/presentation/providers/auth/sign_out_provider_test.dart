import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/usecases/auth/sign_out_usecase.dart';
import 'package:resume_labs/injection/injection_container.dart';
import 'package:resume_labs/presentation/providers/auth/sign_out_provider.dart';

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late SignOutUseCase useCase;

  setUp(() {
    useCase = MockSignOutUseCase();
  });

  test('emits loading then data on success', () async {
    when(() => useCase()).thenAnswer((_) async => const Right(null));

    final container = ProviderContainer(
      overrides: [
        signOutUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(signOutProvider.notifier);

    final future = notifier.signOut();

    expect(container.read(signOutProvider), const AsyncLoading<void>());

    await future;

    expect(container.read(signOutProvider), const AsyncData<void>(null));
  });

  test('emits loading then error on failure', () async {
    when(() => useCase())
        .thenAnswer((_) async => const Left(ServerFailure('Sign out failed')));

    final container = ProviderContainer(
      overrides: [
        signOutUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(signOutProvider.notifier);

    await notifier.signOut();

    final state = container.read(signOutProvider);
    expect(state.hasError, true);
    expect(state.error, const ServerFailure('Sign out failed'));
  });
}

