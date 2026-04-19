import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../injection/injection_container.dart';

final signInProvider =
    AsyncNotifierProvider<SignInNotifier, void>(SignInNotifier.new);

class SignInNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(signInUseCaseProvider);
    final result = await useCase(
      email: email,
      password: password,
    );

    state = result.match(
      (failure) => AsyncError(_mapFailureToMessage(failure), StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}