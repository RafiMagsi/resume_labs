import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../injection/injection_container.dart';

final signOutProvider =
    AsyncNotifierProvider<SignOutNotifier, void>(SignOutNotifier.new);

class SignOutNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signOut() async {
    state = const AsyncLoading();

    final useCase = ref.read(signOutUseCaseProvider);
    final result = await useCase();

    state = result.match(
      (failure) => AsyncError(_mapFailureToMessage(failure), StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}