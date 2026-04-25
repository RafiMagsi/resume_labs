import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository repository;

  const DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.deleteAccount();
}
