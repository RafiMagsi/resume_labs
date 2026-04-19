import '../../core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PdfRepository {
  Future<Either<Failure, String>> exportResumePdf({
    required String resumeId,
  });
}