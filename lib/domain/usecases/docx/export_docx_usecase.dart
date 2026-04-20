import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../entities/resume.dart';
import '../../entities/resume_template.dart';
import '../../repositories/docx_repository.dart';

class ExportDocxUseCase {
  final DocxRepository repository;

  const ExportDocxUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required Resume resume,
    required ResumeTemplate template,
  }) {
    return repository.exportResumeDocx(
      resume: resume,
      template: template,
    );
  }
}
