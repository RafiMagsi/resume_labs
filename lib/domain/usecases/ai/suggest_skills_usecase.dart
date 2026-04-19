import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../repositories/ai_repository.dart';

class SuggestSkillsUseCase {
  final AiRepository repository;

  const SuggestSkillsUseCase(this.repository);

  Future<Either<Failure, List<String>>> call({
    required String jobTitle,
    required List<String> existingSkills,
    String? personalSummary,
  }) {
    return repository.suggestSkills(
      jobTitle: jobTitle,
      existingSkills: existingSkills,
      personalSummary: personalSummary,
    );
  }
}
