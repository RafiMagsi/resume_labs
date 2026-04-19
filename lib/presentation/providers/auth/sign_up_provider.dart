import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../injection/injection_container.dart';

final signUpProvider =
    AsyncNotifierProvider<SignUpNotifier, void>(SignUpNotifier.new);

class SignUpNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(signUpUseCaseProvider);
    final result = await useCase(
      email: email,
      password: password,
    );

    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}
