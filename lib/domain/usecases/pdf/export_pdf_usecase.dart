import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../repositories/pdf_repository.dart';

class ExportPdfUseCase {
  final PdfRepository repository;

  const ExportPdfUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String resumeId,
  }) {
    return repository.exportResumePdf(
      resumeId: resumeId,
    );
  }
}