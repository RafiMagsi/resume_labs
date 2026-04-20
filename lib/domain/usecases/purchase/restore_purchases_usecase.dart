import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../repositories/purchase_repository.dart';

class RestorePurchasesUseCase {
  final PurchaseRepository repository;

  const RestorePurchasesUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.restorePurchases();
  }
}
