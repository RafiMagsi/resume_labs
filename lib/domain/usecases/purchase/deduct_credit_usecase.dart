import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../repositories/purchase_repository.dart';

class DeductCreditUseCase {
  final PurchaseRepository repository;

  const DeductCreditUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.deductCredit();
  }
}
