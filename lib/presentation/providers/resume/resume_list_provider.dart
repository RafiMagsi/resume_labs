import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/resume.dart';
import '../../../injection/injection_container.dart';
import '../auth/auth_provider.dart';

final resumeListProvider = FutureProvider<List<Resume>>((ref) async {
  final authState = ref.watch(authProvider);
  final user = authState.valueOrNull;

  if (user == null) {
    return const [];
  }

  final useCase = ref.watch(getAllResumesUseCaseProvider);
  final result = await useCase(user.uid);

  return result.match(
    (_) => const <Resume>[],
    (resumes) {
      final sorted = [...resumes]
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return sorted;
    },
  );
});