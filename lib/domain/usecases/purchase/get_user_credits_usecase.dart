import '../../repositories/purchase_repository.dart';

class GetUserCreditsUseCase {
  final PurchaseRepository repository;

  const GetUserCreditsUseCase(this.repository);

  Stream<int> call() {
    return repository.creditsStream;
  }
}
