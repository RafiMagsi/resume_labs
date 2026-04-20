import 'package:fpdart/fpdart.dart';

import '../../core/errors/failure.dart';

abstract interface class PurchaseRepository {
  Stream<bool> get premiumStatusStream;

  Future<Either<Failure, void>> purchasePremium();

  Future<Either<Failure, void>> restorePurchases();
}
