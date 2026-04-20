import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../injection/injection_container.dart';

part 'resume_optimization_provider.g.dart';

@riverpod
class ResumeOptimizationNotifier extends _$ResumeOptimizationNotifier {
  @override
  FutureOr<String?> build() {
    return null;
  }

  Future<void> optimizeResume(String resumeText) async {
    state = const AsyncLoading();

    final useCase = ref.read(optimizeCvUseCaseProvider);
    final result = await useCase(resumeText);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (optimizedResume) => AsyncData(optimizedResume),
    );
  }
}

@riverpod
Stream<int> creditsAvailable(CreditsAvailableRef ref) {
  final useCase = ref.watch(getUserCreditsUseCaseProvider);
  return useCase();
}
