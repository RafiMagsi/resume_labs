import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_labs/core/errors/failure.dart';
import 'package:resume_labs/domain/usecases/auth/reset_password_usecase.dart';
import 'package:resume_labs/injection/injection_container.dart';
import 'package:resume_labs/presentation/providers/auth/reset_password_provider.dart';

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

void main() {
  late ResetPasswordUseCase useCase;

  setUp(() {
    useCase = MockResetPasswordUseCase();
  });

  test('emits loading then data on success', () async {
    when(
      () => useCase(email: 'test@example.com'),
    ).thenAnswer((_) async => const Right(null));

    final container = ProviderContainer(
      overrides: [
        resetPasswordUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(resetPasswordProvider.notifier);

    final future = notifier.resetPassword(email: 'test@example.com');

    expect(container.read(resetPasswordProvider), const AsyncLoading<void>());

    await future;

    expect(container.read(resetPasswordProvider), const AsyncData<void>(null));
  });

  test('emits loading then error on failure', () async {
    when(
      () => useCase(email: 'test@example.com'),
    ).thenAnswer((_) async => const Left(NetworkFailure('No internet')));

    final container = ProviderContainer(
      overrides: [
        resetPasswordUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(resetPasswordProvider.notifier);

    await notifier.resetPassword(email: 'test@example.com');

    final state = container.read(resetPasswordProvider);
    expect(state.hasError, true);
    expect(state.error, const NetworkFailure('No internet'));
  });
}

