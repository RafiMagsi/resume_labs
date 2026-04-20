import 'package:fpdart/fpdart.dart';

import '../../core/errors/failure.dart';

abstract interface class PurchaseRepository {
  /// Stream of available CV optimization credits (0-unlimited)
  Stream<int> get creditsStream;

  /// Purchase 10 CV optimization credits for $5.99
  Future<Either<Failure, void>> purchaseCredits();

  /// Deduct 1 credit after CV optimization
  Future<Either<Failure, void>> deductCredit();

  /// Restore previous purchases (replenish credits)
  Future<Either<Failure, void>> restorePurchases();
}
