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
    // Note: In a real implementation, we would check current credits first.
    // For now, we assume the caller (UI layer) checks credits before calling this.

    // Optimize the CV via AI
    final optimizeResult = await _cvRepository.optimizeCv(cvText);

    return optimizeResult.fold(
      (failure) => Left(failure),
      (optimizedCv) async {
        // Deduct credit after successful optimization
        final deductResult = await _purchaseRepository.deductCredit();

        return deductResult.fold(
          (failure) => Left(failure),
          (_) => Right(optimizedCv),
        );
      },
    );
  }
}
