import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../repositories/cv_optimization_repository.dart';
import '../../repositories/purchase_repository.dart';

class OptimizeCvUseCase {
  final CvOptimizationRepository _cvRepository;
  final PurchaseRepository _purchaseRepository;

  const OptimizeCvUseCase(
    this._cvRepository,
    this._purchaseRepository,
  );

  Future<Either<Failure, String>> call(String cvText) async {
    // Optimize the CV via AI
    final optimizeResult = await _cvRepository.optimizeCv(cvText);

    // Handle optimization failure
    if (optimizeResult.isLeft()) {
      return optimizeResult;
    }

    // Extract optimized CV
    final optimizedCv = (optimizeResult as Right<Failure, String>).value;

    // Deduct credit after successful optimization
    final deductResult = await _purchaseRepository.deductCredit();

    return deductResult.fold(
      (failure) => Left(failure),
      (_) => Right(optimizedCv),
    );
  }
}
