import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../injection/injection_container.dart';

part 'premium_status_provider.g.dart';

@riverpod
Stream<int> userCredits(UserCreditsRef ref) {
  final useCase = ref.watch(getUserCreditsUseCaseProvider);
  return useCase();
}
