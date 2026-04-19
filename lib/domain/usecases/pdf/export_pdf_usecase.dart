import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../entities/resume.dart';
import '../../entities/resume_template.dart';
import '../../repositories/pdf_repository.dart';

class ExportPdfUseCase {
  final PdfRepository repository;

  const ExportPdfUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required Resume resume,
    required ResumeTemplate template,
  }) {
    return repository.exportResumePdf(
      resume: resume,
      template: template,
    );
  }
}