import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../repositories/purchase_repository.dart';

class PurchaseCreditsUseCase {
  final PurchaseRepository repository;

  const PurchaseCreditsUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.purchaseCredits();
  }
}
