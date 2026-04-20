import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failure.dart';
import '../../entities/resume.dart';
import '../../entities/resume_template.dart';
import '../../repositories/pdf_repository.dart';

class GeneratePdfBytesUseCase {
  final PdfRepository repository;

  const GeneratePdfBytesUseCase(this.repository);

  Future<Either<Failure, Uint8List>> call({
    required Resume resume,
    required ResumeTemplate template,
  }) {
    return repository.generateResumePdfBytes(
      resume: resume,
      template: template,
    );
  }
}
