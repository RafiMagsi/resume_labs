import '../../repositories/purchase_repository.dart';

class CheckPremiumStatusUseCase {
  final PurchaseRepository repository;

  const CheckPremiumStatusUseCase(this.repository);

  Stream<bool> call() {
    return repository.premiumStatusStream;
  }
}
