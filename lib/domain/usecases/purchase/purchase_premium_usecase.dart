import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../repositories/purchase_repository.dart';

class PurchasePremiumUseCase {
  final PurchaseRepository repository;

  const PurchasePremiumUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.purchasePremium();
  }
}
