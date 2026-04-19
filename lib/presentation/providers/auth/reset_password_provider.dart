import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../injection/injection_container.dart';

final resetPasswordProvider = AsyncNotifierProvider<ResetPasswordNotifier, void>(
  ResetPasswordNotifier.new,
);

class ResetPasswordNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> resetPassword({
    required String email,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(resetPasswordUseCaseProvider);
    final result = await useCase(email: email);

    state = result.match(
      (failure) => AsyncError(_mapFailureToMessage(failure), StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}