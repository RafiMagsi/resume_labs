sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

final class PdfFailure extends Failure {
  const PdfFailure(super.message);
}

final class DocxFailure extends Failure {
  const DocxFailure(super.message);
}
