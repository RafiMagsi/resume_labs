import 'package:fpdart/fpdart.dart';

import '../../core/errors/failure.dart';

abstract interface class CvOptimizationRepository {
  Future<Either<Failure, String>> optimizeCv(String cvText);
}
