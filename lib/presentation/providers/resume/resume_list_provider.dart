import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/resume.dart';
import '../../../injection/injection_container.dart';
import '../auth/auth_provider.dart';

final resumeListProvider = StreamProvider<List<Resume>>((ref) async* {
  final authState = ref.watch(authProvider);

  final user = authState.valueOrNull;
  if (user == null) {
    yield const [];
    return;
  }

  final useCase = ref.watch(getAllResumesUseCaseProvider);
  final result = await useCase(user.uid);

  yield result.match(
    (_) => const <Resume>[],
    (resumes) => resumes,
  );
});