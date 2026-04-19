import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../repositories/ai_repository.dart';

class GenerateSummaryUseCase {
  final AiRepository repository;

  const GenerateSummaryUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String jobTitle,
    required List<String> skills,
    required List<String> workHighlights,
  }) {
    return repository.generateSummary(
      jobTitle: jobTitle,
      skills: skills,
      workHighlights: workHighlights,
    );
  }
}