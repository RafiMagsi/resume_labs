import 'package:fpdart/fpdart.dart';

import '../../core/errors/failure.dart';

abstract interface class AiRepository {
  Future<Either<Failure, String>> generateSummary({
    required String jobTitle,
    required List<String> skills,
    required List<String> workHighlights,
  });

  Future<Either<Failure, String>> improveBullet({
    required String bullet,
    String? jobTitle,
  });

  Future<Either<Failure, List<String>>> suggestSkills({
    required String jobTitle,
    required List<String> existingSkills,
    String? personalSummary,
  });
}
